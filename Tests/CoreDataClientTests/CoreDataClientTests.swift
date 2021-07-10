@testable import CoreDataClient
import XCTest
import Combine

final class CoreDataClientTests: XCTestCase {
    var client: CoreDataClient!
    var bag = Set<AnyCancellable>()
    var expectation: XCTestExpectation!

    override func setUp() {
        client = inMemoryStack()
    }

    func setupAsync() {
        expectation = expectation(description: "Expectation")
    }

    func setupData() {
        ["Alex", "Bill", "Charlie"].forEach { name in
            let pad = client.new(Person.self)
            pad.object?.name = name
            client.save(scratchPad: pad)
        }
    }

    override func tearDown() {
        bag.forEach { $0.cancel() }
        bag.removeAll()
        client = nil
        expectation = nil
    }

    func testContexts() {
        XCTAssertNotEqual(client.viewContext, client.newBackgroundContext())

        XCTAssertEqual(client.viewContext.concurrencyType, .mainQueueConcurrencyType)
        XCTAssertEqual(client.newBackgroundContext().concurrencyType, .privateQueueConcurrencyType)
    }

    func testSave() {
        setupAsync()

        let pad = client.new(Person.self)
        pad.object?.name = "Alex"

        client
            .save(scratchPad: pad)
            .sink { completion in
                switch completion {
                case .finished:
                    XCTAssertTrue(true, "Save should complete successfully.")
                case .failure(_):
                    XCTAssertFalse(true, "Save should not produce an error.")
                }

                self.expectation.fulfill()
            } receiveValue: { pad in
                XCTAssertEqual(pad.object?.name, "Alex")
            }
            .store(in: &bag)

        wait(for: [expectation], timeout: 1.0)
    }

    func testFetch() {
        setupAsync()

        client
            .objects(for: Person.fetchRequest())
            .sink { completion in
                switch completion {
                case .finished:
                    XCTAssertTrue(true, "Fetch should complete successfully.")
                case .failure(_):
                    XCTAssertFalse(true, "Fetch should not produce an error.")
                }

            } receiveValue: { pad in
                XCTAssertEqual(pad.object, nil)

            }
            .store(in: &bag)

        setupData()

        client.objects(for: Person.fetchRequest())
            .sink { completion in
                switch completion {
                case .finished:
                    XCTAssertTrue(true, "Fetch should complete successfully.")
                case .failure(_):
                    XCTAssertFalse(true, "Fetch should not produce an error.")
                }

                self.expectation.fulfill()
            } receiveValue: { pad in
                XCTAssert(pad.array.count == 3)

            }
            .store(in: &bag)


        wait(for: [expectation], timeout: 1.0)
    }

    func testReify() {
        let pad = client.new(Person.self)
        client.save(scratchPad: pad)

        let bgContext = client.newBackgroundContext()
        let bgPad = client.object(pad.object!,
                                  in: bgContext)

        XCTAssertNotNil(bgPad.object)
        XCTAssertEqual(bgPad.context, bgContext)
        XCTAssertEqual(pad.object?.objectID, bgPad.object?.objectID)

        let viewPad = client.object(bgPad.object!)

        XCTAssertNotNil(bgPad.object)
        XCTAssertEqual(viewPad.context, client.viewContext)
        XCTAssertEqual(bgPad.object?.objectID, viewPad.object?.objectID)
    }

    func testDelete() {
        setupAsync()
        setupData()

        let pad = client.new(Person.self)

        client
            .deleteObjects(in: pad)
            .sink { completion in
                switch completion {
                case .finished:
                    XCTAssertTrue(true)
                case .failure(_):
                    XCTAssertFalse(true)
                }
            } receiveValue: { pad in
                XCTAssertNil(pad.object)
                XCTAssertEqual(pad.context.deletedObjects.count, 0)
            }
            .store(in: &bag)

        client
            .deleteObjects(ofType: Person.self)
            .sink { completion in
                switch completion {
                case .finished:
                    XCTAssertTrue(true)
                case .failure(_):
                    XCTAssertFalse(true)
                }

                self.expectation.fulfill()
            } receiveValue: { pad in
                XCTAssertNil(pad.object)
                XCTAssertEqual(pad.array.count, 0)
            }
            .store(in: &bag)

        wait(for: [expectation], timeout: 1)
    }

    func testNew() {
        let pad: ScratchPad = client.new(Person.self)

        XCTAssertNotNil(pad)
        XCTAssertNotNil(pad.object)
        XCTAssertNotNil(pad.context)
    }
}




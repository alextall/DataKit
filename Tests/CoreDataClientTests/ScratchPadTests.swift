@testable import CoreDataClient
import XCTest
import Combine

final class ScratchPadTests: XCTestCase {

    var client: CoreDataClient!
    var expectation: XCTestExpectation!
    var bag = Set<AnyCancellable>()

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
        client = nil
    }

    func testScratchPadModel() {
        setupAsync()

        let empty = ScratchPad<Person>.empty(client.viewContext)

        XCTAssertEqual(empty.context, client.viewContext)
        XCTAssertNil(empty.object)
        XCTAssertEqual(empty.array.count, 0)

        let object = client.new(Person.self)

        XCTAssertEqual(object.context, client.viewContext)
        XCTAssertNotNil(object.object)
        XCTAssertEqual(object.array.count, 1)

        setupData()

        client
            .objects(for: Person.fetchRequest())
            .sink { completion in
                switch completion {
                case .finished:
                    XCTAssertTrue(true)
                case .failure(_):
                    XCTAssertFalse(true)
                }

                self.expectation.fulfill()
            } receiveValue: { pad in
                XCTAssertEqual(pad.context, self.client.viewContext)
                XCTAssertNotNil(pad.object)
                XCTAssertEqual(pad.array.count, 4)
            }
            .store(in: &bag)
        
        wait(for: [expectation], timeout: 1)
    }
}

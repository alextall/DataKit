import Combine
import Foundation

final class FolderMonitor {
    let handle: FileHandle
    let folderDidChange: PassthroughSubject<Void, Never>
    private let source: DispatchSourceFileSystemObject

    init(url: URL) throws {
        let representation = (url.path as NSString).fileSystemRepresentation
        let descriptor = open(representation, O_EVTONLY)
        handle = FileHandle(fileDescriptor: descriptor)

        folderDidChange = .init()

        source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: handle.fileDescriptor,
            eventMask: [.write],
            queue: .main
        )

        source.setEventHandler { [folderDidChange] in
            folderDidChange.send()
        }

        source.setCancelHandler { [handle] in
            try? handle.close()
        }

        source.setRegistrationHandler { [folderDidChange] in
            folderDidChange.send()
        }

        source.activate()
    }

    deinit {
        source.cancel()
    }
}

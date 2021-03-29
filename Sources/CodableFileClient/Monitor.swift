import Combine
import Foundation

final class FolderMonitor {
    let handle: FileHandle
    let folderDidChange: PassthroughSubject<Void, Never> = .init()
    private var source: DispatchSourceFileSystemObject

    init(url: URL) throws {
        let descriptor = FileManager.default.fileSystemRepresentation(withPath: url.path)

        handle = FileHandle(fileDescriptor: Int32(descriptor.pointee))

        source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: handle.fileDescriptor,
            eventMask: .write
        )

        source.setEventHandler { [folderDidChange] in
            folderDidChange.send()
        }

        source.setCancelHandler { [handle] in
            try? handle.close()
        }

        source.resume()
    }

    deinit {
        source.cancel()
    }
}

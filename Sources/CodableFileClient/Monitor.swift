import Foundation
import Combine

final class FolderMonitor {
    let handle: FileHandle
    let folderDidChange: PassthroughSubject<(), Never> = .init()
    private var source: DispatchSourceFileSystemObject

    init(url: URL) throws {
        handle = try FileHandle(forReadingFrom: url)

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

extension FolderMonitor: Hashable {
    static func == (lhs: FolderMonitor, rhs: FolderMonitor) -> Bool {
        lhs.handle.fileDescriptor == rhs.handle.fileDescriptor
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(handle.fileDescriptor)
    }
}

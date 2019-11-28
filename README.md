## DataKit

DataKit consists of several modules that add a `Combine` interface to `CoreData` and `URLSession`.
These modules can be used individually or together as needed.

**PersistenceClient:** A `CoreData` stack with convenience methods for the basic CRUD operations.

**PersistenceClient+Decodable:** The `PersistenceClient` stack with additional support for `NSManagedObject`s that conform to `Decodable`.

**PersistenceClient+Encodable:** The `PersistenceClient` stack with support for `NSManagedObject`s that conform to `Encodable`.

**PersistenceClient+Codable:** The `PersistenceClient` stack with support for `NSManagedObject`s that conform to `Codable`.

**HTTPClient:** A `URLSession` wrapper with convenience methods for `GET`, `POST`, `PUT`, and `DELETE` methods as well as executing pre-built `URLRequest`s.

**DataKit:** All of the above in one tidy package.

## Getting Started

DataKit is still in an experimental phase. Feel free to test it, but DataKit is not fit for production use.

### Requirements

DataKit uses Swift 5.1 in Xcode 11 and supports the platforms below.

- macOS 10.15+
- iOS 13.0+
- tvOS 13.0+
- watchOS 6.0+

## Installation

### Swift Package Manager

Swift Package Manager is the recommended way to install DataKit.

```swift
.package(url: "https://github.com/alextall/DataKit.git", from: "0.2.0")
```

### Git submodule

1. Add the DataKit repository as a [submodule](https://git-scm.com/docs/git-submodule) of your
    application’s repository.
1. Run `git submodule update --init --recursive` from within the DataKit folder.
1. Drag and drop the `Sources` folder into your application’s Xcode
    project or workspace.

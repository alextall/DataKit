## DataKit

DataKit consists of several modules that add a `Combine` interface to `CoreData` and `URLSession`.
These modules can be used individually or together as needed.

**CodableFileClient:** An object to read/write/delete `Codable` objects to disk. 

**CoreDataClient:** A `CoreData` stack with convenience methods for the basic CRUD operations. Includes support for `NSManagedObject`s that conform to `Codable`.

**HTTPClient:** A `URLSession` wrapper with convenience methods for `GET`, `POST`, `PUT`, and `DELETE` methods as well as executing pre-built `URLRequest`s.

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
.package(url: "https://github.com/alextall/DataKit.git", from: "0.3.0")
```

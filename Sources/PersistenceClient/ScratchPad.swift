import CoreData

public enum ScratchPad<T: NSFetchRequestResult> {
    case object(value: T, context: NSManagedObjectContext)
    case list(value: [T], context: NSManagedObjectContext)
    case empty(NSManagedObjectContext)

    public var context: NSManagedObjectContext {
        switch self {
        case let .object(_, ctx):
            return ctx
        case let .list(_, ctx):
            return ctx
        case let .empty(ctx):
            return ctx
        }
    }

    public var object: T? {
        switch self {
        case let .object(obj, _):
            return obj
        case let .list(objs, _):
            return objs.first
        case .empty:
            return nil
        }
    }

    public var array: [T] {
        switch self {
        case let .object(obj, _):
            return [obj]
        case let .list(objs, _):
            return objs
        case .empty:
            return []
        }
    }
}

extension ScratchPad: Equatable where T: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.context == rhs.context && lhs.array == rhs.array
    }
}

import CoreData

public enum ScratchPad<T: NSFetchRequestResult> {
    case object(value: T, context: NSManagedObjectContext)
    case list(value: [T], context: NSManagedObjectContext)
    case empty(NSManagedObjectContext)

    public var context: NSManagedObjectContext {
        switch self {
        case .object(_, let ctx):
            return ctx
        case .list(_, let ctx):
            return ctx
        case .empty(let ctx):
            return ctx
        }
    }

    public var object: T? {
        switch self {
        case .object(let obj, _):
            return obj
        case .list(let objs, _):
            return objs.first
        case .empty:
            return nil
        }
    }

    public var array: [T] {
        switch self {
        case .object(let obj, _):
            return [obj]
        case .list(let objs, _):
            return objs
        case .empty:
            return []
        }
    }
}

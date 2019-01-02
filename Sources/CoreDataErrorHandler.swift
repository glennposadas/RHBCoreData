import Foundation

public enum CoreDataErrorHandler {
    public static var shared: (Error) -> Void = { assertionFailure(String(describing: $0)) }
}


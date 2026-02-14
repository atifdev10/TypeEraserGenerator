import Foundation

/// Do not use directly.
public func __implicitCast<T1, T2>(
    _ input: T1,
    file: StaticString = #file,
    line: UInt = #line
) -> T2 {
    if T1.self == T2.self {
        return input as! T2
    }

    func initializeTypeEraser<T: TypeEraser>(_: T.Type) -> T2? {
        guard let input = input as? T._Base_ else { return nil }
        return T(erasing: input) as? T2
    }

    if let type = T2.self as? any TypeEraser.Type,
       let value = initializeTypeEraser(type) {
        return value
    }

    if let input = input as? any TypeEraser,
       let value = input.base as? T2 {
        return value
    }

    if let output = input as? T2 {
        return output
    }

    if let input = input as? any TypeEraser {
        let name = "\(type(of: input.base))"

        preconditionFailure(
            "Could not cast value of type '\(T1.self)' with base type of '\(name)' to '\(T2.self)'.",
            file: file,
            line: line
        )
    }

    preconditionFailure(
        "Could not cast value of type '\(T1.self)' to '\(T2.self)'.",
        file: file,
        line: line
    )
}

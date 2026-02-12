import Foundation
import SwiftSyntax

func transform<T: MutableCollection>(
    _ array: inout T,
    transformer: (_ index: T.Index, inout T.Element) throws -> Void
) rethrows {
    for index in array.indices {
        try transformer(index, &array[index])
    }
}

func transform<T: SyntaxCollection>(
    _ array: inout T,
    transformer: (_ index: T.Index, inout T.Element) throws -> Void
) rethrows {
    for index in array.indices {
        try transformer(index, &array[index])
    }
}

func transform<V, T: SyntaxCollection>(
    _ array: inout T,
    access: WritableKeyPath<T.Element, V>,
    transformer: (_ index: T.Index, inout V) throws -> Void
) rethrows {
    for index in array.indices {
        try transformer(index, &array[index][keyPath: access])
    }
}

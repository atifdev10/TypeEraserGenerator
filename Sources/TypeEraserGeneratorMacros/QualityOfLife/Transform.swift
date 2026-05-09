import Foundation
import SwiftSyntax

struct EquatableValues<T: Equatable> {
    fileprivate var values: [T]
}

func any<T: Equatable>(of values: T...) -> EquatableValues<T> {
    .init(values: values)
}

func == <T: Equatable>(lhs: T, rhs: EquatableValues<T>) -> Bool {
    rhs.values.contains(lhs)
}

func != <T: Equatable>(lhs: T, rhs: EquatableValues<T>) -> Bool {
    !rhs.values.contains(lhs)
}

extension SyntaxCollection {
    @discardableResult
    mutating func remove(where isRemoved: (Element) -> Bool) -> [Element] {
        var pendingRemovalIndexes: [SyntaxChildrenIndex] = []

        try! transform(&self) { index, element in
            guard isRemoved(element) else {
                throw LoopWorkflow.continue
            }

            pendingRemovalIndexes.append(index)
        }

        return remove(bulk: pendingRemovalIndexes)
    }

    @discardableResult
    mutating func remove(bulk indexes: [Index]) -> [Element] {
        var result = [Element]()

        var removalOffset = 0

        for index in indexes {
            let removed = remove(at: self.index(at: index.integer + removalOffset))
            removalOffset -= 1
            result.append(removed)
        }

        return result
    }
}

extension Array {
    @discardableResult
    mutating func remove(bulk indexes: [Index]) -> [Element] {
        var result = [Element]()

        var removalOffset = 0

        for index in indexes {
            let removed = remove(at: index + removalOffset)
            removalOffset -= 1
            result.append(removed)
        }

        return result
    }

    @discardableResult
    mutating func removeEverything(where isRemoved: (Element) -> Bool) -> [Element] {
        var result = [Element]()

        for index in indices where isRemoved(self[index]) {
            result.append(self[index])
        }

        removeAll(where: isRemoved)

        return result
    }
}

nonisolated func transform<T: MutableCollection>(
    _ array: inout T,
    label: Int = 0,
    operation: (inout T.Element) throws -> Void
) rethrows {
    for index in array.indices {
        var element: T.Element {
            get { array[index] }
            set { array[index] = newValue }
        }

        do {
            try operation(&element)
        } catch let LoopWorkflow.break(localLabel) where localLabel == label {
            break
        } catch let LoopWorkflow.continue(localLabel) where localLabel == label {
            continue
        }
    }
}

nonisolated func transform<T: MutableCollection>(
    _ array: inout T,
    label: Int = 0,
    operation: (T.Index, inout T.Element) throws -> Void
) rethrows {
    for index in array.indices {
        var element: T.Element {
            get { array[index] }
            set { array[index] = newValue }
        }

        do {
            try operation(index, &element)
        } catch let LoopWorkflow.break(localLabel) where localLabel == label {
            break
        } catch let LoopWorkflow.continue(localLabel) where localLabel == label {
            continue
        }
    }
}

nonisolated func transform<T: SyntaxCollection>(
    _ array: inout T,
    label: Int = 0,
    operation: (inout T.Element) throws -> Void
) rethrows {
    for index in array.indices {
        var element: T.Element {
            get { array[index] }
            set { array[index] = newValue }
        }

        do {
            try operation(&element)
        } catch let LoopWorkflow.break(localLabel) where localLabel == label {
            break
        } catch let LoopWorkflow.continue(localLabel) where localLabel == label {
            continue
        }
    }
}

nonisolated func transform<T: SyntaxCollection>(
    _ array: inout T,
    label: Int = 0,
    operation: (T.Index, inout T.Element) throws -> Void
) rethrows {
    for index in array.indices {
        var element: T.Element {
            get { array[index] }
            set { array[index] = newValue }
        }

        do {
            try operation(index, &element)
        } catch let LoopWorkflow.break(localLabel) where localLabel == label {
            break
        } catch let LoopWorkflow.continue(localLabel) where localLabel == label {
            continue
        }
    }
}

nonisolated func transform<V, T: SyntaxCollection>(
    _ array: inout T,
    label: Int = 0,
    access: WritableKeyPath<T.Element, V>,
    operation: (inout V) throws -> Void
) rethrows {
    for index in array.indices {
        var element: T.Element {
            get { array[index] }
            set { array[index] = newValue }
        }

        do {
            try operation(&element[keyPath: access])
        } catch let LoopWorkflow.break(localLabel) where localLabel == label {
            break
        } catch let LoopWorkflow.continue(localLabel) where localLabel == label {
            continue
        }
    }
}

nonisolated func transform<V, T: SyntaxCollection>(
    _ array: inout T,
    label: Int = 0,
    access: WritableKeyPath<T.Element, V>,
    operation: (T.Index, inout V) throws -> Void
) rethrows {
    for index in array.indices {
        var element: T.Element {
            get { array[index] }
            set { array[index] = newValue }
        }

        do {
            try operation(index, &element[keyPath: access])
        } catch let LoopWorkflow.break(localLabel) where localLabel == label {
            break
        } catch let LoopWorkflow.continue(localLabel) where localLabel == label {
            continue
        }
    }
}

enum LoopWorkflow: Error {
    case `break`(label: Int = 0)
    case `continue`(label: Int = 0)

    static var `break`: Self {
        .break()
    }

    static var `continue`: Self {
        .continue()
    }
}

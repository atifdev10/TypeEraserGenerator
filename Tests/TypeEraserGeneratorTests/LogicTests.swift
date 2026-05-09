import Testing
import TypeEraserGenerator
import TypeEraserGeneratorMacros

struct `Logic Tests` {
    @Test func `Implicit cast test`() async {
        let anyEquatable: AnyEquatable = .init(erasing: 1)

        #expect(implicitCast(anyEquatable) as Int == 1)
        #expect(implicitCast(anyEquatable) as AnyEquatable == AnyEquatable(erasing: 1))

        await #expect(processExitsWith: .failure) {
            let anyEquatable: AnyEquatable = .init(erasing: 1)
            _ = implicitCast(anyEquatable) as String
        }

        let string = "A"

        #expect(implicitCast(string) as String == string)
        #expect(implicitCast(string) as AnyEquatable == AnyEquatable(erasing: string))

        await #expect(processExitsWith: .failure) {
            let string = "A"
            _ = implicitCast(string) as Int
        }
    }

    @Test func `Array implicit cast test`() async {
        let array: [AnyEquatable] = [.init("A"), .init("B"), .init("C")]
        let arrayString = ["A", "B", "C"]

        #expect(implicitCast(array) as [String] == ["A", "B", "C"])
        #expect(implicitCast(arrayString) as [AnyEquatable] == [.init("A"), .init("B"), .init("C")])

        await #expect(processExitsWith: .failure) {
            let arrayString = ["A", "B", "C"]
            _ = implicitCast(arrayString) as [Int]
        }

        await #expect(processExitsWith: .failure) {
            let arrayString = ["A", "B", "C"]
            _ = implicitCast(arrayString) as Double
        }

        await #expect(processExitsWith: .failure) {
            let array: [AnyEquatable] = [.init("A"), .init("B"), .init("C")]
            _ = implicitCast(array) as [Int]
        }

        await #expect(processExitsWith: .failure) {
            let array: [AnyEquatable] = [.init("A"), .init(5), .init(3.5)]
            _ = implicitCast(array) as [Int]
        }
    }

    @Test func `Set implicit cast test`() async {
        let set: Set<AnyHashable> = [.init("A"), .init("B"), .init("C")]
        let setString: Set = ["A", "B", "C"]

        #expect(implicitCast(set) as Set<String> == ["A", "B", "C"])
        #expect(implicitCast(setString) as Set<AnyHashable> == [.init("A"), .init("B"), .init("C")])

        await #expect(processExitsWith: .failure) {
            let setString: Set = ["A", "B", "C"]
            _ = implicitCast(setString) as Set<Int>
        }

        await #expect(processExitsWith: .failure) {
            let setString: Set = ["A", "B", "C"]
            _ = implicitCast(setString) as Double
        }

        await #expect(processExitsWith: .failure) {
            let set: Set<AnyHashable> = [.init("A"), .init("B"), .init("C")]
            _ = implicitCast(set) as Set<Int>
        }

        await #expect(processExitsWith: .failure) {
            let set: Set<AnyHashable> = [.init("A"), .init(5), .init(3.5)]
            _ = implicitCast(set) as Set<Int>
        }
    }

    @Test func `Dictionary implicit cast test`() async {
        let dictionary: [AnyHashable: Int] = [.init("A"): 1, .init("B"): 2, .init("C"): 3]
        let dictionaryString = ["A": 1, "B": 2, "C": 3]

        #expect(implicitCast(dictionary) as [String: Int] == ["A": 1, "B": 2, "C": 3])
        #expect(implicitCast(dictionaryString) as [AnyHashable: Int] == [.init("A"): 1, .init("B"): 2, .init("C"): 3])

        await #expect(processExitsWith: .failure) {
            let dictionaryString = ["A": 1, "B": 2, "C": 3]
            _ = implicitCast(dictionaryString) as [Int: Int]
        }

        await #expect(processExitsWith: .failure) {
            let dictionaryString = ["A": 1, "B": 2, "C": 3]
            _ = implicitCast(dictionaryString) as Double
        }

        await #expect(processExitsWith: .failure) {
            let dictionary: [AnyHashable: Int] = [.init("A"): 1, .init("B"): 2, .init("C"): 3]
            _ = implicitCast(dictionary) as [Int: Int]
        }

        await #expect(processExitsWith: .failure) {
            let dictionary: [AnyHashable: Int] = [.init("A"): 1, .init(5): 2, .init(3.5): 3]
            _ = implicitCast(dictionary) as [Int: Int]
        }
    }
}

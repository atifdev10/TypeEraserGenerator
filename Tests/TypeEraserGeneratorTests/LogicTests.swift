import Testing
import TypeEraserGenerator
import TypeEraserGeneratorMacros

struct `Logic Tests` {
    @Test func `implicit cast test`() async {
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
}

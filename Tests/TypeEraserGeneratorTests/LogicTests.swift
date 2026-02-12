import Testing
import TypeEraserGenerator

@Suite
struct `Logic Tests` {
    @Test func implicitCastTest() async throws {
        let anyEquatable: AnyEquatable = .init(erasing: 1)

        #expect(__implicitCast(anyEquatable) as Int == 1)
        #expect(__implicitCast(anyEquatable) as AnyEquatable == AnyEquatable(erasing: 1))

        await #expect(processExitsWith: .failure) {
            let anyEquatable: AnyEquatable = .init(erasing: 1)
            _ = __implicitCast(anyEquatable) as String
        }

        let string = "A"

        #expect(__implicitCast(string) as String == string)
        #expect(__implicitCast(string) as AnyEquatable == AnyEquatable(erasing: string))

        await #expect(processExitsWith: .failure) {
            let string = "A"
            _ = __implicitCast(string) as Int
        }
    }
}

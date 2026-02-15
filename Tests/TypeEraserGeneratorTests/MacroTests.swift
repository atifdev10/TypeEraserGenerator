import MacroTesting
import Testing

@Suite(.macros(testMacros, record: .failed))
struct `Macro Tests` {
    @Suite
    struct `Eraser Tests` {
        @Test func `Type erased on protocol`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {}
                """
            } expansion: {
                """
                protocol Protocol {}

                struct AnyProtocol: Protocol, TypeEraser {
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }
                """
            }
        }

        @Test func `Type erased on isolated protocol`() {
            assertMacro {
                """
                @TypeErased
                @MainActor
                protocol Protocol {}

                @TypeErased
                nonisolated
                protocol Protocol {}
                """
            } expansion: {
                """
                @MainActor
                protocol Protocol {}

                @MainActor
                struct AnyProtocol: Protocol, TypeEraser {
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }
                nonisolated
                protocol Protocol {}

                nonisolated
                struct AnyProtocol: Protocol, TypeEraser {
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }
                """
            }
        }

        @Test func `Type erased on non-protocol`() {
            assertMacro {
                """
                @TypeErased
                struct Protocol {}

                @TypeErased
                class Protocol {}

                @TypeErased
                actor Protocol {}

                @TypeErased
                enum Protocol {}

                @TypeErased
                let value = 0
                """
            } diagnostics: {
                """
                @TypeErased
                ┬──────────
                ╰─ 🛑 Only protocols are type erasable
                struct Protocol {}

                @TypeErased
                ┬──────────
                ╰─ 🛑 Only protocols are type erasable
                class Protocol {}

                @TypeErased
                ┬──────────
                ╰─ 🛑 Only protocols are type erasable
                actor Protocol {}

                @TypeErased
                ┬──────────
                ╰─ 🛑 Only protocols are type erasable
                enum Protocol {}

                @TypeErased
                ┬──────────
                ╰─ 🛑 Only protocols are type erasable
                let value = 0
                """
            }
        }
    }

    @Suite
    struct `Variable Tests` {
        @Test func `Standard variables`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    var variable: Any { get }
                    var variable: Any { get set }
                    var variable: Any { get async }
                    var variable: Any { get throws }
                    var variable: Any { get async throws }
                    var variable: Any { get throws(any Error) }
                    var variable: Any { get throws(SomeError) }
                    var variable: Any { get throws(Never) }
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    var variable: Any { get }
                    var variable: Any { get set }
                    var variable: Any { get async }
                    var variable: Any { get throws }
                    var variable: Any { get async throws }
                    var variable: Any { get throws(any Error) }
                    var variable: Any { get throws(SomeError) }
                    var variable: Any { get throws(Never) }
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    var variable: Any {
                        get {
                            func variable_genericOpen<T: Protocol>(_: T) -> Any  {
                                var base: T {
                                    get {
                                        self.base as! T
                                    }
                                };
                                return base.variable
                            };
                            return __implicitCast(_openExistential(self.base, do: variable_genericOpen))
                        }
                    }
                    var variable: Any {
                        get {
                            func variable_genericOpen<T: Protocol>(_: T) -> Any  {
                                var base: T {
                                    get {
                                        self.base as! T
                                    }
                                };
                                return base.variable
                            };
                            return __implicitCast(_openExistential(self.base, do: variable_genericOpen))
                        }
                        set {
                            func variable_genericOpen<T: Protocol>(_: T) {
                                var base: T {
                                    get {
                                        self.base as! T
                                    }
                                    set {
                                        self.base = newValue
                                    }
                                };
                                base.variable = __implicitCast(newValue)
                            };
                            _openExistential(self.base, do: variable_genericOpen)
                        }
                    }
                    var variable: Any {
                        get async {
                            func variable_genericOpen<T: Protocol>(_: T) async -> Any  {
                                var base: T {
                                    get {
                                        self.base as! T
                                    }
                                };
                                return await base.variable
                            };
                            return await __implicitCast(_openExistential(self.base, do: variable_genericOpen))
                        }
                    }
                    var variable: Any {
                        get throws {
                            func variable_genericOpen<T: Protocol>(_: T) throws -> Any  {
                                var base: T {
                                    get {
                                        self.base as! T
                                    }
                                };
                                do {
                                    return try base.variable
                                } catch let error {
                                    throw __implicitCast(error)
                                }
                            };
                            return try __implicitCast(_openExistential(self.base, do: variable_genericOpen))
                        }
                    }
                    var variable: Any {
                        get async throws {
                            func variable_genericOpen<T: Protocol>(_: T) async throws -> Any  {
                                var base: T {
                                    get {
                                        self.base as! T
                                    }
                                };
                                do {
                                    return try await base.variable
                                } catch let error {
                                    throw __implicitCast(error)
                                }
                            };
                            return try await __implicitCast(_openExistential(self.base, do: variable_genericOpen))
                        }
                    }
                    var variable: Any {
                        get throws(any Error) {
                            func variable_genericOpen<T: Protocol>(_: T) throws(any Error) -> Any  {
                                var base: T {
                                    get {
                                        self.base as! T
                                    }
                                };
                                do {
                                    return try base.variable
                                } catch let error {
                                    throw __implicitCast(error)
                                }
                            };
                            return try __implicitCast(_openExistential(self.base, do: variable_genericOpen))
                        }
                    }
                    var variable: Any {
                        get throws(SomeError) {
                            func variable_genericOpen<T: Protocol>(_: T) throws(SomeError) -> Any  {
                                var base: T {
                                    get {
                                        self.base as! T
                                    }
                                };
                                do {
                                    return try base.variable
                                } catch let error {
                                    throw __implicitCast(error)
                                }
                            };
                            return try __implicitCast(_openExistential(self.base, do: variable_genericOpen))
                        }
                    }
                    var variable: Any {
                        get throws(Never) {
                            func variable_genericOpen<T: Protocol>(_: T) throws(Never) -> Any  {
                                var base: T {
                                    get {
                                        self.base as! T
                                    }
                                };
                                do {
                                    return try base.variable
                                } catch let error {
                                    throw __implicitCast(error)
                                }
                            };
                            return try __implicitCast(_openExistential(self.base, do: variable_genericOpen))
                        }
                    }
                }
                """
            }
        }

        @Test func `Standard variables with default specifiers`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @DefaultExternal(impl) var variable: Any { get }
                    @DefaultType<Type> var variable: Any { get }
                    @DefaultValue(1) var variable: Any { get }
                    @DefaultNone var variable: Any { get }
                }
                """
            } diagnostics: {
                """
                @TypeErased
                protocol Protocol {
                    @DefaultExternal(impl) var variable: Any { get }
                    @DefaultType<Type> var variable: Any { get }
                    ┬─────────────────
                    ╰─ 🛑 Only static requirements can have a default
                    @DefaultValue(1) var variable: Any { get }
                    ┬───────────────
                    ╰─ 🛑 Only static requirements can have a default
                    @DefaultNone var variable: Any { get }
                    ┬───────────
                    ╰─ 🛑 Only static requirements can have a default
                }
                """
            }
        }

        @Test func `Static non-marked variable`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    static var variable: Any { get }
                }
                """
            } diagnostics: {
                """
                @TypeErased
                ┬──────────
                ╰─ 🛑 Type erased protocols can't have static requirements
                protocol Protocol {
                    static var variable: Any { get }
                }
                """
            }
        }

        @Test func `Static variables without setter with default value`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @DefaultValue(1) static var variable: Any { get }
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    static var variable: Any { get }
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    static var variable: Any {
                        get {
                            __implicitCast(1)
                        }
                    }
                }
                """
            }
        }

        @Test func `Static variable with setter and default value`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @DefaultValue(1) static var variable: Any { get set }
                }
                """
            } diagnostics: {
                """
                @TypeErased
                protocol Protocol {
                    @DefaultValue(1) static var variable: Any { get set }
                    ┬───────────────
                    ╰─ 🛑 This default doesn't support the use of set requirement
                }
                """
            }
        }

        @Test func `Static variables with default type`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @DefaultType<Type> static var variable: Any { get }
                    @DefaultType<Type> static var variable: Any { get set }
                    @DefaultType<Type> static var variable: Any { get async }
                    @DefaultType<Type> static var variable: Any { get throws }
                    @DefaultType<Type> static var variable: Any { get async throws }
                    @DefaultType<Type> static var variable: Any { get throws(any Error) }
                    @DefaultType<Type> static var variable: Any { get throws(URLError) }
                    @DefaultType<Type> static var variable: Any { get throws(Never) }
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    static var variable: Any { get }
                    static var variable: Any { get set }
                    static var variable: Any { get async }
                    static var variable: Any { get throws }
                    static var variable: Any { get async throws }
                    static var variable: Any { get throws(any Error) }
                    static var variable: Any { get throws(URLError) }
                    static var variable: Any { get throws(Never) }
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    static var variable: Any {
                        get {
                            __implicitCast(Type.variable)
                        }
                    }
                    static var variable: Any {
                        get {
                            __implicitCast(Type.variable)
                        }
                        set {
                            Type.variable = __implicitCast(newValue)
                        }
                    }
                    static var variable: Any {
                        get async {
                            __implicitCast(Type.variable)
                        }
                    }
                    static var variable: Any {
                        get throws {
                            __implicitCast(Type.variable)
                        }
                    }
                    static var variable: Any {
                        get async throws {
                            __implicitCast(Type.variable)
                        }
                    }
                    static var variable: Any {
                        get throws(any Error) {
                            __implicitCast(Type.variable)
                        }
                    }
                    static var variable: Any {
                        get throws(URLError) {
                            __implicitCast(Type.variable)
                        }
                    }
                    static var variable: Any {
                        get throws(Never) {
                            __implicitCast(Type.variable)
                        }
                    }
                }
                """
            }
        }

        @Test func `Static variables without setter with external default`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @DefaultExternal(impl1) static var variable: Any { get }
                    @DefaultExternal(impl1) static var variable: Any { get async }
                    @DefaultExternal(impl1) static var variable: Any { get throws }
                    @DefaultExternal(impl1) static var variable: Any { get async throws }
                    @DefaultExternal(impl1) static var variable: Any { get throws(any Error) }
                    @DefaultExternal(impl1) static var variable: Any { get throws(URLError) }
                    @DefaultExternal(impl1) static var variable: Any { get throws(Never) }
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    @DefaultExternal(impl1) static var variable: Any { get }
                    @DefaultExternal(impl1) static var variable: Any { get async }
                    @DefaultExternal(impl1) static var variable: Any { get throws }
                    @DefaultExternal(impl1) static var variable: Any { get async throws }
                    @DefaultExternal(impl1) static var variable: Any { get throws(any Error) }
                    @DefaultExternal(impl1) static var variable: Any { get throws(URLError) }
                    @DefaultExternal(impl1) static var variable: Any { get throws(Never) }
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    static var variable: Any {
                        get {
                            __implicitCast(impl1())
                        }
                    }
                    static var variable: Any {
                        get async {
                            await __implicitCast(impl1())
                        }
                    }
                    static var variable: Any {
                        get throws {
                            try __implicitCast(impl1())
                        }
                    }
                    static var variable: Any {
                        get async throws {
                            try await __implicitCast(impl1())
                        }
                    }
                    static var variable: Any {
                        get throws(any Error) {
                            try __implicitCast(impl1())
                        }
                    }
                    static var variable: Any {
                        get throws(URLError) {
                            try __implicitCast(impl1())
                        }
                    }
                    static var variable: Any {
                        get throws(Never) {
                            try __implicitCast(impl1())
                        }
                    }
                }
                """
            }
        }

        @Test func `Static variables with setter with external default`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @DefaultExternal(impl1) static var variable: Any { get set }
                    @DefaultExternal(impl1, impl2) static var variable: Any { get set }
                }
                """
            } expansion: {
                #"""
                protocol Protocol {
                    @DefaultExternal(impl1) static var variable: Any { get set }
                    @DefaultExternal(impl1, impl2) static var variable: Any { get set }
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    static var variable: Any {
                        get {
                            __implicitCast(impl1())
                        }
                        set {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                    }
                    static var variable: Any {
                        get {
                            __implicitCast(impl1())
                        }
                        set {
                            impl2(newValue)
                        }
                    }
                }
                """#
            }
        }

        @Test func `Static variables with no default`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @DefaultNone static var variable: Any { get }
                    @DefaultNone static var variable: Any { get set }
                }
                """
            } expansion: {
                #"""
                protocol Protocol {
                    static var variable: Any { get }
                    static var variable: Any { get set }
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    static var variable: Any {
                        get {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                    }
                    static var variable: Any {
                        get {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                        set {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                    }
                }
                """#
            }
        }
    }

    @Suite
    struct `Function Tests` {
        @Test func `Standard functions with varying parameter and input labels`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    func function()
                    func function(label: Any)
                    func function(_: Any)
                    func function(label input: Any)
                    func function(_ input: Any)
                    func function(label _: Any)
                    func function(_ _: Any)
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    func function()
                    func function(label: Any)
                    func function(_: Any)
                    func function(label input: Any)
                    func function(_ input: Any)
                    func function(label _: Any)
                    func function(_ _: Any)
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    func function() {
                        func function_genericOpen<T: Protocol>(_: T) -> Void {
                            var base: T {
                                get {
                                    self.base as! T
                                }
                            };
                            return base.function()
                        };
                        return __implicitCast(_openExistential(self.base, do: function_genericOpen))
                    }
                    func function(label: Any) {
                        func function_genericOpen<T: Protocol>(_: T) -> Void {
                            var base: T {
                                get {
                                    self.base as! T
                                }
                            };
                            return base.function(label: __implicitCast(label))
                        };
                        return __implicitCast(_openExistential(self.base, do: function_genericOpen))
                    }
                    func function(_ param0: Any) {
                        func function_genericOpen<T: Protocol>(_: T) -> Void {
                            var base: T {
                                get {
                                    self.base as! T
                                }
                            };
                            return base.function(__implicitCast(param0))
                        };
                        return __implicitCast(_openExistential(self.base, do: function_genericOpen))
                    }
                    func function(label input: Any) {
                        func function_genericOpen<T: Protocol>(_: T) -> Void {
                            var base: T {
                                get {
                                    self.base as! T
                                }
                            };
                            return base.function(label: __implicitCast(input))
                        };
                        return __implicitCast(_openExistential(self.base, do: function_genericOpen))
                    }
                    func function(_ input: Any) {
                        func function_genericOpen<T: Protocol>(_: T) -> Void {
                            var base: T {
                                get {
                                    self.base as! T
                                }
                            };
                            return base.function(__implicitCast(input))
                        };
                        return __implicitCast(_openExistential(self.base, do: function_genericOpen))
                    }
                    func function(label _: Any) {
                        func function_genericOpen<T: Protocol>(_: T) -> Void {
                            var base: T {
                                get {
                                    self.base as! T
                                }
                            };
                            return base.function(label: __implicitCast(label))
                        };
                        return __implicitCast(_openExistential(self.base, do: function_genericOpen))
                    }
                    func function(_ param0: Any) {
                        func function_genericOpen<T: Protocol>(_: T) -> Void {
                            var base: T {
                                get {
                                    self.base as! T
                                }
                            };
                            return base.function(__implicitCast(param0))
                        };
                        return __implicitCast(_openExistential(self.base, do: function_genericOpen))
                    }
                }
                """
            }
        }

        @Test func `Standard functions with varying modifiers`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    func function() async
                    func function() throws
                    func function() async throws
                    func function() throws(any Error)
                    func function() throws(SomeError)
                    func function() throws(Never)
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    func function() async
                    func function() throws
                    func function() async throws
                    func function() throws(any Error)
                    func function() throws(SomeError)
                    func function() throws(Never)
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    func function() async {
                        func function_genericOpen<T: Protocol>(_: T) async -> Void {
                            var base: T {
                                get {
                                    self.base as! T
                                }
                            };
                            return await base.function()
                        };
                        return await __implicitCast(_openExistential(self.base, do: function_genericOpen))
                    }
                    func function() throws {
                        func function_genericOpen<T: Protocol>(_: T) throws -> Void {
                            var base: T {
                                get {
                                    self.base as! T
                                }
                            };
                            do {
                                return try base.function()
                            } catch let error {
                                throw __implicitCast(error)
                            }
                        };
                        return try __implicitCast(_openExistential(self.base, do: function_genericOpen))
                    }
                    func function() async throws {
                        func function_genericOpen<T: Protocol>(_: T) async throws -> Void {
                            var base: T {
                                get {
                                    self.base as! T
                                }
                            };
                            do {
                                return try await base.function()
                            } catch let error {
                                throw __implicitCast(error)
                            }
                        };
                        return try await __implicitCast(_openExistential(self.base, do: function_genericOpen))
                    }
                    func function() throws(any Error) {
                        func function_genericOpen<T: Protocol>(_: T) throws(any Error) -> Void {
                            var base: T {
                                get {
                                    self.base as! T
                                }
                            };
                            do {
                                return try base.function()
                            } catch let error {
                                throw __implicitCast(error)
                            }
                        };
                        return try __implicitCast(_openExistential(self.base, do: function_genericOpen))
                    }
                    func function() throws(SomeError) {
                        func function_genericOpen<T: Protocol>(_: T) throws(SomeError) -> Void {
                            var base: T {
                                get {
                                    self.base as! T
                                }
                            };
                            do {
                                return try base.function()
                            } catch let error {
                                throw __implicitCast(error)
                            }
                        };
                        return try __implicitCast(_openExistential(self.base, do: function_genericOpen))
                    }
                    func function() throws(Never) {
                        func function_genericOpen<T: Protocol>(_: T) throws(Never) -> Void {
                            var base: T {
                                get {
                                    self.base as! T
                                }
                            };
                            return base.function()
                        };
                        return __implicitCast(_openExistential(self.base, do: function_genericOpen))
                    }
                }
                """
            }
        }

        @Test func `Standard functions with default specifiers`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @DefaultExternal(impl) func function() -> Any
                    @DefaultType<Type> func function() -> Any
                    @DefaultValue(1) func function() -> Any
                    @DefaultNone func function() -> Any
                }
                """
            } diagnostics: {
                """
                @TypeErased
                protocol Protocol {
                    @DefaultExternal(impl) func function() -> Any
                    @DefaultType<Type> func function() -> Any
                    ┬─────────────────
                    ╰─ 🛑 Only static requirements can have a default
                    @DefaultValue(1) func function() -> Any
                    ┬───────────────
                    ╰─ 🛑 Only static requirements can have a default
                    @DefaultNone func function() -> Any
                    ┬───────────
                    ╰─ 🛑 Only static requirements can have a default
                }
                """
            }
        }

        @Test func `Static non-marked function`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    static func function()
                }
                """
            } diagnostics: {
                """
                @TypeErased
                ┬──────────
                ╰─ 🛑 Type erased protocols can't have static requirements
                protocol Protocol {
                    static func function()
                }
                """
            }
        }

        @Test func `Static function with default value`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @DefaultValue(1) static func function() -> Any
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    static func function() -> Any
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    static func function() -> Any {
                        1
                    }
                }
                """
            }
        }

        @Test func `Static function with default type with varying parameter and input labels`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @DefaultType<Type> static func function()
                    @DefaultType<Type> static func function(label: Any)
                    @DefaultType<Type> static func function(_: Any)
                    @DefaultType<Type> static func function(label input: Any)
                    @DefaultType<Type> static func function(_ input: Any)
                    @DefaultType<Type> static func function(label _: Any)
                    @DefaultType<Type> static func function(_ _: Any)
                }
                """
            } diagnostics: {
                """

                """
            } expansion: {
                """
                protocol Protocol {
                    static func function()
                    static func function(label: Any)
                    static func function(_: Any)
                    static func function(label input: Any)
                    static func function(_ input: Any)
                    static func function(label _: Any)
                    static func function(_ _: Any)
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    static func function() {
                        __implicitCast(Type.function())
                    }
                    static func function(label: Any) {
                        __implicitCast(Type.function(label: __implicitCast(label)))
                    }
                    static func function(_ param0: Any) {
                        __implicitCast(Type.function(__implicitCast(param0)))
                    }
                    static func function(label input: Any) {
                        __implicitCast(Type.function(label: __implicitCast(input)))
                    }
                    static func function(_ input: Any) {
                        __implicitCast(Type.function(__implicitCast(input)))
                    }
                    static func function(label _: Any) {
                        __implicitCast(Type.function(label: __implicitCast(label)))
                    }
                    static func function(_ param0: Any) {
                        __implicitCast(Type.function(__implicitCast(param0)))
                    }
                }
                """
            }
        }

        @Test func `Static function with default type with varying modifiers`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @DefaultType<Type> static func function() async
                    @DefaultType<Type> static func function() throws
                    @DefaultType<Type> static func function() async throws
                    @DefaultType<Type> static func function() throws(any Error)
                    @DefaultType<Type> static func function() throws(SomeError)
                    @DefaultType<Type> static func function() throws(Never)
                }
                """
            } diagnostics: {
                """

                """
            } expansion: {
                """
                protocol Protocol {
                    static func function() async
                    static func function() throws
                    static func function() async throws
                    static func function() throws(any Error)
                    static func function() throws(SomeError)
                    static func function() throws(Never)
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    static func function() async {
                        await __implicitCast(Type.function())
                    }
                    static func function() throws {
                        try __implicitCast(Type.function())
                    }
                    static func function() async throws {
                        try await __implicitCast(Type.function())
                    }
                    static func function() throws(any Error) {
                        try __implicitCast(Type.function())
                    }
                    static func function() throws(SomeError) {
                        try __implicitCast(Type.function())
                    }
                    static func function() throws(Never) {
                        __implicitCast(Type.function())
                    }
                }
                """
            }
        }

        @Test func `Static function with external default with varying parameter and input labels`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @DefaultExternal(impl) static func function()
                    @DefaultExternal(impl) static func function(label: Any)
                    @DefaultExternal(impl) static func function(_: Any)
                    @DefaultExternal(impl) static func function(label input: Any)
                    @DefaultExternal(impl) static func function(_ input: Any)
                    @DefaultExternal(impl) static func function(label _: Any)
                    @DefaultExternal(impl) static func function(_ _: Any)
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    @DefaultExternal(impl) static func function()
                    @DefaultExternal(impl) static func function(label: Any)
                    @DefaultExternal(impl) static func function(_: Any)
                    @DefaultExternal(impl) static func function(label input: Any)
                    @DefaultExternal(impl) static func function(_ input: Any)
                    @DefaultExternal(impl) static func function(label _: Any)
                    @DefaultExternal(impl) static func function(_ _: Any)
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    static func function() {
                        __implicitCast(impl())
                    }
                    static func function(label: Any) {
                        __implicitCast(impl(label: label))
                    }
                    static func function(_ param0: Any) {
                        __implicitCast(impl(param0))
                    }
                    static func function(label input: Any) {
                        __implicitCast(impl(label: input))
                    }
                    static func function(_ input: Any) {
                        __implicitCast(impl(input))
                    }
                    static func function(label _: Any) {
                        __implicitCast(impl(label: label))
                    }
                    static func function(_ param0: Any) {
                        __implicitCast(impl(param0))
                    }
                }
                """
            }
        }

        @Test func `Static function with external default with varying modifiers`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @DefaultExternal(impl) static func function() async
                    @DefaultExternal(impl) static func function() throws
                    @DefaultExternal(impl) static func function() async throws
                    @DefaultExternal(impl) static func function() throws(any Error)
                    @DefaultExternal(impl) static func function() throws(SomeError)
                    @DefaultExternal(impl) static func function() throws(Never)
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    @DefaultExternal(impl) static func function() async
                    @DefaultExternal(impl) static func function() throws
                    @DefaultExternal(impl) static func function() async throws
                    @DefaultExternal(impl) static func function() throws(any Error)
                    @DefaultExternal(impl) static func function() throws(SomeError)
                    @DefaultExternal(impl) static func function() throws(Never)
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    static func function() async {
                        await __implicitCast(impl())
                    }
                    static func function() throws {
                        try __implicitCast(impl())
                    }
                    static func function() async throws {
                        try await __implicitCast(impl())
                    }
                    static func function() throws(any Error) {
                        try __implicitCast(impl())
                    }
                    static func function() throws(SomeError) {
                        try __implicitCast(impl())
                    }
                    static func function() throws(Never) {
                        __implicitCast(impl())
                    }
                }
                """
            }
        }

        @Test func `Static function with no default`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @DefaultNone static func function()
                }
                """
            } expansion: {
                #"""
                protocol Protocol {
                    static func function()
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    static func function() {
                        fatalError("Tried to access static member \(#function) from type eraser")
                    }
                }
                """#
            }
        }
    }

    @Suite
    struct `Subscript Tests` {
        @Test func `Standard subscripts with varying parameter and input labels without setters`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    subscript() -> Any { get }
                    subscript(label: Any) -> Any { get }
                    subscript(_: Any) -> Any { get }
                    subscript(label input: Any) -> Any { get }
                    subscript(_ input: Any) -> Any { get }
                    subscript(label _: Any) -> Any { get }
                    subscript(_ _: Any) -> Any { get }
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    subscript() -> Any { get }
                    subscript(label: Any) -> Any { get }
                    subscript(_: Any) -> Any { get }
                    subscript(label input: Any) -> Any { get }
                    subscript(_ input: Any) -> Any { get }
                    subscript(label _: Any) -> Any { get }
                    subscript(_ _: Any) -> Any { get }
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    subscript() -> Any {
                        get {
                            func subscript_genericOpen<T: Protocol>(_: T) -> Any  {
                                var base: T {
                                    get {
                                        self.base as! T
                                    }
                                };
                                return base[]
                            };
                            return __implicitCast(_openExistential(self.base, do: subscript_genericOpen))
                        }
                    }
                    subscript(label: Any) -> Any {
                        get {
                            func subscript_genericOpen<T: Protocol>(_: T) -> Any  {
                                var base: T {
                                    get {
                                        self.base as! T
                                    }
                                };
                                return base[__implicitCast(label)]
                            };
                            return __implicitCast(_openExistential(self.base, do: subscript_genericOpen))
                        }
                    }
                    subscript(_ param0: Any) -> Any {
                        get {
                            func subscript_genericOpen<T: Protocol>(_: T) -> Any  {
                                var base: T {
                                    get {
                                        self.base as! T
                                    }
                                };
                                return base[__implicitCast(param0)]
                            };
                            return __implicitCast(_openExistential(self.base, do: subscript_genericOpen))
                        }
                    }
                    subscript(label input: Any) -> Any {
                        get {
                            func subscript_genericOpen<T: Protocol>(_: T) -> Any  {
                                var base: T {
                                    get {
                                        self.base as! T
                                    }
                                };
                                return base[label: __implicitCast(input)]
                            };
                            return __implicitCast(_openExistential(self.base, do: subscript_genericOpen))
                        }
                    }
                    subscript(_ input: Any) -> Any {
                        get {
                            func subscript_genericOpen<T: Protocol>(_: T) -> Any  {
                                var base: T {
                                    get {
                                        self.base as! T
                                    }
                                };
                                return base[__implicitCast(input)]
                            };
                            return __implicitCast(_openExistential(self.base, do: subscript_genericOpen))
                        }
                    }
                    subscript(label param0: Any) -> Any {
                        get {
                            func subscript_genericOpen<T: Protocol>(_: T) -> Any  {
                                var base: T {
                                    get {
                                        self.base as! T
                                    }
                                };
                                return base[label: __implicitCast(param0)]
                            };
                            return __implicitCast(_openExistential(self.base, do: subscript_genericOpen))
                        }
                    }
                    subscript(_ param0: Any) -> Any {
                        get {
                            func subscript_genericOpen<T: Protocol>(_: T) -> Any  {
                                var base: T {
                                    get {
                                        self.base as! T
                                    }
                                };
                                return base[__implicitCast(param0)]
                            };
                            return __implicitCast(_openExistential(self.base, do: subscript_genericOpen))
                        }
                    }
                }
                """
            }
        }

        @Test func `Standard subscripts with varying parameter and input labels with setters`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    subscript() -> Any { get set }
                    subscript(label: Any) -> Any { get set }
                    subscript(_: Any) -> Any { get set }
                    subscript(label input: Any) -> Any { get set }
                    subscript(_ input: Any) -> Any { get set }
                    subscript(label _: Any) -> Any { get set }
                    subscript(_ _: Any) -> Any { get set }
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    subscript() -> Any { get set }
                    subscript(label: Any) -> Any { get set }
                    subscript(_: Any) -> Any { get set }
                    subscript(label input: Any) -> Any { get set }
                    subscript(_ input: Any) -> Any { get set }
                    subscript(label _: Any) -> Any { get set }
                    subscript(_ _: Any) -> Any { get set }
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    subscript() -> Any {
                        get {
                            func subscript_genericOpen<T: Protocol>(_: T) -> Any  {
                                var base: T {
                                    get {
                                        self.base as! T
                                    }
                                };
                                return base[]
                            };
                            return __implicitCast(_openExistential(self.base, do: subscript_genericOpen))
                        }
                        set {
                            func subscript_genericOpen<T: Protocol>(_: T) {
                                var base: T {
                                    get {
                                        self.base as! T
                                    }
                                    set {
                                        self.base = newValue
                                    }
                                };
                                return base[] = __implicitCast(newValue)
                            };
                            _openExistential(self.base, do: subscript_genericOpen)
                        }
                    }
                    subscript(label: Any) -> Any {
                        get {
                            func subscript_genericOpen<T: Protocol>(_: T) -> Any  {
                                var base: T {
                                    get {
                                        self.base as! T
                                    }
                                };
                                return base[__implicitCast(label)]
                            };
                            return __implicitCast(_openExistential(self.base, do: subscript_genericOpen))
                        }
                        set {
                            func subscript_genericOpen<T: Protocol>(_: T) {
                                var base: T {
                                    get {
                                        self.base as! T
                                    }
                                    set {
                                        self.base = newValue
                                    }
                                };
                                return base[__implicitCast(label)] = __implicitCast(newValue)
                            };
                            _openExistential(self.base, do: subscript_genericOpen)
                        }
                    }
                    subscript(_ param0: Any) -> Any {
                        get {
                            func subscript_genericOpen<T: Protocol>(_: T) -> Any  {
                                var base: T {
                                    get {
                                        self.base as! T
                                    }
                                };
                                return base[__implicitCast(param0)]
                            };
                            return __implicitCast(_openExistential(self.base, do: subscript_genericOpen))
                        }
                        set {
                            func subscript_genericOpen<T: Protocol>(_: T) {
                                var base: T {
                                    get {
                                        self.base as! T
                                    }
                                    set {
                                        self.base = newValue
                                    }
                                };
                                return base[__implicitCast(param0)] = __implicitCast(newValue)
                            };
                            _openExistential(self.base, do: subscript_genericOpen)
                        }
                    }
                    subscript(label input: Any) -> Any {
                        get {
                            func subscript_genericOpen<T: Protocol>(_: T) -> Any  {
                                var base: T {
                                    get {
                                        self.base as! T
                                    }
                                };
                                return base[label: __implicitCast(input)]
                            };
                            return __implicitCast(_openExistential(self.base, do: subscript_genericOpen))
                        }
                        set {
                            func subscript_genericOpen<T: Protocol>(_: T) {
                                var base: T {
                                    get {
                                        self.base as! T
                                    }
                                    set {
                                        self.base = newValue
                                    }
                                };
                                return base[label: __implicitCast(input)] = __implicitCast(newValue)
                            };
                            _openExistential(self.base, do: subscript_genericOpen)
                        }
                    }
                    subscript(_ input: Any) -> Any {
                        get {
                            func subscript_genericOpen<T: Protocol>(_: T) -> Any  {
                                var base: T {
                                    get {
                                        self.base as! T
                                    }
                                };
                                return base[__implicitCast(input)]
                            };
                            return __implicitCast(_openExistential(self.base, do: subscript_genericOpen))
                        }
                        set {
                            func subscript_genericOpen<T: Protocol>(_: T) {
                                var base: T {
                                    get {
                                        self.base as! T
                                    }
                                    set {
                                        self.base = newValue
                                    }
                                };
                                return base[__implicitCast(input)] = __implicitCast(newValue)
                            };
                            _openExistential(self.base, do: subscript_genericOpen)
                        }
                    }
                    subscript(label param0: Any) -> Any {
                        get {
                            func subscript_genericOpen<T: Protocol>(_: T) -> Any  {
                                var base: T {
                                    get {
                                        self.base as! T
                                    }
                                };
                                return base[label: __implicitCast(param0)]
                            };
                            return __implicitCast(_openExistential(self.base, do: subscript_genericOpen))
                        }
                        set {
                            func subscript_genericOpen<T: Protocol>(_: T) {
                                var base: T {
                                    get {
                                        self.base as! T
                                    }
                                    set {
                                        self.base = newValue
                                    }
                                };
                                return base[label: __implicitCast(param0)] = __implicitCast(newValue)
                            };
                            _openExistential(self.base, do: subscript_genericOpen)
                        }
                    }
                    subscript(_ param0: Any) -> Any {
                        get {
                            func subscript_genericOpen<T: Protocol>(_: T) -> Any  {
                                var base: T {
                                    get {
                                        self.base as! T
                                    }
                                };
                                return base[__implicitCast(param0)]
                            };
                            return __implicitCast(_openExistential(self.base, do: subscript_genericOpen))
                        }
                        set {
                            func subscript_genericOpen<T: Protocol>(_: T) {
                                var base: T {
                                    get {
                                        self.base as! T
                                    }
                                    set {
                                        self.base = newValue
                                    }
                                };
                                return base[__implicitCast(param0)] = __implicitCast(newValue)
                            };
                            _openExistential(self.base, do: subscript_genericOpen)
                        }
                    }
                }
                """
            }
        }

        @Test func `Standard subscripts with varying modifiers`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    subscript() -> Any { get async }
                    subscript() -> Any { get throws }
                    subscript() -> Any { get async throws }
                    subscript() -> Any { get throws(any Error) }
                    subscript() -> Any { get throws(SomeError) }
                    subscript() -> Any { get throws(Never) }
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    subscript() -> Any { get async }
                    subscript() -> Any { get throws }
                    subscript() -> Any { get async throws }
                    subscript() -> Any { get throws(any Error) }
                    subscript() -> Any { get throws(SomeError) }
                    subscript() -> Any { get throws(Never) }
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    subscript() -> Any {
                        get async {
                            func subscript_genericOpen<T: Protocol>(_: T) async -> Any  {
                                var base: T {
                                    get {
                                        self.base as! T
                                    }
                                };
                                return await base[]
                            };
                            return await __implicitCast(_openExistential(self.base, do: subscript_genericOpen))
                        }
                    }
                    subscript() -> Any {
                        get throws {
                            func subscript_genericOpen<T: Protocol>(_: T) throws -> Any  {
                                var base: T {
                                    get {
                                        self.base as! T
                                    }
                                };
                                do {
                                    return try base[]
                                } catch let error {
                                    throw __implicitCast(error)
                                }
                            };
                            return try __implicitCast(_openExistential(self.base, do: subscript_genericOpen))
                        }
                    }
                    subscript() -> Any {
                        get async throws {
                            func subscript_genericOpen<T: Protocol>(_: T) async throws -> Any  {
                                var base: T {
                                    get {
                                        self.base as! T
                                    }
                                };
                                do {
                                    return try await base[]
                                } catch let error {
                                    throw __implicitCast(error)
                                }
                            };
                            return try await __implicitCast(_openExistential(self.base, do: subscript_genericOpen))
                        }
                    }
                    subscript() -> Any {
                        get throws(any Error) {
                            func subscript_genericOpen<T: Protocol>(_: T) throws(any Error) -> Any  {
                                var base: T {
                                    get {
                                        self.base as! T
                                    }
                                };
                                do {
                                    return try base[]
                                } catch let error {
                                    throw __implicitCast(error)
                                }
                            };
                            return try __implicitCast(_openExistential(self.base, do: subscript_genericOpen))
                        }
                    }
                    subscript() -> Any {
                        get throws(SomeError) {
                            func subscript_genericOpen<T: Protocol>(_: T) throws(SomeError) -> Any  {
                                var base: T {
                                    get {
                                        self.base as! T
                                    }
                                };
                                do {
                                    return try base[]
                                } catch let error {
                                    throw __implicitCast(error)
                                }
                            };
                            return try __implicitCast(_openExistential(self.base, do: subscript_genericOpen))
                        }
                    }
                    subscript() -> Any {
                        get throws(Never) {
                            func subscript_genericOpen<T: Protocol>(_: T) throws(Never) -> Any  {
                                var base: T {
                                    get {
                                        self.base as! T
                                    }
                                };
                                return base[]
                            };
                            return __implicitCast(_openExistential(self.base, do: subscript_genericOpen))
                        }
                    }
                }
                """
            }
        }

        @Test func `Standard subscripts with default specifiers`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @DefaultExternal(impl1) subscript() -> Any { get }
                    @DefaultType<Type> subscript() -> Any { get }
                    @DefaultValue(1) subscript() -> Any { get }
                    @DefaultNone subscript() -> Any { get }
                }
                """
            } diagnostics: {
                """
                @TypeErased
                protocol Protocol {
                    @DefaultExternal(impl1) subscript() -> Any { get }
                    @DefaultType<Type> subscript() -> Any { get }
                    ┬─────────────────
                    ╰─ 🛑 Only static requirements can have a default
                    @DefaultValue(1) subscript() -> Any { get }
                    ┬───────────────
                    ╰─ 🛑 Only static requirements can have a default
                    @DefaultNone subscript() -> Any { get }
                    ┬───────────
                    ╰─ 🛑 Only static requirements can have a default
                }
                """
            }
        }

        @Test func `Static non-marked subscript`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    static subscript() -> Any { get }
                }
                """
            } diagnostics: {
                """
                @TypeErased
                ┬──────────
                ╰─ 🛑 Type erased protocols can't have static requirements
                protocol Protocol {
                    static subscript() -> Any { get }
                }
                """
            }
        }

        @Test func `Static subscript with default value without setter`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @DefaultValue(1) static subscript() -> Any { get }
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    static subscript() -> Any { get }
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    static subscript() -> Any {
                        get {
                            __implicitCast(1)
                        }
                    }
                }
                """
            }
        }

        @Test func `Static subscript with default value with setter`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @DefaultValue(1) static subscript() -> Any { get set }
                }
                """
            } diagnostics: {
                """
                @TypeErased
                protocol Protocol {
                    @DefaultValue(1) static subscript() -> Any { get set }
                    ┬───────────────
                    ╰─ 🛑 This default doesn't support the use of set requirement
                }
                """
            }
        }

        @Test func `Static subscript with default type with varying parameter and input labels without setters`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @DefaultType<Type> static subscript() -> Any { get }
                    @DefaultType<Type> static subscript(label: Any) -> Any { get }
                    @DefaultType<Type> static subscript(_: Any) -> Any { get }
                    @DefaultType<Type> static subscript(label input: Any) -> Any { get }
                    @DefaultType<Type> static subscript(_ input: Any) -> Any { get }
                    @DefaultType<Type> static subscript(label _: Any) -> Any { get }
                    @DefaultType<Type> static subscript(_ _: Any) -> Any { get }
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    static subscript() -> Any { get }
                    static subscript(label: Any) -> Any { get }
                    static subscript(_: Any) -> Any { get }
                    static subscript(label input: Any) -> Any { get }
                    static subscript(_ input: Any) -> Any { get }
                    static subscript(label _: Any) -> Any { get }
                    static subscript(_ _: Any) -> Any { get }
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    static subscript() -> Any {
                        get {
                            __implicitCast(Type[])
                        }
                    }
                    static subscript(label: Any) -> Any {
                        get {
                            __implicitCast(Type[__implicitCast(label)])
                        }
                    }
                    static subscript(_ param0: Any) -> Any {
                        get {
                            __implicitCast(Type[__implicitCast(param0)])
                        }
                    }
                    static subscript(label input: Any) -> Any {
                        get {
                            __implicitCast(Type[label: __implicitCast(input)])
                        }
                    }
                    static subscript(_ input: Any) -> Any {
                        get {
                            __implicitCast(Type[__implicitCast(input)])
                        }
                    }
                    static subscript(label param0: Any) -> Any {
                        get {
                            __implicitCast(Type[label: __implicitCast(param0)])
                        }
                    }
                    static subscript(_ param0: Any) -> Any {
                        get {
                            __implicitCast(Type[__implicitCast(param0)])
                        }
                    }
                }
                """
            }
        }

        @Test func `Static subscript with default type with varying parameter and input labels with setters`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @DefaultType<Type> static subscript() -> Any { get set }
                    @DefaultType<Type> static subscript(label: Any) -> Any { get set }
                    @DefaultType<Type> static subscript(_: Any) -> Any { get set }
                    @DefaultType<Type> static subscript(label input: Any) -> Any { get set }
                    @DefaultType<Type> static subscript(_ input: Any) -> Any { get set }
                    @DefaultType<Type> static subscript(label _: Any) -> Any { get set }
                    @DefaultType<Type> static subscript(_ _: Any) -> Any { get set }
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    static subscript() -> Any { get set }
                    static subscript(label: Any) -> Any { get set }
                    static subscript(_: Any) -> Any { get set }
                    static subscript(label input: Any) -> Any { get set }
                    static subscript(_ input: Any) -> Any { get set }
                    static subscript(label _: Any) -> Any { get set }
                    static subscript(_ _: Any) -> Any { get set }
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    static subscript() -> Any {
                        get {
                            __implicitCast(Type[])
                        }
                        set {
                            Type[] = __implicitCast(newValue)
                        }
                    }
                    static subscript(label: Any) -> Any {
                        get {
                            __implicitCast(Type[__implicitCast(label)])
                        }
                        set {
                            Type[__implicitCast(label)] = __implicitCast(newValue)
                        }
                    }
                    static subscript(_ param0: Any) -> Any {
                        get {
                            __implicitCast(Type[__implicitCast(param0)])
                        }
                        set {
                            Type[__implicitCast(param0)] = __implicitCast(newValue)
                        }
                    }
                    static subscript(label input: Any) -> Any {
                        get {
                            __implicitCast(Type[label: __implicitCast(input)])
                        }
                        set {
                            Type[label: __implicitCast(input)] = __implicitCast(newValue)
                        }
                    }
                    static subscript(_ input: Any) -> Any {
                        get {
                            __implicitCast(Type[__implicitCast(input)])
                        }
                        set {
                            Type[__implicitCast(input)] = __implicitCast(newValue)
                        }
                    }
                    static subscript(label param0: Any) -> Any {
                        get {
                            __implicitCast(Type[label: __implicitCast(param0)])
                        }
                        set {
                            Type[label: __implicitCast(param0)] = __implicitCast(newValue)
                        }
                    }
                    static subscript(_ param0: Any) -> Any {
                        get {
                            __implicitCast(Type[__implicitCast(param0)])
                        }
                        set {
                            Type[__implicitCast(param0)] = __implicitCast(newValue)
                        }
                    }
                }
                """
            }
        }

        @Test func `Static subscript with default type with varying modifiers`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @DefaultType<Type> static subscript() -> Any { get async }
                    @DefaultType<Type> static subscript() -> Any { get throws }
                    @DefaultType<Type> static subscript() -> Any { get async throws }
                    @DefaultType<Type> static subscript() -> Any { get throws(any Error) }
                    @DefaultType<Type> static subscript() -> Any { get throws(SomeError) }
                    @DefaultType<Type> static subscript() -> Any { get throws(Never) }
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    static subscript() -> Any { get async }
                    static subscript() -> Any { get throws }
                    static subscript() -> Any { get async throws }
                    static subscript() -> Any { get throws(any Error) }
                    static subscript() -> Any { get throws(SomeError) }
                    static subscript() -> Any { get throws(Never) }
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    static subscript() -> Any {
                        get async {
                            await __implicitCast(Type[])
                        }
                    }
                    static subscript() -> Any {
                        get throws {
                            try __implicitCast(Type[])
                        }
                    }
                    static subscript() -> Any {
                        get async throws {
                            try await __implicitCast(Type[])
                        }
                    }
                    static subscript() -> Any {
                        get throws(any Error) {
                            try __implicitCast(Type[])
                        }
                    }
                    static subscript() -> Any {
                        get throws(SomeError) {
                            try __implicitCast(Type[])
                        }
                    }
                    static subscript() -> Any {
                        get throws(Never) {
                            try __implicitCast(Type[])
                        }
                    }
                }
                """
            }
        }

        @Test func `Static subscript with external default with varying parameter and input labels without setters`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @DefaultExternal(impl1) static subscript() -> Any { get }
                    @DefaultExternal(impl1) static subscript(label: Any) -> Any { get }
                    @DefaultExternal(impl1) static subscript(_: Any) -> Any { get }
                    @DefaultExternal(impl1) static subscript(label input: Any) -> Any { get }
                    @DefaultExternal(impl1) static subscript(_ input: Any) -> Any { get }
                    @DefaultExternal(impl1) static subscript(label _: Any) -> Any { get }
                    @DefaultExternal(impl1) static subscript(_ _: Any) -> Any { get }
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    @DefaultExternal(impl1) static subscript() -> Any { get }
                    @DefaultExternal(impl1) static subscript(label: Any) -> Any { get }
                    @DefaultExternal(impl1) static subscript(_: Any) -> Any { get }
                    @DefaultExternal(impl1) static subscript(label input: Any) -> Any { get }
                    @DefaultExternal(impl1) static subscript(_ input: Any) -> Any { get }
                    @DefaultExternal(impl1) static subscript(label _: Any) -> Any { get }
                    @DefaultExternal(impl1) static subscript(_ _: Any) -> Any { get }
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    static subscript() -> Any {
                        get {
                            __implicitCast(impl1())
                        }
                    }
                    static subscript(label: Any) -> Any {
                        get {
                            __implicitCast(impl1(label))
                        }
                    }
                    static subscript(_ param0: Any) -> Any {
                        get {
                            __implicitCast(impl1(param0))
                        }
                    }
                    static subscript(label input: Any) -> Any {
                        get {
                            __implicitCast(impl1(label: input))
                        }
                    }
                    static subscript(_ input: Any) -> Any {
                        get {
                            __implicitCast(impl1(input))
                        }
                    }
                    static subscript(label param0: Any) -> Any {
                        get {
                            __implicitCast(impl1(label: param0))
                        }
                    }
                    static subscript(_ param0: Any) -> Any {
                        get {
                            __implicitCast(impl1(param0))
                        }
                    }
                }
                """
            }
        }

        @Test func `Static subscript with over-parameterized external default with varying parameter and input labels without setters`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @DefaultExternal(impl1, impl2) static subscript() -> Any { get }
                    @DefaultExternal(impl1, impl2) static subscript(label: Any) -> Any { get }
                    @DefaultExternal(impl1, impl2) static subscript(_: Any) -> Any { get }
                    @DefaultExternal(impl1, impl2) static subscript(label input: Any) -> Any { get }
                    @DefaultExternal(impl1, impl2) static subscript(_ input: Any) -> Any { get }
                    @DefaultExternal(impl1, impl2) static subscript(label _: Any) -> Any { get }
                    @DefaultExternal(impl1, impl2) static subscript(_ _: Any) -> Any { get }
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    @DefaultExternal(impl1, impl2) static subscript() -> Any { get }
                    @DefaultExternal(impl1, impl2) static subscript(label: Any) -> Any { get }
                    @DefaultExternal(impl1, impl2) static subscript(_: Any) -> Any { get }
                    @DefaultExternal(impl1, impl2) static subscript(label input: Any) -> Any { get }
                    @DefaultExternal(impl1, impl2) static subscript(_ input: Any) -> Any { get }
                    @DefaultExternal(impl1, impl2) static subscript(label _: Any) -> Any { get }
                    @DefaultExternal(impl1, impl2) static subscript(_ _: Any) -> Any { get }
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    static subscript() -> Any {
                        get {
                            __implicitCast(impl1())
                        }
                    }
                    static subscript(label: Any) -> Any {
                        get {
                            __implicitCast(impl1(label))
                        }
                    }
                    static subscript(_ param0: Any) -> Any {
                        get {
                            __implicitCast(impl1(param0))
                        }
                    }
                    static subscript(label input: Any) -> Any {
                        get {
                            __implicitCast(impl1(label: input))
                        }
                    }
                    static subscript(_ input: Any) -> Any {
                        get {
                            __implicitCast(impl1(input))
                        }
                    }
                    static subscript(label param0: Any) -> Any {
                        get {
                            __implicitCast(impl1(label: param0))
                        }
                    }
                    static subscript(_ param0: Any) -> Any {
                        get {
                            __implicitCast(impl1(param0))
                        }
                    }
                }
                """
            }
        }

        @Test func `Static subscript with default with varying parameter and input labels with setters`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @DefaultExternal(impl1, impl2) static subscript() -> Any { get set }
                    @DefaultExternal(impl1, impl2) static subscript(label: Any) -> Any { get set }
                    @DefaultExternal(impl1, impl2) static subscript(_: Any) -> Any { get set }
                    @DefaultExternal(impl1, impl2) static subscript(label input: Any) -> Any { get set }
                    @DefaultExternal(impl1, impl2) static subscript(_ input: Any) -> Any { get set }
                    @DefaultExternal(impl1, impl2) static subscript(label _: Any) -> Any { get set }
                    @DefaultExternal(impl1, impl2) static subscript(_ _: Any) -> Any { get set }
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    @DefaultExternal(impl1, impl2) static subscript() -> Any { get set }
                    @DefaultExternal(impl1, impl2) static subscript(label: Any) -> Any { get set }
                    @DefaultExternal(impl1, impl2) static subscript(_: Any) -> Any { get set }
                    @DefaultExternal(impl1, impl2) static subscript(label input: Any) -> Any { get set }
                    @DefaultExternal(impl1, impl2) static subscript(_ input: Any) -> Any { get set }
                    @DefaultExternal(impl1, impl2) static subscript(label _: Any) -> Any { get set }
                    @DefaultExternal(impl1, impl2) static subscript(_ _: Any) -> Any { get set }
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    static subscript() -> Any {
                        get {
                            __implicitCast(impl1())
                        }
                        set {
                            __implicitCast(impl2(newValue, ))
                        }
                    }
                    static subscript(label: Any) -> Any {
                        get {
                            __implicitCast(impl1(label))
                        }
                        set {
                            __implicitCast(impl2(newValue, label))
                        }
                    }
                    static subscript(_ param0: Any) -> Any {
                        get {
                            __implicitCast(impl1(param0))
                        }
                        set {
                            __implicitCast(impl2(newValue, param0))
                        }
                    }
                    static subscript(label input: Any) -> Any {
                        get {
                            __implicitCast(impl1(label: input))
                        }
                        set {
                            __implicitCast(impl2(newValue, label: input))
                        }
                    }
                    static subscript(_ input: Any) -> Any {
                        get {
                            __implicitCast(impl1(input))
                        }
                        set {
                            __implicitCast(impl2(newValue, input))
                        }
                    }
                    static subscript(label param0: Any) -> Any {
                        get {
                            __implicitCast(impl1(label: param0))
                        }
                        set {
                            __implicitCast(impl2(newValue, label: param0))
                        }
                    }
                    static subscript(_ param0: Any) -> Any {
                        get {
                            __implicitCast(impl1(param0))
                        }
                        set {
                            __implicitCast(impl2(newValue, param0))
                        }
                    }
                }
                """
            }
        }

        @Test func `Static subscript with under-parametrized external default with varying parameter and input labels with setters`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @DefaultExternal(impl1) static subscript() -> Any { get set }
                    @DefaultExternal(impl1) static subscript(label: Any) -> Any { get set }
                    @DefaultExternal(impl1) static subscript(_: Any) -> Any { get set }
                    @DefaultExternal(impl1) static subscript(label input: Any) -> Any { get set }
                    @DefaultExternal(impl1) static subscript(_ input: Any) -> Any { get set }
                    @DefaultExternal(impl1) static subscript(label _: Any) -> Any { get set }
                    @DefaultExternal(impl1) static subscript(_ _: Any) -> Any { get set }
                }
                """
            } expansion: {
                #"""
                protocol Protocol {
                    @DefaultExternal(impl1) static subscript() -> Any { get set }
                    @DefaultExternal(impl1) static subscript(label: Any) -> Any { get set }
                    @DefaultExternal(impl1) static subscript(_: Any) -> Any { get set }
                    @DefaultExternal(impl1) static subscript(label input: Any) -> Any { get set }
                    @DefaultExternal(impl1) static subscript(_ input: Any) -> Any { get set }
                    @DefaultExternal(impl1) static subscript(label _: Any) -> Any { get set }
                    @DefaultExternal(impl1) static subscript(_ _: Any) -> Any { get set }
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    static subscript() -> Any {
                        get {
                            __implicitCast(impl1())
                        }
                        set {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                    }
                    static subscript(label: Any) -> Any {
                        get {
                            __implicitCast(impl1(label))
                        }
                        set {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                    }
                    static subscript(_ param0: Any) -> Any {
                        get {
                            __implicitCast(impl1(param0))
                        }
                        set {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                    }
                    static subscript(label input: Any) -> Any {
                        get {
                            __implicitCast(impl1(label: input))
                        }
                        set {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                    }
                    static subscript(_ input: Any) -> Any {
                        get {
                            __implicitCast(impl1(input))
                        }
                        set {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                    }
                    static subscript(label param0: Any) -> Any {
                        get {
                            __implicitCast(impl1(label: param0))
                        }
                        set {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                    }
                    static subscript(_ param0: Any) -> Any {
                        get {
                            __implicitCast(impl1(param0))
                        }
                        set {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                    }
                }
                """#
            }
        }

        @Test func `Static subscript with external default with varying modifiers`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @DefaultExternal(impl1) static subscript() -> Any { get async }
                    @DefaultExternal(impl1) static subscript() -> Any { get throws }
                    @DefaultExternal(impl1) static subscript() -> Any { get async throws }
                    @DefaultExternal(impl1) static subscript() -> Any { get throws(any Error) }
                    @DefaultExternal(impl1) static subscript() -> Any { get throws(SomeError) }
                    @DefaultExternal(impl1) static subscript() -> Any { get throws(Never) }
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    @DefaultExternal(impl1) static subscript() -> Any { get async }
                    @DefaultExternal(impl1) static subscript() -> Any { get throws }
                    @DefaultExternal(impl1) static subscript() -> Any { get async throws }
                    @DefaultExternal(impl1) static subscript() -> Any { get throws(any Error) }
                    @DefaultExternal(impl1) static subscript() -> Any { get throws(SomeError) }
                    @DefaultExternal(impl1) static subscript() -> Any { get throws(Never) }
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    static subscript() -> Any {
                        get async {
                            await __implicitCast(impl1())
                        }
                    }
                    static subscript() -> Any {
                        get throws {
                            try __implicitCast(impl1())
                        }
                    }
                    static subscript() -> Any {
                        get async throws {
                            try await __implicitCast(impl1())
                        }
                    }
                    static subscript() -> Any {
                        get throws(any Error) {
                            try __implicitCast(impl1())
                        }
                    }
                    static subscript() -> Any {
                        get throws(SomeError) {
                            try __implicitCast(impl1())
                        }
                    }
                    static subscript() -> Any {
                        get throws(Never) {
                            try __implicitCast(impl1())
                        }
                    }
                }
                """
            }
        }

        @Test func `Static subscript with no default`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @DefaultNone static subscript() -> Any { get }
                    @DefaultNone static subscript() -> Any { get set }
                }
                """
            } expansion: {
                #"""
                protocol Protocol {
                    static subscript() -> Any { get }
                    static subscript() -> Any { get set }
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    static subscript() -> Any {
                        get {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                    }
                    static subscript() -> Any {
                        get {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                        set {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                    }
                }
                """#
            }
        }
    }

    @Suite
    struct `Initializer Tests` {
        @Test func `Non-marked initializer`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    init()
                }
                """
            } diagnostics: {
                """
                @TypeErased
                ┬──────────
                ╰─ 🛑 Type erased protocols can't have static requirements
                protocol Protocol {
                    init()
                }
                """
            }
        }

        @Test func `Initializers with default type with varying parameter and input labels`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @DefaultType<Type> init()
                    @DefaultType<Type> init(label: Any)
                    @DefaultType<Type> init(_: Any)
                    @DefaultType<Type> init(label input: Any)
                    @DefaultType<Type> init(_ input: Any)
                    @DefaultType<Type> init(label _: Any)
                    @DefaultType<Type> init(_ _: Any)
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    init()
                    init(label: Any)
                    init(_: Any)
                    init(label input: Any)
                    init(_ input: Any)
                    init(label _: Any)
                    init(_ _: Any)
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    init() {
                        self.init(Type())
                    }
                    init(label: Any) {
                        self.init(Type(label: __implicitCast(label)))
                    }
                    init(_ param0: Any) {
                        self.init(Type(__implicitCast(param0)))
                    }
                    init(label input: Any) {
                        self.init(Type(label: __implicitCast(input)))
                    }
                    init(_ input: Any) {
                        self.init(Type(__implicitCast(input)))
                    }
                    init(label _: Any) {
                        self.init(Type(label: __implicitCast(label)))
                    }
                    init(_ param0: Any) {
                        self.init(Type(__implicitCast(param0)))
                    }
                }
                """
            }
        }

        @Test func `Initializers with default type with varying modifiers`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @DefaultType<Type> init() async
                    @DefaultType<Type> init() throws
                    @DefaultType<Type> init() async throws
                    @DefaultType<Type> init() throws(any Error)
                    @DefaultType<Type> init() throws(SomeError)
                    @DefaultType<Type> init() throws(Never)
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    init() async
                    init() throws
                    init() async throws
                    init() throws(any Error)
                    init() throws(SomeError)
                    init() throws(Never)
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    init() async {
                        await self.init(Type())
                    }
                    init() throws {
                        try self.init(Type())
                    }
                    init() async throws {
                        try await self.init(Type())
                    }
                    init() throws(any Error) {
                        try self.init(Type())
                    }
                    init() throws(SomeError) {
                        try self.init(Type())
                    }
                    init() throws(Never) {
                        self.init(Type())
                    }
                }
                """
            }
        }

        @Test func `Optional initializer with default type`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @DefaultType<Type> init?()
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    init?()
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    init?() {
                        self.init(Type())
                    }
                }
                """
            }
        }

        @Test func `Initializers with external default with varying parameter and input labels`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @DefaultExternal(impl1) init()
                    @DefaultExternal(impl1) init(label: Any)
                    @DefaultExternal(impl1) init(_: Any)
                    @DefaultExternal(impl1) init(label input: Any)
                    @DefaultExternal(impl1) init(_ input: Any)
                    @DefaultExternal(impl1) init(label _: Any)
                    @DefaultExternal(impl1) init(_ _: Any)
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    @DefaultExternal(impl1) init()
                    @DefaultExternal(impl1) init(label: Any)
                    @DefaultExternal(impl1) init(_: Any)
                    @DefaultExternal(impl1) init(label input: Any)
                    @DefaultExternal(impl1) init(_ input: Any)
                    @DefaultExternal(impl1) init(label _: Any)
                    @DefaultExternal(impl1) init(_ _: Any)
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    init() {
                        self = __implicitCast(impl1())
                    }
                    init(label: Any) {
                        self = __implicitCast(impl1(label: label))
                    }
                    init(_ param0: Any) {
                        self = __implicitCast(impl1(param0))
                    }
                    init(label input: Any) {
                        self = __implicitCast(impl1(label: input))
                    }
                    init(_ input: Any) {
                        self = __implicitCast(impl1(input))
                    }
                    init(label _: Any) {
                        self = __implicitCast(impl1(label: label))
                    }
                    init(_ param0: Any) {
                        self = __implicitCast(impl1(param0))
                    }
                }
                """
            }
        }

        @Test func `Initializers with external default with varying modifiers`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @DefaultExternal(impl1) init() async
                    @DefaultExternal(impl1) init() throws
                    @DefaultExternal(impl1) init() async throws
                    @DefaultExternal(impl1) init() throws(any Error)
                    @DefaultExternal(impl1) init() throws(SomeError)
                    @DefaultExternal(impl1) init() throws(Never)
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    @DefaultExternal(impl1) init() async
                    @DefaultExternal(impl1) init() throws
                    @DefaultExternal(impl1) init() async throws
                    @DefaultExternal(impl1) init() throws(any Error)
                    @DefaultExternal(impl1) init() throws(SomeError)
                    @DefaultExternal(impl1) init() throws(Never)
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    init() async {
                        self = __implicitCast(await impl1())
                    }
                    init() throws {
                        self = __implicitCast(try impl1())
                    }
                    init() async throws {
                        self = __implicitCast(try await impl1())
                    }
                    init() throws(any Error) {
                        self = __implicitCast(try impl1())
                    }
                    init() throws(SomeError) {
                        self = __implicitCast(try impl1())
                    }
                    init() throws(Never) {
                        self = __implicitCast(impl1())
                    }
                }
                """
            }
        }

        @Test func `Optional initializer with external default`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @DefaultExternal(impl1) init?()
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    @DefaultExternal(impl1) init?()
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    init?() {
                        if let value: Self = impl1() {
                            self = __implicitCast(value)
                        } else {
                            return nil
                        }
                    }
                }
                """
            }
        }

        @Test func `Initializer with default value`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @DefaultValue(1) init()
                }
                """
            } diagnostics: {
                """
                @TypeErased
                protocol Protocol {
                    @DefaultValue(1) init()
                    ┬───────────────
                    ╰─ 🛑 This macro isn't applicable to initializers and associated types
                }
                """
            }
        }

        @Test func `Initializer with no default`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @DefaultNone init()
                }
                """
            } expansion: {
                #"""
                protocol Protocol {
                    init()
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    init() {
                        fatalError("Tried to access static member \(#function) from type eraser")
                    }
                }
                """#
            }
        }
    }

    @Suite
    struct `Associated Tests` {
        @Test func `Associated with varying inheritance clauses with erasure type`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @ErasureType<Type> associatedtype T1
                    @ErasureType<Type> associatedtype T2: Interface
                    @ErasureType<Type> associatedtype T3: Interface, Protocol
                    @ErasureType<Type> associatedtype T4: Interface & Protocol
                    @ErasureType<Type> associatedtype T5: Interface & Protocol, Class
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    associatedtype T1
                    associatedtype T2: Interface
                    associatedtype T3: Interface, Protocol
                    associatedtype T4: Interface & Protocol
                    associatedtype T5: Interface & Protocol, Class
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    typealias T1 = Type
                    typealias T2 = Type
                    typealias T3 = Type
                    typealias T4 = Type
                    typealias T5 = Type
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }
                """
            }
        }

        @Test func `Non-marked associated`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    associatedtype T
                }
                """
            } diagnostics: {
                """
                @TypeErased
                ┬──────────
                ╰─ 🛑 Associated type 'T' must have a erasure specifier
                protocol Protocol {
                    associatedtype T
                }
                """
            }
        }

        @Test func `Associated with defaults`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    associatedtype T
                }
                """
            } diagnostics: {
                """
                @TypeErased
                ┬──────────
                ╰─ 🛑 Associated type 'T' must have a erasure specifier
                protocol Protocol {
                    associatedtype T
                }
                """
            }
        }
    }

    @Suite
    struct `Type Alias Tests` {
        @Test func `Type alias`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    typealias T = Int
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    typealias T = Int
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    typealias T = Int
                }
                """
            }
        }
    }

    @Suite
    struct `Automatic Conformance Generation Tests` {
        @Test func `Protocol with equatable conformance`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol: Equatable {}
                """
            } expansion: {
                """
                protocol Protocol: Equatable {}

                struct AnyProtocol: Protocol, TypeEraser {
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    static func == (left: Self, right: Self) -> Bool {
                        return _isEqual(lhs: left.base, rhs: right.base)
                    }
                    private static func _isEqual<T: Equatable, U: Equatable>(lhs: T, rhs: U) -> Bool {
                        if let rhsAsT = rhs as? T {
                            return lhs == rhsAsT
                        }
                        if let lhsAsU = lhs as? U {
                            return lhsAsU == rhs
                        }
                        return false
                    }
                }
                """
            }
        }

        @Test func `Protocol with hashable conformance`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol: Hashable {}
                """
            } expansion: {
                """
                protocol Protocol: Hashable {}

                struct AnyProtocol: Protocol, TypeEraser {
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    func hash(into hasher: inout Hasher) {
                        hasher.combine(base)
                    }
                    static func == (left: Self, right: Self) -> Bool {
                        return _isEqual(lhs: left.base, rhs: right.base)
                    }
                    private static func _isEqual<T: Equatable, U: Equatable>(lhs: T, rhs: U) -> Bool {
                        if let rhsAsT = rhs as? T {
                            return lhs == rhsAsT
                        }
                        if let lhsAsU = lhs as? U {
                            return lhsAsU == rhs
                        }
                        return false
                    }
                }
                """
            }
        }

        @Test func `Protocol with identifiable conformance without erasure specifier constraint`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol: Identifiable {}
                """
            } diagnostics: {
                """
                @TypeErased
                ┬──────────
                ╰─ 🛑 Associated type 'ID' must have a erasure specifier
                protocol Protocol: Identifiable {}
                """
            }
        }

        @Test func `Protocol with identifiable conformance with varying constraining methods`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol: Identifiable {
                    @ErasureType<AnyHashable>
                    associatedtype ID: Hashable
                }

                @TypeErased
                protocol Protocol: Identifiable where ID == Int {}

                @TypeErased
                protocol Protocol: Identifiable where Self.ID == Int {}

                @TypeErased
                protocol Protocol: Identifiable<Int> {}

                @TypeErased
                protocol Protocol: Identifiable {
                    var id: Int { get }
                }
                """
            } expansion: {
                """
                protocol Protocol: Identifiable {
                    associatedtype ID: Hashable
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    typealias ID = AnyHashable
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    var id: ID {
                        self.base.id
                    }
                }
                protocol Protocol: Identifiable where ID == Int {}

                struct AnyProtocol: Protocol, TypeEraser where ID == Int {
                    typealias ID = Int
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    var id: ID {
                        self.base.id
                    }
                }
                protocol Protocol: Identifiable where Self.ID == Int {}

                struct AnyProtocol: Protocol, TypeEraser where Self.ID == Int {
                    typealias ID = Int
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    var id: ID {
                        self.base.id
                    }
                }
                protocol Protocol: Identifiable<Int> {}

                struct AnyProtocol: Protocol, TypeEraser {
                    typealias ID = Int
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    var id: ID {
                        self.base.id
                    }
                }
                protocol Protocol: Identifiable {
                    var id: Int { get }
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    typealias ID = Int
                    var base: any Protocol
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    var id: Int {
                        get {
                            func id_genericOpen<T: Protocol>(_: T) -> Int  {
                                var base: T {
                                    get {
                                        self.base as! T
                                    }
                                };
                                return base.id
                            };
                            return __implicitCast(_openExistential(self.base, do: id_genericOpen))
                        }
                    }
                }
                """
            }
        }
    }
}

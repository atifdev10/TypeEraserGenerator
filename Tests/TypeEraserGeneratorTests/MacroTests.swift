import MacroTesting
import Testing

@Suite(.macros(testMacros))
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
                protocol Protocol {
                
                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
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
                protocol Protocol {
                
                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                @MainActor
                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }
                nonisolated
                protocol Protocol {
                
                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                nonisolated
                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
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
        @Test(.tags(.modifiers))
        func `Standard variables with varying modifiers`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    var variable: Any { get }
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
                    var variable: Any { get async }
                    var variable: Any { get throws }
                    var variable: Any { get async throws }
                    var variable: Any { get throws(any Error) }
                    var variable: Any { get throws(SomeError) }
                    var variable: Any { get throws(Never) }
                
                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    var variable: Any {
                        get {
                            func variable_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Any  {
                                var base: _OpenBase_ {
                                    get {
                                        self.base as! _OpenBase_
                                    }
                                };
                                return base.variable
                            };
                            return __implicitCast(_openExistential(self.base, do: variable_genericOpen))
                        }
                    }
                    var variable: Any {
                        get async {
                            func variable_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) async -> Any  {
                                var base: _OpenBase_ {
                                    get {
                                        self.base as! _OpenBase_
                                    }
                                };
                                return await base.variable
                            };
                            return await __implicitCast(_openExistential(self.base, do: variable_genericOpen))
                        }
                    }
                    var variable: Any {
                        get throws {
                            func variable_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) throws -> Any  {
                                var base: _OpenBase_ {
                                    get {
                                        self.base as! _OpenBase_
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
                            func variable_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) async throws -> Any  {
                                var base: _OpenBase_ {
                                    get {
                                        self.base as! _OpenBase_
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
                            func variable_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) throws(any Error) -> Any  {
                                var base: _OpenBase_ {
                                    get {
                                        self.base as! _OpenBase_
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
                            func variable_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) throws(SomeError) -> Any  {
                                var base: _OpenBase_ {
                                    get {
                                        self.base as! _OpenBase_
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
                            func variable_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) throws(Never) -> Any  {
                                var base: _OpenBase_ {
                                    get {
                                        self.base as! _OpenBase_
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

        @Test func `Standard variables with setter`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    var variable: Any { get set }
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    var variable: Any { get set }
                
                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    var variable: Any {
                        get {
                            func variable_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Any  {
                                var base: _OpenBase_ {
                                    get {
                                        self.base as! _OpenBase_
                                    }
                                };
                                return base.variable
                            };
                            return __implicitCast(_openExistential(self.base, do: variable_genericOpen))
                        }
                        set {
                            func variable_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) {
                                var base: _OpenBase_ {
                                    get {
                                        self.base as! _OpenBase_
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
                }
                """
            }
        }

        @Test(.tags(.default))
        func `Standard variables with default specifiers`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Default(.external) var variable: Any { get }
                    @Default(.type(Type.self)) var variable: Any { get }
                    @Default(.value(1)) var variable: Any { get }
                    @Default(.error) var variable: Any { get }
                }
                """
            } diagnostics: {
                """
                @TypeErased
                protocol Protocol {
                    @Default(.external) var variable: Any { get }
                    ┬──────────────────
                    ╰─ 🛑 Only static requirements can have a default
                    @Default(.type(Type.self)) var variable: Any { get }
                    ┬─────────────────────────
                    ╰─ 🛑 Only static requirements can have a default
                    @Default(.value(1)) var variable: Any { get }
                    ┬──────────────────
                    ╰─ 🛑 Only static requirements can have a default
                    @Default(.error) var variable: Any { get }
                    ┬───────────────
                    ╰─ 🛑 Only static requirements can have a default
                }
                """
            }
        }

        @Test(.tags(.modifiers, .option))
        func `Standard variables with assureNoAssociates flag with varying modifiers`() {
            assertMacro {
                """
                @TypeErased(options: .assureNoAssociates)
                protocol Protocol {
                    var variable: Any { get }
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
                    var variable: Any { get async }
                    var variable: Any { get throws }
                    var variable: Any { get async throws }
                    var variable: Any { get throws(any Error) }
                    var variable: Any { get throws(SomeError) }
                    var variable: Any { get throws(Never) }

                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    var variable: Any {
                        get {
                            base.variable
                        }
                    }
                    var variable: Any {
                        get async {
                            await base.variable
                        }
                    }
                    var variable: Any {
                        get throws {
                            try base.variable
                        }
                    }
                    var variable: Any {
                        get async throws {
                            try await base.variable
                        }
                    }
                    var variable: Any {
                        get throws(any Error) {
                            try base.variable
                        }
                    }
                    var variable: Any {
                        get throws(SomeError) {
                            try base.variable
                        }
                    }
                    var variable: Any {
                        get throws(Never) {
                            try base.variable
                        }
                    }
                }
                """
            }
        }

        @Test(.tags(.option))
        func `Standard variables with assureNoAssociates flag with setter`() {
            assertMacro {
                """
                @TypeErased(options: .assureNoAssociates)
                protocol Protocol {
                    var variable: Any { get set }
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    var variable: Any { get set }

                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    var variable: Any {
                        get {
                            base.variable
                        }
                        set {
                            base.variable = newValue
                        }
                    }
                }
                """
            }
        }

        @Test(.tags(.static))
        func `Static non-marked variable`() {
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

        @Test(.tags(.static, .default))
        func `Static variables without setter with default value`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Default(.value(1)) static var variable: Any { get }
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    static var variable: Any { get }
                
                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
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

        @Test(.tags(.static, .default))
        func `Static variable with setter and default value`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Default(.value(1)) static var variable: Any { get set }
                }
                """
            } expansion: {
                #"""
                protocol Protocol {
                    static var variable: Any { get set }

                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    static var variable: Any {
                        get {
                            __implicitCast(1)
                        }
                        set {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                    }
                }
                """#
            }
        }

        @Test(.tags(.static, .modifiers, .default))
        func `Static variables with varying modifiers with default type`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Default(.type(Type.self)) static var variable: Any { get }
                    @Default(.type(Type.self)) static var variable: Any { get async }
                    @Default(.type(Type.self)) static var variable: Any { get throws }
                    @Default(.type(Type.self)) static var variable: Any { get async throws }
                    @Default(.type(Type.self)) static var variable: Any { get throws(any Error) }
                    @Default(.type(Type.self)) static var variable: Any { get throws(URLError) }
                    @Default(.type(Type.self)) static var variable: Any { get throws(Never) }
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    static var variable: Any { get }
                    static var variable: Any { get async }
                    static var variable: Any { get throws }
                    static var variable: Any { get async throws }
                    static var variable: Any { get throws(any Error) }
                    static var variable: Any { get throws(URLError) }
                    static var variable: Any { get throws(Never) }
                
                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    static var variable: Any {
                        get {
                            __implicitCast(Type.variable)
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

        @Test(.tags(.static, .default))
        func `Static variables with default type with setter`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Default(.type(Type.self)) static var variable: Any { get set }
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    static var variable: Any { get set }
                
                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    static var variable: Any {
                        get {
                            __implicitCast(Type.variable)
                        }
                        set {
                            Type.variable = __implicitCast(newValue)
                        }
                    }
                }
                """
            }
        }

        @Test(.tags(.static, .default))
        func `Static variables with external default`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Default(.external) static var variable: Any { get }
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    static var variable: Any { get }
                
                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }
                """
            }
        }

        @Test(.tags(.static, .default))
        func `Static variables with no default`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Default(.error) static var variable: Any { get }
                    @Default(.error) static var variable: Any { get set }
                }
                """
            } expansion: {
                #"""
                protocol Protocol {
                    static var variable: Any { get }
                    static var variable: Any { get set }
                
                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
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

        @Test func `Static variables with exportStaticToObjectLevel flag`() {
            assertMacro {
                """
                @TypeErased(options: .exportStaticToObjectLevel)
                protocol Protocol {
                    @Default(.error) static var variable: Any { get }
                    @Default(.error) static var variable: Any { get set }
                    @Default(.error) static var variable: Any { get async }
                    @Default(.error) static var variable: Any { get throws }
                    @Default(.error) static var variable: Any { get async throws }
                    @Default(.error) static var variable: Any { get throws(any Error) }
                    @Default(.error) static var variable: Any { get throws(SomeError) }
                    @Default(.error) static var variable: Any { get throws(Never) }
                }
                """
            } expansion: {
                #"""
                protocol Protocol {
                    static var variable: Any { get }
                    static var variable: Any { get set }
                    static var variable: Any { get async }
                    static var variable: Any { get throws }
                    static var variable: Any { get async throws }
                    static var variable: Any { get throws(any Error) }
                    static var variable: Any { get throws(SomeError) }
                    static var variable: Any { get throws(Never) }

                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
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
                    static var variable: Any {
                        get async {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                    }
                    static var variable: Any {
                        get throws {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                    }
                    static var variable: Any {
                        get async throws {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                    }
                    static var variable: Any {
                        get throws(any Error) {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                    }
                    static var variable: Any {
                        get throws(SomeError) {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                    }
                    static var variable: Any {
                        get throws(Never) {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                    }
                }

                extension Protocol {
                    var variable: Any {
                        get {
                            __implicitCast(Self.variable)
                        }
                    }
                    var variable: Any {
                        get {
                            __implicitCast(Self.variable)
                        }
                        set {
                            Self.variable = __implicitCast(newValue)
                        }
                    }
                    var variable: Any {
                        get async {
                            await __implicitCast(Self.variable)
                        }
                    }
                    var variable: Any {
                        get throws {
                            try __implicitCast(Self.variable)
                        }
                    }
                    var variable: Any {
                        get async throws {
                            try await __implicitCast(Self.variable)
                        }
                    }
                    var variable: Any {
                        get throws(any Error) {
                            try __implicitCast(Self.variable)
                        }
                    }
                    var variable: Any {
                        get throws(SomeError) {
                            try __implicitCast(Self.variable)
                        }
                    }
                    var variable: Any {
                        get throws(Never) {
                            try __implicitCast(Self.variable)
                        }
                    }
                }
                """#
            }
        }
    }

    @Suite
    struct `Function Tests` {
        @Test(.tags(.parameters))
        func `Standard functions with varying parameter and input labels`() {
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
                
                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    func function() {
                        func function_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Void {
                            var base: _OpenBase_ {
                                get {
                                    self.base as! _OpenBase_
                                }
                            };
                            return base.function()
                        };
                        return __implicitCast(_openExistential(self.base, do: function_genericOpen))
                    }
                    func function(label: Any) {
                        func function_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Void {
                            var base: _OpenBase_ {
                                get {
                                    self.base as! _OpenBase_
                                }
                            };
                            return base.function(label: __implicitCast(label))
                        };
                        return __implicitCast(_openExistential(self.base, do: function_genericOpen))
                    }
                    func function(_ param0: Any) {
                        func function_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Void {
                            var base: _OpenBase_ {
                                get {
                                    self.base as! _OpenBase_
                                }
                            };
                            return base.function(__implicitCast(param0))
                        };
                        return __implicitCast(_openExistential(self.base, do: function_genericOpen))
                    }
                    func function(label input: Any) {
                        func function_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Void {
                            var base: _OpenBase_ {
                                get {
                                    self.base as! _OpenBase_
                                }
                            };
                            return base.function(label: __implicitCast(input))
                        };
                        return __implicitCast(_openExistential(self.base, do: function_genericOpen))
                    }
                    func function(_ input: Any) {
                        func function_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Void {
                            var base: _OpenBase_ {
                                get {
                                    self.base as! _OpenBase_
                                }
                            };
                            return base.function(__implicitCast(input))
                        };
                        return __implicitCast(_openExistential(self.base, do: function_genericOpen))
                    }
                    func function(label _: Any) {
                        func function_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Void {
                            var base: _OpenBase_ {
                                get {
                                    self.base as! _OpenBase_
                                }
                            };
                            return base.function(label: __implicitCast(label))
                        };
                        return __implicitCast(_openExistential(self.base, do: function_genericOpen))
                    }
                    func function(_ param0: Any) {
                        func function_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Void {
                            var base: _OpenBase_ {
                                get {
                                    self.base as! _OpenBase_
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

        @Test(.tags(.modifiers))
        func `Standard functions with varying modifiers`() {
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
                
                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    func function() async {
                        func function_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) async -> Void {
                            var base: _OpenBase_ {
                                get {
                                    self.base as! _OpenBase_
                                }
                            };
                            return await base.function()
                        };
                        return await __implicitCast(_openExistential(self.base, do: function_genericOpen))
                    }
                    func function() throws {
                        func function_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) throws -> Void {
                            var base: _OpenBase_ {
                                get {
                                    self.base as! _OpenBase_
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
                        func function_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) async throws -> Void {
                            var base: _OpenBase_ {
                                get {
                                    self.base as! _OpenBase_
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
                        func function_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) throws(any Error) -> Void {
                            var base: _OpenBase_ {
                                get {
                                    self.base as! _OpenBase_
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
                        func function_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) throws(SomeError) -> Void {
                            var base: _OpenBase_ {
                                get {
                                    self.base as! _OpenBase_
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
                        func function_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) throws(Never) -> Void {
                            var base: _OpenBase_ {
                                get {
                                    self.base as! _OpenBase_
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

        @Test(.tags(.default))
        func `Standard functions with default specifiers`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Default(.external) func function() -> Any
                    @Default(.type(Type.self)) func function() -> Any
                    @Default(.value(1)) func function() -> Any
                    @Default(.error) func function() -> Any
                }
                """
            } diagnostics: {
                """
                @TypeErased
                protocol Protocol {
                    @Default(.external) func function() -> Any
                    ┬──────────────────
                    ╰─ 🛑 Only static requirements can have a default
                    @Default(.type(Type.self)) func function() -> Any
                    ┬─────────────────────────
                    ╰─ 🛑 Only static requirements can have a default
                    @Default(.value(1)) func function() -> Any
                    ┬──────────────────
                    ╰─ 🛑 Only static requirements can have a default
                    @Default(.error) func function() -> Any
                    ┬───────────────
                    ╰─ 🛑 Only static requirements can have a default
                }
                """
            }
        }

        @Test(.tags(.option, .parameters))
        func `Standard functions with assureNoAssociates flag with varying parameter and input labels`() {
            assertMacro {
                """
                @TypeErased(options: .assureNoAssociates)
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

                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    func function() {
                        base.function()
                    }
                    func function(label: Any) {
                        base.function(label: label)
                    }
                    func function(_ param0: Any) {
                        base.function(param0)
                    }
                    func function(label input: Any) {
                        base.function(label: input)
                    }
                    func function(_ input: Any) {
                        base.function(input)
                    }
                    func function(label _: Any) {
                        base.function(label: label)
                    }
                    func function(_ param0: Any) {
                        base.function(param0)
                    }
                }
                """
            }
        }

        @Test(.tags(.option, .modifiers))
        func `Standard functions with assureNoAssociates flag with varying modifiers`() {
            assertMacro {
                """
                @TypeErased(options: .assureNoAssociates)
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

                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    func function() async {
                        await base.function()
                    }
                    func function() throws {
                        try base.function()
                    }
                    func function() async throws {
                        try await base.function()
                    }
                    func function() throws(any Error) {
                        try base.function()
                    }
                    func function() throws(SomeError) {
                        try base.function()
                    }
                    func function() throws(Never) {
                        base.function()
                    }
                }
                """
            }
        }

        @Test(.tags(.static))
        func `Static non-marked function`() {
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

        @Test(.tags(.static, .default))
        func `Static function with default value`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Default(.value(1)) static func function() -> Any
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    static func function() -> Any
                
                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    static func function() -> Any {
                        __implicitCast(1)
                    }
                }
                """
            }
        }

        @Test(.tags(.static, .parameters, .default))
        func `Static function with default type with varying parameter and input labels`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Default(.type(Type.self)) static func function()
                    @Default(.type(Type.self)) static func function(label: Any)
                    @Default(.type(Type.self)) static func function(_: Any)
                    @Default(.type(Type.self)) static func function(label input: Any)
                    @Default(.type(Type.self)) static func function(_ input: Any)
                    @Default(.type(Type.self)) static func function(label _: Any)
                    @Default(.type(Type.self)) static func function(_ _: Any)
                }
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
                
                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
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

        @Test(.tags(.static, .modifiers, .default))
        func `Static function with default type with varying modifiers`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Default(.type(Type.self)) static func function() async
                    @Default(.type(Type.self)) static func function() throws
                    @Default(.type(Type.self)) static func function() async throws
                    @Default(.type(Type.self)) static func function() throws(any Error)
                    @Default(.type(Type.self)) static func function() throws(SomeError)
                    @Default(.type(Type.self)) static func function() throws(Never)
                }
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
                
                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
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

        @Test(.tags(.static, .default))
        func `Static function with external default`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Default(.external) static func function()
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    static func function()
                
                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }
                """
            }
        }

        @Test(.tags(.static, .default))
        func `Static function with no default`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Default(.error) static func function()
                }
                """
            } expansion: {
                #"""
                protocol Protocol {
                    static func function()
                
                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
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

        @Test(.tags(.static, .option, .modifiers))
        func `Static function with exportStaticToObjectLevel flag with varying modifiers`() {
            assertMacro {
                """
                @TypeErased(options: .exportStaticToObjectLevel)
                protocol Protocol {
                    @Default(.error) static func function() async
                    @Default(.error) static func function() throws
                    @Default(.error) static func function() async throws
                    @Default(.error) static func function() throws(any Error)
                    @Default(.error) static func function() throws(SomeError)
                    @Default(.error) static func function() throws(Never)
                }
                """
            } expansion: {
                #"""
                protocol Protocol {
                    static func function() async
                    static func function() throws
                    static func function() async throws
                    static func function() throws(any Error)
                    static func function() throws(SomeError)
                    static func function() throws(Never)

                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    static func function() async {
                        fatalError("Tried to access static member \(#function) from type eraser")
                    }
                    static func function() throws {
                        fatalError("Tried to access static member \(#function) from type eraser")
                    }
                    static func function() async throws {
                        fatalError("Tried to access static member \(#function) from type eraser")
                    }
                    static func function() throws(any Error) {
                        fatalError("Tried to access static member \(#function) from type eraser")
                    }
                    static func function() throws(SomeError) {
                        fatalError("Tried to access static member \(#function) from type eraser")
                    }
                    static func function() throws(Never) {
                        fatalError("Tried to access static member \(#function) from type eraser")
                    }
                }

                extension Protocol {
                    func function() async {
                        await __implicitCast(Self.function())
                    }
                    func function() throws {
                        try __implicitCast(Self.function())
                    }
                    func function() async throws {
                        try await __implicitCast(Self.function())
                    }
                    func function() throws(any Error) {
                        try __implicitCast(Self.function())
                    }
                    func function() throws(SomeError) {
                        try __implicitCast(Self.function())
                    }
                    func function() throws(Never) {
                        __implicitCast(Self.function())
                    }
                }
                """#
            }
        }

        @Test(.tags(.static, .option, .parameters))
        func `Static function with exportStaticToObjectLevel flag with varying parameter and input labels`() {
            assertMacro {
                """
                @TypeErased(options: .exportStaticToObjectLevel)
                protocol Protocol {
                    @Default(.error) static func function()
                    @Default(.error) static func function(label: Any)
                    @Default(.error) static func function(_: Any)
                    @Default(.error) static func function(label input: Any)
                    @Default(.error) static func function(_ input: Any)
                    @Default(.error) static func function(label _: Any)
                    @Default(.error) static func function(_ _: Any)
                }
                """
            } expansion: {
                #"""
                protocol Protocol {
                    static func function()
                    static func function(label: Any)
                    static func function(_: Any)
                    static func function(label input: Any)
                    static func function(_ input: Any)
                    static func function(label _: Any)
                    static func function(_ _: Any)

                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    static func function() {
                        fatalError("Tried to access static member \(#function) from type eraser")
                    }
                    static func function(label: Any) {
                        fatalError("Tried to access static member \(#function) from type eraser")
                    }
                    static func function(_ param0: Any) {
                        fatalError("Tried to access static member \(#function) from type eraser")
                    }
                    static func function(label input: Any) {
                        fatalError("Tried to access static member \(#function) from type eraser")
                    }
                    static func function(_ input: Any) {
                        fatalError("Tried to access static member \(#function) from type eraser")
                    }
                    static func function(label _: Any) {
                        fatalError("Tried to access static member \(#function) from type eraser")
                    }
                    static func function(_ param0: Any) {
                        fatalError("Tried to access static member \(#function) from type eraser")
                    }
                }

                extension Protocol {
                    func function() {
                        __implicitCast(Self.function())
                    }
                    func function(label: Any) {
                        __implicitCast(Self.function(label: __implicitCast(label)))
                    }
                    func function(_ param0: Any) {
                        __implicitCast(Self.function(__implicitCast(param0)))
                    }
                    func function(label input: Any) {
                        __implicitCast(Self.function(label: __implicitCast(input)))
                    }
                    func function(_ input: Any) {
                        __implicitCast(Self.function(__implicitCast(input)))
                    }
                    func function(label _: Any) {
                        __implicitCast(Self.function(label: __implicitCast(label)))
                    }
                    func function(_ param0: Any) {
                        __implicitCast(Self.function(__implicitCast(param0)))
                    }
                }
                """#
            }
        }
    }

    @Suite
    struct `Subscript Tests` {
        @Test(.tags(.parameters))
        func `Standard subscripts with varying parameter and input labels without setters`() {
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
                
                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    subscript() -> Any {
                        get {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Any  {
                                var base: _OpenBase_ {
                                    get {
                                        self.base as! _OpenBase_
                                    }
                                };
                                return base[]
                            };
                            return __implicitCast(_openExistential(self.base, do: subscript_genericOpen))
                        }
                    }
                    subscript(label: Any) -> Any {
                        get {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Any  {
                                var base: _OpenBase_ {
                                    get {
                                        self.base as! _OpenBase_
                                    }
                                };
                                return base[__implicitCast(label)]
                            };
                            return __implicitCast(_openExistential(self.base, do: subscript_genericOpen))
                        }
                    }
                    subscript(_ param0: Any) -> Any {
                        get {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Any  {
                                var base: _OpenBase_ {
                                    get {
                                        self.base as! _OpenBase_
                                    }
                                };
                                return base[__implicitCast(param0)]
                            };
                            return __implicitCast(_openExistential(self.base, do: subscript_genericOpen))
                        }
                    }
                    subscript(label input: Any) -> Any {
                        get {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Any  {
                                var base: _OpenBase_ {
                                    get {
                                        self.base as! _OpenBase_
                                    }
                                };
                                return base[label: __implicitCast(input)]
                            };
                            return __implicitCast(_openExistential(self.base, do: subscript_genericOpen))
                        }
                    }
                    subscript(_ input: Any) -> Any {
                        get {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Any  {
                                var base: _OpenBase_ {
                                    get {
                                        self.base as! _OpenBase_
                                    }
                                };
                                return base[__implicitCast(input)]
                            };
                            return __implicitCast(_openExistential(self.base, do: subscript_genericOpen))
                        }
                    }
                    subscript(label param0: Any) -> Any {
                        get {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Any  {
                                var base: _OpenBase_ {
                                    get {
                                        self.base as! _OpenBase_
                                    }
                                };
                                return base[label: __implicitCast(param0)]
                            };
                            return __implicitCast(_openExistential(self.base, do: subscript_genericOpen))
                        }
                    }
                    subscript(_ param0: Any) -> Any {
                        get {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Any  {
                                var base: _OpenBase_ {
                                    get {
                                        self.base as! _OpenBase_
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

        @Test(.tags(.parameters))
        func `Standard subscripts with varying parameter and input labels with setters`() {
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
                
                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    subscript() -> Any {
                        get {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Any  {
                                var base: _OpenBase_ {
                                    get {
                                        self.base as! _OpenBase_
                                    }
                                };
                                return base[]
                            };
                            return __implicitCast(_openExistential(self.base, do: subscript_genericOpen))
                        }
                        set {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) {
                                var base: _OpenBase_ {
                                    get {
                                        self.base as! _OpenBase_
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
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Any  {
                                var base: _OpenBase_ {
                                    get {
                                        self.base as! _OpenBase_
                                    }
                                };
                                return base[__implicitCast(label)]
                            };
                            return __implicitCast(_openExistential(self.base, do: subscript_genericOpen))
                        }
                        set {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) {
                                var base: _OpenBase_ {
                                    get {
                                        self.base as! _OpenBase_
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
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Any  {
                                var base: _OpenBase_ {
                                    get {
                                        self.base as! _OpenBase_
                                    }
                                };
                                return base[__implicitCast(param0)]
                            };
                            return __implicitCast(_openExistential(self.base, do: subscript_genericOpen))
                        }
                        set {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) {
                                var base: _OpenBase_ {
                                    get {
                                        self.base as! _OpenBase_
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
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Any  {
                                var base: _OpenBase_ {
                                    get {
                                        self.base as! _OpenBase_
                                    }
                                };
                                return base[label: __implicitCast(input)]
                            };
                            return __implicitCast(_openExistential(self.base, do: subscript_genericOpen))
                        }
                        set {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) {
                                var base: _OpenBase_ {
                                    get {
                                        self.base as! _OpenBase_
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
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Any  {
                                var base: _OpenBase_ {
                                    get {
                                        self.base as! _OpenBase_
                                    }
                                };
                                return base[__implicitCast(input)]
                            };
                            return __implicitCast(_openExistential(self.base, do: subscript_genericOpen))
                        }
                        set {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) {
                                var base: _OpenBase_ {
                                    get {
                                        self.base as! _OpenBase_
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
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Any  {
                                var base: _OpenBase_ {
                                    get {
                                        self.base as! _OpenBase_
                                    }
                                };
                                return base[label: __implicitCast(param0)]
                            };
                            return __implicitCast(_openExistential(self.base, do: subscript_genericOpen))
                        }
                        set {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) {
                                var base: _OpenBase_ {
                                    get {
                                        self.base as! _OpenBase_
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
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Any  {
                                var base: _OpenBase_ {
                                    get {
                                        self.base as! _OpenBase_
                                    }
                                };
                                return base[__implicitCast(param0)]
                            };
                            return __implicitCast(_openExistential(self.base, do: subscript_genericOpen))
                        }
                        set {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) {
                                var base: _OpenBase_ {
                                    get {
                                        self.base as! _OpenBase_
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

        @Test(.tags(.modifiers))
        func `Standard subscripts with varying modifiers`() {
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
                
                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    subscript() -> Any {
                        get async {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) async -> Any  {
                                var base: _OpenBase_ {
                                    get {
                                        self.base as! _OpenBase_
                                    }
                                };
                                return await base[]
                            };
                            return await __implicitCast(_openExistential(self.base, do: subscript_genericOpen))
                        }
                    }
                    subscript() -> Any {
                        get throws {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) throws -> Any  {
                                var base: _OpenBase_ {
                                    get {
                                        self.base as! _OpenBase_
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
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) async throws -> Any  {
                                var base: _OpenBase_ {
                                    get {
                                        self.base as! _OpenBase_
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
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) throws(any Error) -> Any  {
                                var base: _OpenBase_ {
                                    get {
                                        self.base as! _OpenBase_
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
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) throws(SomeError) -> Any  {
                                var base: _OpenBase_ {
                                    get {
                                        self.base as! _OpenBase_
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
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) throws(Never) -> Any  {
                                var base: _OpenBase_ {
                                    get {
                                        self.base as! _OpenBase_
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

        @Test(.tags(.default))
        func `Standard subscripts with default specifiers`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Default(.external) subscript() -> Any { get }
                    @Default(.type(Type.self)) subscript() -> Any { get }
                    @Default(.value(1)) subscript() -> Any { get }
                    @Default(.error) subscript() -> Any { get }
                }
                """
            } diagnostics: {
                """
                @TypeErased
                protocol Protocol {
                    @Default(.external) subscript() -> Any { get }
                    ┬──────────────────
                    ╰─ 🛑 Only static requirements can have a default
                    @Default(.type(Type.self)) subscript() -> Any { get }
                    ┬─────────────────────────
                    ╰─ 🛑 Only static requirements can have a default
                    @Default(.value(1)) subscript() -> Any { get }
                    ┬──────────────────
                    ╰─ 🛑 Only static requirements can have a default
                    @Default(.error) subscript() -> Any { get }
                    ┬───────────────
                    ╰─ 🛑 Only static requirements can have a default
                }
                """
            }
        }

        @Test(.tags(.option, .parameters))
        func `Standard subscripts with assureNoAssociates flag with varying parameter and input labels without setters`() {
            assertMacro {
                """
                @TypeErased(options: .assureNoAssociates)
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

                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    subscript() -> Any {
                        get {
                            base[]
                        }
                    }
                    subscript(label: Any) -> Any {
                        get {
                            base[label]
                        }
                    }
                    subscript(_ param0: Any) -> Any {
                        get {
                            base[param0]
                        }
                    }
                    subscript(label input: Any) -> Any {
                        get {
                            base[label: input]
                        }
                    }
                    subscript(_ input: Any) -> Any {
                        get {
                            base[input]
                        }
                    }
                    subscript(label param0: Any) -> Any {
                        get {
                            base[label: param0]
                        }
                    }
                    subscript(_ param0: Any) -> Any {
                        get {
                            base[param0]
                        }
                    }
                }
                """
            }
        }

        @Test(.tags(.option, .parameters))
        func `Standard subscripts with assureNoAssociates flag with varying parameter and input labels with setters`() {
            assertMacro {
                """
                @TypeErased(options: .assureNoAssociates)
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

                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    subscript() -> Any {
                        get {
                            base[]
                        }
                        set {
                            base[] = newValue
                        }
                    }
                    subscript(label: Any) -> Any {
                        get {
                            base[label]
                        }
                        set {
                            base[label] = newValue
                        }
                    }
                    subscript(_ param0: Any) -> Any {
                        get {
                            base[param0]
                        }
                        set {
                            base[param0] = newValue
                        }
                    }
                    subscript(label input: Any) -> Any {
                        get {
                            base[label: input]
                        }
                        set {
                            base[label: input] = newValue
                        }
                    }
                    subscript(_ input: Any) -> Any {
                        get {
                            base[input]
                        }
                        set {
                            base[input] = newValue
                        }
                    }
                    subscript(label param0: Any) -> Any {
                        get {
                            base[label: param0]
                        }
                        set {
                            base[label: param0] = newValue
                        }
                    }
                    subscript(_ param0: Any) -> Any {
                        get {
                            base[param0]
                        }
                        set {
                            base[param0] = newValue
                        }
                    }
                }
                """
            }
        }

        @Test(.tags(.static, .modifiers))
        func `Standard subscripts with assureNoAssociates flag with varying modifiers`() {
            assertMacro {
                """
                @TypeErased(options: .assureNoAssociates)
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

                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    subscript() -> Any {
                        get async {
                            await base[]
                        }
                    }
                    subscript() -> Any {
                        get throws {
                            try base[]
                        }
                    }
                    subscript() -> Any {
                        get async throws {
                            try await base[]
                        }
                    }
                    subscript() -> Any {
                        get throws(any Error) {
                            try base[]
                        }
                    }
                    subscript() -> Any {
                        get throws(SomeError) {
                            try base[]
                        }
                    }
                    subscript() -> Any {
                        get throws(Never) {
                            try base[]
                        }
                    }
                }
                """
            }
        }

        @Test(.tags(.static))
        func `Static non-marked subscript`() {
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

        @Test(.tags(.static, .default))
        func `Static subscript with default value without setter`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Default(.value(1)) static subscript() -> Any { get }
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    static subscript() -> Any { get }
                
                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
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

        @Test(.tags(.static, .default))
        func `Static subscript with default value with setter`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Default(.value(1)) static subscript() -> Any { get set }
                }
                """
            } expansion: {
                #"""
                protocol Protocol {
                    static subscript() -> Any { get set }

                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    static subscript() -> Any {
                        get {
                            __implicitCast(1)
                        }
                        set {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                    }
                }
                """#
            }
        }

        @Test(.tags(.static, .parameters, .default))
        func `Static subscript with default type with varying parameter and input labels without setters`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Default(.type(Type.self)) static subscript() -> Any { get }
                    @Default(.type(Type.self)) static subscript(label: Any) -> Any { get }
                    @Default(.type(Type.self)) static subscript(_: Any) -> Any { get }
                    @Default(.type(Type.self)) static subscript(label input: Any) -> Any { get }
                    @Default(.type(Type.self)) static subscript(_ input: Any) -> Any { get }
                    @Default(.type(Type.self)) static subscript(label _: Any) -> Any { get }
                    @Default(.type(Type.self)) static subscript(_ _: Any) -> Any { get }
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
                
                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
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

        @Test(.tags(.static, .parameters, .default))
        func `Static subscript with default type with varying parameter and input labels with setters`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Default(.type(Type.self)) static subscript() -> Any { get set }
                    @Default(.type(Type.self)) static subscript(label: Any) -> Any { get set }
                    @Default(.type(Type.self)) static subscript(_: Any) -> Any { get set }
                    @Default(.type(Type.self)) static subscript(label input: Any) -> Any { get set }
                    @Default(.type(Type.self)) static subscript(_ input: Any) -> Any { get set }
                    @Default(.type(Type.self)) static subscript(label _: Any) -> Any { get set }
                    @Default(.type(Type.self)) static subscript(_ _: Any) -> Any { get set }
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
                
                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
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

        @Test(.tags(.static, .modifiers, .default))
        func `Static subscript with default type with varying modifiers`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Default(.type(Type.self)) static subscript() -> Any { get async }
                    @Default(.type(Type.self)) static subscript() -> Any { get throws }
                    @Default(.type(Type.self)) static subscript() -> Any { get async throws }
                    @Default(.type(Type.self)) static subscript() -> Any { get throws(any Error) }
                    @Default(.type(Type.self)) static subscript() -> Any { get throws(SomeError) }
                    @Default(.type(Type.self)) static subscript() -> Any { get throws(Never) }
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
                
                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
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

        @Test(.tags(.static, .default))
        func `Static subscript with external default`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Default(.external) static subscript() -> Any { get }
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    static subscript() -> Any { get }
                
                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }
                """
            }
        }

        @Test(.tags(.static, .default))
        func `Static subscripts with no default`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Default(.error) static subscript() -> Any { get }
                    @Default(.error) static subscript() -> Any { get set }
                }
                """
            } expansion: {
                #"""
                protocol Protocol {
                    static subscript() -> Any { get }
                    static subscript() -> Any { get set }
                
                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
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

        @Test(.tags(.static, .option, .parameters))
        func `Static subscripts with exportStaticToObjectLevel flag with varying parameter and input labels without setters`() {
            assertMacro {
                """
                @TypeErased(options: .exportStaticToObjectLevel)
                protocol Protocol {
                    @Default(.none) static subscript() -> Any { get }
                    @Default(.none) static subscript(label: Any) -> Any { get }
                    @Default(.none) static subscript(_: Any) -> Any { get }
                    @Default(.none) static subscript(label input: Any) -> Any { get }
                    @Default(.none) static subscript(_ input: Any) -> Any { get }
                    @Default(.none) static subscript(label _: Any) -> Any { get }
                    @Default(.none) static subscript(_ _: Any) -> Any { get }
                }
                """
            } expansion: {
                #"""
                protocol Protocol {
                    static subscript() -> Any { get }
                    static subscript(label: Any) -> Any { get }
                    static subscript(_: Any) -> Any { get }
                    static subscript(label input: Any) -> Any { get }
                    static subscript(_ input: Any) -> Any { get }
                    static subscript(label _: Any) -> Any { get }
                    static subscript(_ _: Any) -> Any { get }

                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    static subscript() -> Any {
                        get {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                    }
                    static subscript(label: Any) -> Any {
                        get {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                    }
                    static subscript(_ param0: Any) -> Any {
                        get {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                    }
                    static subscript(label input: Any) -> Any {
                        get {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                    }
                    static subscript(_ input: Any) -> Any {
                        get {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                    }
                    static subscript(label param0: Any) -> Any {
                        get {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                    }
                    static subscript(_ param0: Any) -> Any {
                        get {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                    }
                }

                extension Protocol {
                    subscript() -> Any {
                        get {
                            Self[]
                        }
                    }
                    subscript(label: Any) -> Any {
                        get {
                            Self[__implicitCast(label)]
                        }
                    }
                    subscript(_ param0: Any) -> Any {
                        get {
                            Self[__implicitCast(param0)]
                        }
                    }
                    subscript(label input: Any) -> Any {
                        get {
                            Self[label: __implicitCast(input)]
                        }
                    }
                    subscript(_ input: Any) -> Any {
                        get {
                            Self[__implicitCast(input)]
                        }
                    }
                    subscript(label param0: Any) -> Any {
                        get {
                            Self[label: __implicitCast(param0)]
                        }
                    }
                    subscript(_ param0: Any) -> Any {
                        get {
                            Self[__implicitCast(param0)]
                        }
                    }
                }
                """#
            }
        }

        @Test(.tags(.static, .option, .parameters))
        func `Static subscripts with exportStaticToObjectLevel flag with varying parameter and input labels with setters`() {
            assertMacro {
                """
                @TypeErased(options: .exportStaticToObjectLevel)
                protocol Protocol {
                    @Default(.none) static subscript() -> Any { get set }
                    @Default(.none) static subscript(label: Any) -> Any { get set }
                    @Default(.none) static subscript(_: Any) -> Any { get set }
                    @Default(.none) static subscript(label input: Any) -> Any { get set }
                    @Default(.none) static subscript(_ input: Any) -> Any { get set }
                    @Default(.none) static subscript(label _: Any) -> Any { get set }
                    @Default(.none) static subscript(_ _: Any) -> Any { get set }
                }
                """
            } expansion: {
                #"""
                protocol Protocol {
                    static subscript() -> Any { get set }
                    static subscript(label: Any) -> Any { get set }
                    static subscript(_: Any) -> Any { get set }
                    static subscript(label input: Any) -> Any { get set }
                    static subscript(_ input: Any) -> Any { get set }
                    static subscript(label _: Any) -> Any { get set }
                    static subscript(_ _: Any) -> Any { get set }

                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    static subscript() -> Any {
                        get {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                        set {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                    }
                    static subscript(label: Any) -> Any {
                        get {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                        set {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                    }
                    static subscript(_ param0: Any) -> Any {
                        get {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                        set {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                    }
                    static subscript(label input: Any) -> Any {
                        get {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                        set {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                    }
                    static subscript(_ input: Any) -> Any {
                        get {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                        set {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                    }
                    static subscript(label param0: Any) -> Any {
                        get {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                        set {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                    }
                    static subscript(_ param0: Any) -> Any {
                        get {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                        set {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                    }
                }

                extension Protocol {
                    subscript() -> Any {
                        get {
                            Self[]
                        }
                        set {
                            Self[] = __implicitCast(newValue)
                        }
                    }
                    subscript(label: Any) -> Any {
                        get {
                            Self[__implicitCast(label)]
                        }
                        set {
                            Self[__implicitCast(label)] = __implicitCast(newValue)
                        }
                    }
                    subscript(_ param0: Any) -> Any {
                        get {
                            Self[__implicitCast(param0)]
                        }
                        set {
                            Self[__implicitCast(param0)] = __implicitCast(newValue)
                        }
                    }
                    subscript(label input: Any) -> Any {
                        get {
                            Self[label: __implicitCast(input)]
                        }
                        set {
                            Self[label: __implicitCast(input)] = __implicitCast(newValue)
                        }
                    }
                    subscript(_ input: Any) -> Any {
                        get {
                            Self[__implicitCast(input)]
                        }
                        set {
                            Self[__implicitCast(input)] = __implicitCast(newValue)
                        }
                    }
                    subscript(label param0: Any) -> Any {
                        get {
                            Self[label: __implicitCast(param0)]
                        }
                        set {
                            Self[label: __implicitCast(param0)] = __implicitCast(newValue)
                        }
                    }
                    subscript(_ param0: Any) -> Any {
                        get {
                            Self[__implicitCast(param0)]
                        }
                        set {
                            Self[__implicitCast(param0)] = __implicitCast(newValue)
                        }
                    }
                }
                """#
            }
        }

        @Test(.tags(.static, .option, .modifiers))
        func `Static subscripts with exportStaticToObjectLevel flag with varying modifiers`() {
            assertMacro {
                """
                @TypeErased(options: .exportStaticToObjectLevel)
                protocol Protocol {
                    @Default(.none) static subscript() -> Any { get async }
                    @Default(.none) static subscript() -> Any { get throws }
                    @Default(.none) static subscript() -> Any { get async throws }
                    @Default(.none) static subscript() -> Any { get throws(any Error) }
                    @Default(.none) static subscript() -> Any { get throws(SomeError) }
                    @Default(.none) static subscript() -> Any { get throws(Never) }
                }
                """
            } expansion: {
                #"""
                protocol Protocol {
                    static subscript() -> Any { get async }
                    static subscript() -> Any { get throws }
                    static subscript() -> Any { get async throws }
                    static subscript() -> Any { get throws(any Error) }
                    static subscript() -> Any { get throws(SomeError) }
                    static subscript() -> Any { get throws(Never) }

                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    static subscript() -> Any {
                        get async {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                    }
                    static subscript() -> Any {
                        get throws {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                    }
                    static subscript() -> Any {
                        get async throws {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                    }
                    static subscript() -> Any {
                        get throws(any Error) {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                    }
                    static subscript() -> Any {
                        get throws(SomeError) {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                    }
                    static subscript() -> Any {
                        get throws(Never) {
                            fatalError("Tried to access static member \(#function) from type eraser")
                        }
                    }
                }

                extension Protocol {
                    subscript() -> Any {
                        get async {
                            await Self[]
                        }
                    }
                    subscript() -> Any {
                        get throws {
                            try Self[]
                        }
                    }
                    subscript() -> Any {
                        get async throws {
                            try await Self[]
                        }
                    }
                    subscript() -> Any {
                        get throws(any Error) {
                            try Self[]
                        }
                    }
                    subscript() -> Any {
                        get throws(SomeError) {
                            try Self[]
                        }
                    }
                    subscript() -> Any {
                        get throws(Never) {
                            try Self[]
                        }
                    }
                }
                """#
            }
        }
    }

    @Suite(.tags(.static))
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

        @Test(.tags(.parameters, .default))
        func `Initializers with default type with varying parameter and input labels`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Default(.type(Type.self)) init()
                    @Default(.type(Type.self)) init(label: Any)
                    @Default(.type(Type.self)) init(_: Any)
                    @Default(.type(Type.self)) init(label input: Any)
                    @Default(.type(Type.self)) init(_ input: Any)
                    @Default(.type(Type.self)) init(label _: Any)
                    @Default(.type(Type.self)) init(_ _: Any)
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
                
                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
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

        @Test(.tags(.modifiers, .default))
        func `Initializers with default type with varying modifiers`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Default(.type(Type.self)) init() async
                    @Default(.type(Type.self)) init() throws
                    @Default(.type(Type.self)) init() async throws
                    @Default(.type(Type.self)) init() throws(any Error)
                    @Default(.type(Type.self)) init() throws(SomeError)
                    @Default(.type(Type.self)) init() throws(Never)
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
                
                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
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

        @Test(.tags(.default))
        func `Optional initializer with default type`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Default(.type(Type.self)) init?()
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    init?()

                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    init?() {
                        guard let type = Type() else {
                            return nil
                        };
                        self.init(type)
                    }
                }
                """
            }
        }

        @Test(.tags(.default))
        func `Initializer with external default`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Default(.external) init()
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    init()
                
                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }
                
                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }
                """
            }
        }

        @Test(.tags(.default))
        func `Initializer with no default`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Default(.error) init()
                }
                """
            } expansion: {
                #"""
                protocol Protocol {
                    init()
                
                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
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

    @Suite(.tags(.static))
    struct `Associated Tests` {
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

        @Test(.tags(.erase))
        func `Associated with varying inheritance clauses with explicit erasure type`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Erase<Type> associatedtype T1
                    @Erase<Type> associatedtype T2: Interface
                    @Erase<Type> associatedtype T3: Interface, Protocol
                    @Erase<Type> associatedtype T4: Interface & Protocol
                    @Erase<Type> associatedtype T5: Interface & Protocol, Class
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
                
                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    typealias T1 = Type
                    typealias T2 = Type
                    typealias T3 = Type
                    typealias T4 = Type
                    typealias T5 = Type
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }
                """
            }
        }

        @Test(.tags(.erase))
        func `Associated with varying inheritance clauses with implicit erasure type`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Erase associatedtype T1
                    @Erase associatedtype T2: Interface
                    @Erase associatedtype T3: Interface, Protocol
                    @Erase associatedtype T4: Interface & Protocol
                    @Erase associatedtype T5: Interface & Protocol, Class
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
                
                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    typealias T1 = Any
                    typealias T2 = (Interface)._Eraser_
                    typealias T3 = (Interface & Protocol)._Eraser_
                    typealias T4 = (Interface & Protocol)._Eraser_
                    typealias T5 = (Interface & Protocol & Class)._Eraser_
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }
                """
            }
        }
    }

    @Suite(.tags(.static))
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
                
                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
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
                protocol Protocol: Equatable {
                
                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
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
                protocol Protocol: Hashable {
                
                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
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
                    @Erase<AnyHashable>
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
                
                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    typealias ID = AnyHashable
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    var id: ID {
                        self.base.id
                    }
                }
                protocol Protocol: Identifiable where ID == Int {
                
                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser where ID == Int {
                    typealias ID = Int
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    var id: ID {
                        self.base.id
                    }
                }
                protocol Protocol: Identifiable where Self.ID == Int {
                
                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser where Self.ID == Int {
                    typealias ID = Int
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    var id: ID {
                        self.base.id
                    }
                }
                protocol Protocol: Identifiable<Int> {
                
                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    typealias ID = Int
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    var id: ID {
                        self.base.id
                    }
                }
                protocol Protocol: Identifiable {
                    var id: Int { get }
                
                    /// Used for automatically resolving the type of `Erase` macro.
                    typealias _Eraser_ = AnyProtocol
                }

                struct AnyProtocol: Protocol, TypeEraser {
                    typealias ID = Int
                    /// The value wrapped by this instance.
                    var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    var id: Int {
                        get {
                            func id_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Int  {
                                var base: _OpenBase_ {
                                    get {
                                        self.base as! _OpenBase_
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

    @Suite(.tags(.default))
    struct `Default Tests` {
        @Test func `Multiple default specifiers`() async throws {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Default(.error)
                    @Default(.external)
                    static var variable: Any { get }
                }
                """
            } diagnostics: {
                """
                @TypeErased
                protocol Protocol {
                    @Default(.error)
                    ┬───────────────
                    ╰─ 🛑 Requirement can only have one default
                    @Default(.external)
                    ┬──────────────────
                    ╰─ 🛑 Requirement can only have one default
                    static var variable: Any { get }
                }
                """
            }
        }
    }

    @Suite(.tags(.option))
    struct `Options Tests` {
        @Test func `Multiple option specifiers`() async throws {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Options([])
                    @Options(.assureNoAssociates)
                    var variable: Any { get }
                }
                """
            } diagnostics: {
                """
                @TypeErased
                protocol Protocol {
                    @Options([])
                    ┬───────────
                    ╰─ 🛑 Only static requirements can have a default
                    @Options(.assureNoAssociates)
                    ┬────────────────────────────
                    ╰─ 🛑 Only static requirements can have a default
                    var variable: Any { get }
                }
                """
            }
        }
    }
}

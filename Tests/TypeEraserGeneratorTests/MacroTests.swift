import MacroTesting
import Testing

// TODO: This is fragile

@Suite(.macros(testMacros))
struct `Macro Tests` {
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

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
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

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol
                nonisolated
                protocol Protocol {}

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                }

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
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
                ╰─ 🛑 Cannot type erase a non-protocol type
                struct Protocol {}

                @TypeErased
                ┬──────────
                ╰─ 🛑 Cannot type erase a non-protocol type
                class Protocol {}

                @TypeErased
                ┬──────────
                ╰─ 🛑 Cannot type erase a non-protocol type
                actor Protocol {}

                @TypeErased
                ┬──────────
                ╰─ 🛑 Cannot type erase a non-protocol type
                enum Protocol {}

                @TypeErased
                ┬──────────
                ╰─ 🛑 Cannot type erase a non-protocol type
                let value = 0
                """
            }
        }

        @Test(.tags(.associateAndAssociateEraser))
        func `Type erased with selfGenerateCompositions flag with multiple associate addition types`() {
            assertMacro {
                """
                @TypeErased(options: .selfGenerateCompositions)
                protocol Protocol {
                    @Erase
                    associatedtype A: Protocol1
                    @Erase
                    associatedtype B: Protocol1, Protocol2
                    @Erase
                    associatedtype C: Protocol1, Protocol2

                    @Associate<any Protocol4>("D")
                    @Associate<any Protocol4, any Protocol5>("E")
                    @Associate<any Protocol4, any Protocol5, any Protocol6>("F")
                    var variable: Any { get }
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    associatedtype A: Protocol1
                    associatedtype B: Protocol1, Protocol2
                    associatedtype C: Protocol1, Protocol2
                    var variable: Any { get }
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                        associatedtype A: Protocol1 = AnyProtocol1
                        associatedtype B: Protocol1, Protocol2 = AnyProtocol1AndProtocol2
                        associatedtype C: Protocol1, Protocol2 = AnyProtocol1AndProtocol2
                        associatedtype D: Protocol4 = AnyProtocol4
                        associatedtype E: Protocol4, Protocol5 = AnyProtocol4AndProtocol5
                        associatedtype F: Protocol4, Protocol5, Protocol6 = AnyProtocol4AndProtocol5AndProtocol6
                    }
                    struct AnyProtocol1AndProtocol2: TypeEraser, ErasedProtocol1, ErasedProtocol2 {
                        /// The value wrapped by this instance.
                        var base: any Protocol1 & Protocol2
                        /// Create an instance that type-erases `Protocol1&Protocol2`.
                        init(_ erasing: some Protocol1 & Protocol2) {
                            self.base = erasing
                        }
                        /// Create an instance that type-erases `Protocol1&Protocol2`.
                        init(erasing: any Protocol1 & Protocol2) {
                            self.base = erasing
                        }
                    }
                    struct AnyProtocol1AndProtocol2: TypeEraser, ErasedProtocol1, ErasedProtocol2 {
                        /// The value wrapped by this instance.
                        var base: any Protocol1 & Protocol2
                        /// Create an instance that type-erases `Protocol1&Protocol2`.
                        init(_ erasing: some Protocol1 & Protocol2) {
                            self.base = erasing
                        }
                        /// Create an instance that type-erases `Protocol1&Protocol2`.
                        init(erasing: any Protocol1 & Protocol2) {
                            self.base = erasing
                        }
                    }
                    struct AnyProtocol4AndProtocol5: TypeEraser, ErasedProtocol4, ErasedProtocol5 {
                        /// The value wrapped by this instance.
                        var base: any Protocol4 & Protocol5
                        /// Create an instance that type-erases `Protocol4&Protocol5`.
                        init(_ erasing: some Protocol4 & Protocol5) {
                            self.base = erasing
                        }
                        /// Create an instance that type-erases `Protocol4&Protocol5`.
                        init(erasing: any Protocol4 & Protocol5) {
                            self.base = erasing
                        }
                    }
                    struct AnyProtocol4AndProtocol5AndProtocol6: TypeEraser, ErasedProtocol4, ErasedProtocol5, ErasedProtocol6 {
                        /// The value wrapped by this instance.
                        var base: any Protocol4 & Protocol5 & Protocol6
                        /// Create an instance that type-erases `Protocol4&Protocol5&Protocol6`.
                        init(_ erasing: some Protocol4 & Protocol5 & Protocol6) {
                            self.base = erasing
                        }
                        /// Create an instance that type-erases `Protocol4&Protocol5&Protocol6`.
                        init(erasing: any Protocol4 & Protocol5 & Protocol6) {
                            self.base = erasing
                        }
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                        var variable: Any {
                        get {
                            func variable_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Any  {
                                var localBase: _OpenBase_ {
                                    get {
                                        self.base_Protocol as! _OpenBase_
                                    }
                                };
                                return implicitCast(localBase.variable)
                            };
                            return implicitCast(_openExistential(self.base_Protocol, do: variable_genericOpen))
                        }
                    }
                }
                """
            }
        }

        @Test func `Type erased with disableEraserInheritance flag`() {
            assertMacro {
                """
                @TypeErased(options: .disableEraserInheritance)
                protocol Protocol: Protocol1, Protocol2, Protocol3 {}
                """
            } expansion: {
                """
                protocol Protocol: Protocol1, Protocol2, Protocol3 {}

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                }
                """
            }
        }

        @Test func `Type erased with advanced where clauses`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol: Protocol8 where
                    AS.AS2: Protocol1,
                    AS.AS3: Protocol2,
                    Self: Protocol3,
                    Self.AS1: Protocol4,
                    Self.AS1: Protocol5,
                    AS1: Protocol6 {
                @Erase
                associatedtype AS: Protocol6 where AS: Protocol7, AS2 == Int
                }
                """
            } expansion: {
                """
                protocol Protocol: Protocol8 where
                    AS.AS2: Protocol1,
                    AS.AS3: Protocol2,
                    Self: Protocol3,
                    Self.AS1: Protocol4,
                    Self.AS1: Protocol5,
                    AS1: Protocol6 {
                associatedtype AS: Protocol6 where AS: Protocol7, AS2 == Int
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    struct AS: TypeEraser, ErasedProtocol1, ErasedProtocol7 {
                        /// The value wrapped by this instance.
                        var base: any Protocol1 & Protocol7
                        /// Create an instance that type-erases `Protocol1&Protocol7`.
                        init(_ erasing: some Protocol1 & Protocol7) {
                            self.base = erasing
                        }
                        /// Create an instance that type-erases `Protocol1&Protocol7`.
                        init(erasing: any Protocol1 & Protocol7) {
                            self.base = erasing
                        }
                        typealias AS2 = AnyProtocol1
                    }
                    typealias AS1 = AnyProtocol4AndProtocol5AndProtocol6
                    typealias AS2 = Int
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol, ErasedProtocol8, ErasedProtocol3 {
                        associatedtype AS: Protocol6 = AnyProtocol6
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                }
                """
            }
        }
    }

    struct `Composition Tests` {
        @Test func `Composition type eraser`() {
            assertMacro {
                """
                enum Storage {
                    #compositionTypeEraser<any Protocol1, any Protocol2>()
                    #compositionTypeEraser<any Protocol1, any Protocol2, any Protocol3>()
                    #compositionTypeEraser<any Protocol1, any Protocol2, any Protocol3, any Protocol4>()
                }
                """
            } expansion: {
                """
                enum Storage {
                    struct AnyProtocol1AndProtocol2: TypeEraser, ErasedProtocol1, ErasedProtocol2 {
                        /// The value wrapped by this instance.
                        var base: any Protocol1 & Protocol2
                        /// Create an instance that type-erases `Protocol1&Protocol2`.
                        init(_ erasing: some Protocol1 & Protocol2) {
                            self.base = erasing
                        }
                        /// Create an instance that type-erases `Protocol1&Protocol2`.
                        init(erasing: any Protocol1 & Protocol2) {
                            self.base = erasing
                        }
                    }
                    typealias AnyProtocol2AndProtocol1 = AnyProtocol1AndProtocol2
                    struct AnyProtocol1AndProtocol2AndProtocol3: TypeEraser, ErasedProtocol1, ErasedProtocol2, ErasedProtocol3 {
                        /// The value wrapped by this instance.
                        var base: any Protocol1 & Protocol2 & Protocol3
                        /// Create an instance that type-erases `Protocol1&Protocol2&Protocol3`.
                        init(_ erasing: some Protocol1 & Protocol2 & Protocol3) {
                            self.base = erasing
                        }
                        /// Create an instance that type-erases `Protocol1&Protocol2&Protocol3`.
                        init(erasing: any Protocol1 & Protocol2 & Protocol3) {
                            self.base = erasing
                        }
                    }
                    typealias AnyProtocol1AndProtocol3AndProtocol2 = AnyProtocol1AndProtocol2AndProtocol3
                    typealias AnyProtocol2AndProtocol1AndProtocol3 = AnyProtocol1AndProtocol2AndProtocol3
                    typealias AnyProtocol2AndProtocol3AndProtocol1 = AnyProtocol1AndProtocol2AndProtocol3
                    typealias AnyProtocol3AndProtocol1AndProtocol2 = AnyProtocol1AndProtocol2AndProtocol3
                    typealias AnyProtocol3AndProtocol2AndProtocol1 = AnyProtocol1AndProtocol2AndProtocol3
                    struct AnyProtocol1AndProtocol2AndProtocol3AndProtocol4: TypeEraser, ErasedProtocol1, ErasedProtocol2, ErasedProtocol3, ErasedProtocol4 {
                        /// The value wrapped by this instance.
                        var base: any Protocol1 & Protocol2 & Protocol3 & Protocol4
                        /// Create an instance that type-erases `Protocol1&Protocol2&Protocol3&Protocol4`.
                        init(_ erasing: some Protocol1 & Protocol2 & Protocol3 & Protocol4) {
                            self.base = erasing
                        }
                        /// Create an instance that type-erases `Protocol1&Protocol2&Protocol3&Protocol4`.
                        init(erasing: any Protocol1 & Protocol2 & Protocol3 & Protocol4) {
                            self.base = erasing
                        }
                    }
                    typealias AnyProtocol1AndProtocol2AndProtocol4AndProtocol3 = AnyProtocol1AndProtocol2AndProtocol3AndProtocol4
                    typealias AnyProtocol1AndProtocol3AndProtocol2AndProtocol4 = AnyProtocol1AndProtocol2AndProtocol3AndProtocol4
                    typealias AnyProtocol1AndProtocol3AndProtocol4AndProtocol2 = AnyProtocol1AndProtocol2AndProtocol3AndProtocol4
                    typealias AnyProtocol1AndProtocol4AndProtocol2AndProtocol3 = AnyProtocol1AndProtocol2AndProtocol3AndProtocol4
                    typealias AnyProtocol1AndProtocol4AndProtocol3AndProtocol2 = AnyProtocol1AndProtocol2AndProtocol3AndProtocol4
                    typealias AnyProtocol2AndProtocol1AndProtocol3AndProtocol4 = AnyProtocol1AndProtocol2AndProtocol3AndProtocol4
                    typealias AnyProtocol2AndProtocol1AndProtocol4AndProtocol3 = AnyProtocol1AndProtocol2AndProtocol3AndProtocol4
                    typealias AnyProtocol2AndProtocol3AndProtocol1AndProtocol4 = AnyProtocol1AndProtocol2AndProtocol3AndProtocol4
                    typealias AnyProtocol2AndProtocol3AndProtocol4AndProtocol1 = AnyProtocol1AndProtocol2AndProtocol3AndProtocol4
                    typealias AnyProtocol2AndProtocol4AndProtocol1AndProtocol3 = AnyProtocol1AndProtocol2AndProtocol3AndProtocol4
                    typealias AnyProtocol2AndProtocol4AndProtocol3AndProtocol1 = AnyProtocol1AndProtocol2AndProtocol3AndProtocol4
                    typealias AnyProtocol3AndProtocol1AndProtocol2AndProtocol4 = AnyProtocol1AndProtocol2AndProtocol3AndProtocol4
                    typealias AnyProtocol3AndProtocol1AndProtocol4AndProtocol2 = AnyProtocol1AndProtocol2AndProtocol3AndProtocol4
                    typealias AnyProtocol3AndProtocol2AndProtocol1AndProtocol4 = AnyProtocol1AndProtocol2AndProtocol3AndProtocol4
                    typealias AnyProtocol3AndProtocol2AndProtocol4AndProtocol1 = AnyProtocol1AndProtocol2AndProtocol3AndProtocol4
                    typealias AnyProtocol3AndProtocol4AndProtocol1AndProtocol2 = AnyProtocol1AndProtocol2AndProtocol3AndProtocol4
                    typealias AnyProtocol3AndProtocol4AndProtocol2AndProtocol1 = AnyProtocol1AndProtocol2AndProtocol3AndProtocol4
                    typealias AnyProtocol4AndProtocol1AndProtocol2AndProtocol3 = AnyProtocol1AndProtocol2AndProtocol3AndProtocol4
                    typealias AnyProtocol4AndProtocol1AndProtocol3AndProtocol2 = AnyProtocol1AndProtocol2AndProtocol3AndProtocol4
                    typealias AnyProtocol4AndProtocol2AndProtocol1AndProtocol3 = AnyProtocol1AndProtocol2AndProtocol3AndProtocol4
                    typealias AnyProtocol4AndProtocol2AndProtocol3AndProtocol1 = AnyProtocol1AndProtocol2AndProtocol3AndProtocol4
                    typealias AnyProtocol4AndProtocol3AndProtocol1AndProtocol2 = AnyProtocol1AndProtocol2AndProtocol3AndProtocol4
                    typealias AnyProtocol4AndProtocol3AndProtocol2AndProtocol1 = AnyProtocol1AndProtocol2AndProtocol3AndProtocol4
                }
                """
            }
        }

        @Test func `Composition type eraser with overloaded commutativity`() {
            assertMacro {
                """
                #compositionTypeEraser<
                    any Protocol1,
                    any Protocol2,
                    any Protocol3,
                    any Protocol4,
                    any Protocol5,
                    any Protocol6,
                    any Protocol7
                >
                """
            } diagnostics: {
                """
                #compositionTypeEraser<
                ╰─ ⚠️ Commutativity overloaded, automatically disabled commutativity
                    any Protocol1,
                    any Protocol2,
                    any Protocol3,
                    any Protocol4,
                    any Protocol5,
                    any Protocol6,
                    any Protocol7
                >
                """
            } expansion: {
                """
                struct AnyProtocol1AndProtocol2AndProtocol3AndProtocol4AndProtocol5AndProtocol6AndProtocol7: TypeEraser, ErasedProtocol1, ErasedProtocol2, ErasedProtocol3, ErasedProtocol4, ErasedProtocol5, ErasedProtocol6, ErasedProtocol7 {
                    /// The value wrapped by this instance.
                    var base: any Protocol1 & Protocol2 & Protocol3 & Protocol4 & Protocol5 & Protocol6 & Protocol7
                    /// Create an instance that type-erases `Protocol1&Protocol2&Protocol3&Protocol4&Protocol5&Protocol6&Protocol7`.
                    init(_ erasing: some Protocol1 & Protocol2 & Protocol3 & Protocol4 & Protocol5 & Protocol6 & Protocol7) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol1&Protocol2&Protocol3&Protocol4&Protocol5&Protocol6&Protocol7`.
                    init(erasing: any Protocol1 & Protocol2 & Protocol3 & Protocol4 & Protocol5 & Protocol6 & Protocol7) {
                        self.base = erasing
                    }
                }
                """
            }
        }

        @Test func `Composition type eraser with disableCommutativity flag`() {
            assertMacro {
                """
                #compositionTypeEraser<any Protocol1, any Protocol2>(options: [.disableCommutativity])
                #compositionTypeEraser<any Protocol1, any Protocol2, any Protocol3>(options: [.disableCommutativity])
                #compositionTypeEraser<any Protocol1, any Protocol2, any Protocol3, any Protocol4>(options: [.disableCommutativity])
                """
            } expansion: {
                """
                struct AnyProtocol1AndProtocol2: TypeEraser, ErasedProtocol1, ErasedProtocol2 {
                    /// The value wrapped by this instance.
                    var base: any Protocol1 & Protocol2
                    /// Create an instance that type-erases `Protocol1&Protocol2`.
                    init(_ erasing: some Protocol1 & Protocol2) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol1&Protocol2`.
                    init(erasing: any Protocol1 & Protocol2) {
                        self.base = erasing
                    }
                }
                struct AnyProtocol1AndProtocol2AndProtocol3: TypeEraser, ErasedProtocol1, ErasedProtocol2, ErasedProtocol3 {
                    /// The value wrapped by this instance.
                    var base: any Protocol1 & Protocol2 & Protocol3
                    /// Create an instance that type-erases `Protocol1&Protocol2&Protocol3`.
                    init(_ erasing: some Protocol1 & Protocol2 & Protocol3) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol1&Protocol2&Protocol3`.
                    init(erasing: any Protocol1 & Protocol2 & Protocol3) {
                        self.base = erasing
                    }
                }
                struct AnyProtocol1AndProtocol2AndProtocol3AndProtocol4: TypeEraser, ErasedProtocol1, ErasedProtocol2, ErasedProtocol3, ErasedProtocol4 {
                    /// The value wrapped by this instance.
                    var base: any Protocol1 & Protocol2 & Protocol3 & Protocol4
                    /// Create an instance that type-erases `Protocol1&Protocol2&Protocol3&Protocol4`.
                    init(_ erasing: some Protocol1 & Protocol2 & Protocol3 & Protocol4) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol1&Protocol2&Protocol3&Protocol4`.
                    init(erasing: any Protocol1 & Protocol2 & Protocol3 & Protocol4) {
                        self.base = erasing
                    }
                }
                """
            }
        }

        @Test func `Composition type eraser with overloaded commutativity with disableCommutativity flag`() {
            assertMacro {
                """
                #compositionTypeEraser<
                    any Protocol1,
                    any Protocol2,
                    any Protocol3,
                    any Protocol5,
                    any Protocol6
                >(options: [.disableCommutativity])
                """
            } expansion: {
                """
                struct AnyProtocol1AndProtocol2AndProtocol3AndProtocol5AndProtocol6: TypeEraser, ErasedProtocol1, ErasedProtocol2, ErasedProtocol3, ErasedProtocol5, ErasedProtocol6 {
                    /// The value wrapped by this instance.
                    var base: any Protocol1 & Protocol2 & Protocol3 & Protocol5 & Protocol6
                    /// Create an instance that type-erases `Protocol1&Protocol2&Protocol3&Protocol5&Protocol6`.
                    init(_ erasing: some Protocol1 & Protocol2 & Protocol3 & Protocol5 & Protocol6) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol1&Protocol2&Protocol3&Protocol5&Protocol6`.
                    init(erasing: any Protocol1 & Protocol2 & Protocol3 & Protocol5 & Protocol6) {
                        self.base = erasing
                    }
                }
                """
            }
        }

        @Test func `Composition type eraser with non-protocol`() {
            assertMacro {
                """
                #compositionTypeEraser<Struct, any Protocol>
                """
            } diagnostics: {
                """
                #compositionTypeEraser<Struct, any Protocol>
                ┬───────────────────────────────────────────
                ╰─ 🛑 The protocols must be prefixed with 'any'
                """
            }
        }
    }

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
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                    var variable: Any {
                        get {
                            func variable_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Any  {
                                var localBase: _OpenBase_ {
                                    get {
                                        self.base_Protocol as! _OpenBase_
                                    }
                                };
                                return implicitCast(localBase.variable)
                            };
                            return implicitCast(_openExistential(self.base_Protocol, do: variable_genericOpen))
                        }
                    }
                    var variable: Any {
                        get async {
                            func variable_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) async -> Any  {
                                var localBase: _OpenBase_ {
                                    get {
                                        self.base_Protocol as! _OpenBase_
                                    }
                                };
                                return await implicitCast(localBase.variable)
                            };
                            return await implicitCast(_openExistential(self.base_Protocol, do: variable_genericOpen))
                        }
                    }
                    var variable: Any {
                        get throws {
                            func variable_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) throws -> Any  {
                                var localBase: _OpenBase_ {
                                    get {
                                        self.base_Protocol as! _OpenBase_
                                    }
                                };
                                do {
                                    return try implicitCast(localBase.variable)
                                } catch let error {
                                    throw implicitCast(error)
                                }
                            };
                            return try _openExistential(self.base_Protocol, do: variable_genericOpen)
                        }
                    }
                    var variable: Any {
                        get async throws {
                            func variable_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) async throws -> Any  {
                                var localBase: _OpenBase_ {
                                    get {
                                        self.base_Protocol as! _OpenBase_
                                    }
                                };
                                do {
                                    return try await implicitCast(localBase.variable)
                                } catch let error {
                                    throw implicitCast(error)
                                }
                            };
                            return try await _openExistential(self.base_Protocol, do: variable_genericOpen)
                        }
                    }
                    var variable: Any {
                        get throws(any Error) {
                            func variable_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) throws(any Error) -> Any  {
                                var localBase: _OpenBase_ {
                                    get {
                                        self.base_Protocol as! _OpenBase_
                                    }
                                };
                                do {
                                    return try implicitCast(localBase.variable)
                                } catch let error {
                                    throw implicitCast(error)
                                }
                            };
                            return try _openExistential(self.base_Protocol, do: variable_genericOpen)
                        }
                    }
                    var variable: Any {
                        get throws(SomeError) {
                            func variable_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) throws(SomeError) -> Any  {
                                var localBase: _OpenBase_ {
                                    get {
                                        self.base_Protocol as! _OpenBase_
                                    }
                                };
                                do {
                                    return try implicitCast(localBase.variable)
                                } catch let error {
                                    throw implicitCast(error)
                                }
                            };
                            return try _openExistential(self.base_Protocol, do: variable_genericOpen)
                        }
                    }
                    var variable: Any {
                        get throws(Never) {
                            func variable_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) throws(Never) -> Any  {
                                var localBase: _OpenBase_ {
                                    get {
                                        self.base_Protocol as! _OpenBase_
                                    }
                                };
                                do {
                                    return try implicitCast(localBase.variable)
                                } catch let error {
                                    throw implicitCast(error)
                                }
                            };
                            return try _openExistential(self.base_Protocol, do: variable_genericOpen)
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
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                    var variable: Any {
                        get {
                            func variable_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Any  {
                                var localBase: _OpenBase_ {
                                    get {
                                        self.base_Protocol as! _OpenBase_
                                    }
                                };
                                return implicitCast(localBase.variable)
                            };
                            return implicitCast(_openExistential(self.base_Protocol, do: variable_genericOpen))
                        }
                        set {
                            func variable_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) {
                                var localBase: _OpenBase_ {
                                    get {
                                        self.base_Protocol as! _OpenBase_
                                    }
                                    set {
                                        self.base_Protocol = newValue
                                    }
                                };
                                localBase.variable = implicitCast(newValue)
                            };
                            _openExistential(self.base_Protocol, do: variable_genericOpen)
                        }
                    }
                }
                """
            }
        }

        @Test(.tags(.implementation))
        func `Standard variables with implementation specifiers`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Implementation(.external) var variable: Any { get }
                    @Implementation(.type(Type.self)) var variable: Any { get }
                    @Implementation(.value(1)) var variable: Any { get }
                    @Implementation(.error) var variable: Any { get }
                }
                """
            } diagnostics: {
                """
                @TypeErased
                protocol Protocol {
                    @Implementation(.external) var variable: Any { get }
                    ┬─────────────────────────
                    ╰─ 🛑 Non-static requirements cannot have an explicit implementation
                    @Implementation(.type(Type.self)) var variable: Any { get }
                    ┬────────────────────────────────
                    ╰─ 🛑 Non-static requirements cannot have an explicit implementation
                    @Implementation(.value(1)) var variable: Any { get }
                    ┬─────────────────────────
                    ╰─ 🛑 Non-static requirements cannot have an explicit implementation
                    @Implementation(.error) var variable: Any { get }
                    ┬──────────────────────
                    ╰─ 🛑 Non-static requirements cannot have an explicit implementation
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
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                    var variable: Any {
                        get {
                            base_Protocol.variable
                        }
                    }
                    var variable: Any {
                        get async {
                            await base_Protocol.variable
                        }
                    }
                    var variable: Any {
                        get throws {
                            try base_Protocol.variable
                        }
                    }
                    var variable: Any {
                        get async throws {
                            try await base_Protocol.variable
                        }
                    }
                    var variable: Any {
                        get throws(any Error) {
                            try base_Protocol.variable
                        }
                    }
                    var variable: Any {
                        get throws(SomeError) {
                            try base_Protocol.variable
                        }
                    }
                    var variable: Any {
                        get throws(Never) {
                            try base_Protocol.variable
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
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                    var variable: Any {
                        get {
                            base_Protocol.variable
                        }
                        set {
                            base_Protocol.variable = newValue
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
                protocol Protocol {
                    static var variable: Any { get }
                }
                 ╰─ 🛑 Static requirements of type erased protocols must have an explicit implementation
                """
            }
        }

        @Test(.tags(.static, .implementation))
        func `Static variables without setter with implementation value`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Implementation(.value(1)) static var variable: Any { get }
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    static var variable: Any { get }
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                    static var variable: Any {
                        get {
                            implicitCast(1)
                        }
                    }
                }
                """
            }
        }

        @Test(.tags(.static, .implementation))
        func `Static variable with setter and implementation value`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Implementation(.value(1)) static var variable: Any { get set }
                }
                """
            } expansion: {
                #"""
                protocol Protocol {
                    static var variable: Any { get set }
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                    static var variable: Any {
                        get {
                            implicitCast(1)
                        }
                        set {
                            preconditionFailure("Tried to access static member \(#function) from type eraser")
                        }
                    }
                }
                """#
            }
        }

        @Test(.tags(.static, .modifiers, .implementation))
        func `Static variables with varying modifiers with implementation type`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Implementation(.type(Type.self)) static var variable: Any { get }
                    @Implementation(.type(Type.self)) static var variable: Any { get async }
                    @Implementation(.type(Type.self)) static var variable: Any { get throws }
                    @Implementation(.type(Type.self)) static var variable: Any { get async throws }
                    @Implementation(.type(Type.self)) static var variable: Any { get throws(any Error) }
                    @Implementation(.type(Type.self)) static var variable: Any { get throws(URLError) }
                    @Implementation(.type(Type.self)) static var variable: Any { get throws(Never) }
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
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                    static var variable: Any {
                        get {
                            implicitCast(Type.variable)
                        }
                    }
                    static var variable: Any {
                        get async {
                            implicitCast(Type.variable)
                        }
                    }
                    static var variable: Any {
                        get throws {
                            implicitCast(Type.variable)
                        }
                    }
                    static var variable: Any {
                        get async throws {
                            implicitCast(Type.variable)
                        }
                    }
                    static var variable: Any {
                        get throws(any Error) {
                            implicitCast(Type.variable)
                        }
                    }
                    static var variable: Any {
                        get throws(URLError) {
                            implicitCast(Type.variable)
                        }
                    }
                    static var variable: Any {
                        get throws(Never) {
                            implicitCast(Type.variable)
                        }
                    }
                }
                """
            }
        }

        @Test(.tags(.static, .implementation))
        func `Static variables with implementation type with setter`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Implementation(.type(Type.self)) static var variable: Any { get set }
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    static var variable: Any { get set }
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                    static var variable: Any {
                        get {
                            implicitCast(Type.variable)
                        }
                        set {
                            Type.variable = implicitCast(newValue)
                        }
                    }
                }
                """
            }
        }

        @Test(.tags(.static, .implementation))
        func `Static variables with external implementation`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Implementation(.external) static var variable: Any { get }
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    static var variable: Any { get }
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                }
                """
            }
        }

        @Test(.tags(.static, .implementation))
        func `Static variables with no implementation`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Implementation(.error) static var variable: Any { get }
                    @Implementation(.error) static var variable: Any { get set }
                }
                """
            } expansion: {
                #"""
                protocol Protocol {
                    static var variable: Any { get }
                    static var variable: Any { get set }
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                    static var variable: Any {
                        get {
                            preconditionFailure("Tried to access static member \(#function) from type eraser")
                        }
                    }
                    static var variable: Any {
                        get {
                            preconditionFailure("Tried to access static member \(#function) from type eraser")
                        }
                        set {
                            preconditionFailure("Tried to access static member \(#function) from type eraser")
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
                    @Implementation(.error) static var variable: Any { get }
                    @Implementation(.error) static var variable: Any { get set }
                    @Implementation(.error) static var variable: Any { get async }
                    @Implementation(.error) static var variable: Any { get throws }
                    @Implementation(.error) static var variable: Any { get async throws }
                    @Implementation(.error) static var variable: Any { get throws(any Error) }
                    @Implementation(.error) static var variable: Any { get throws(SomeError) }
                    @Implementation(.error) static var variable: Any { get throws(Never) }
                }
                """
            } diagnostics: {
                """
                @TypeErased(options: .exportStaticToObjectLevel)
                ┬───────────────────────────────────────────────
                ╰─ 🛑 Internal error: No options match
                protocol Protocol {
                    @Implementation(.error) static var variable: Any { get }
                    @Implementation(.error) static var variable: Any { get set }
                    @Implementation(.error) static var variable: Any { get async }
                    @Implementation(.error) static var variable: Any { get throws }
                    @Implementation(.error) static var variable: Any { get async throws }
                    @Implementation(.error) static var variable: Any { get throws(any Error) }
                    @Implementation(.error) static var variable: Any { get throws(SomeError) }
                    @Implementation(.error) static var variable: Any { get throws(Never) }
                }
                """
            }
        }
    }

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
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                    func function() {
                        func function_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Void {
                            var localBase: _OpenBase_ {
                                get {
                                    self.base_Protocol as! _OpenBase_
                                }
                            };
                            return implicitCast(localBase.function())
                        };
                        return implicitCast(_openExistential(self.base_Protocol, do: function_genericOpen))
                    }
                    func function(label: Any) {
                        func function_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Void {
                            var localBase: _OpenBase_ {
                                get {
                                    self.base_Protocol as! _OpenBase_
                                }
                            };
                            return implicitCast(localBase.function(label: implicitCast(label)))
                        };
                        return implicitCast(_openExistential(self.base_Protocol, do: function_genericOpen))
                    }
                    func function(_ param0: Any) {
                        func function_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Void {
                            var localBase: _OpenBase_ {
                                get {
                                    self.base_Protocol as! _OpenBase_
                                }
                            };
                            return implicitCast(localBase.function(implicitCast(param0)))
                        };
                        return implicitCast(_openExistential(self.base_Protocol, do: function_genericOpen))
                    }
                    func function(label input: Any) {
                        func function_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Void {
                            var localBase: _OpenBase_ {
                                get {
                                    self.base_Protocol as! _OpenBase_
                                }
                            };
                            return implicitCast(localBase.function(label: implicitCast(input)))
                        };
                        return implicitCast(_openExistential(self.base_Protocol, do: function_genericOpen))
                    }
                    func function(_ input: Any) {
                        func function_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Void {
                            var localBase: _OpenBase_ {
                                get {
                                    self.base_Protocol as! _OpenBase_
                                }
                            };
                            return implicitCast(localBase.function(implicitCast(input)))
                        };
                        return implicitCast(_openExistential(self.base_Protocol, do: function_genericOpen))
                    }
                    func function(label _: Any) {
                        func function_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Void {
                            var localBase: _OpenBase_ {
                                get {
                                    self.base_Protocol as! _OpenBase_
                                }
                            };
                            return implicitCast(localBase.function(label: implicitCast(label)))
                        };
                        return implicitCast(_openExistential(self.base_Protocol, do: function_genericOpen))
                    }
                    func function(_ param0: Any) {
                        func function_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Void {
                            var localBase: _OpenBase_ {
                                get {
                                    self.base_Protocol as! _OpenBase_
                                }
                            };
                            return implicitCast(localBase.function(implicitCast(param0)))
                        };
                        return implicitCast(_openExistential(self.base_Protocol, do: function_genericOpen))
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
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                    func function() async {
                        func function_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) async -> Void {
                            var localBase: _OpenBase_ {
                                get {
                                    self.base_Protocol as! _OpenBase_
                                }
                            };
                            return await implicitCast(localBase.function())
                        };
                        return await implicitCast(_openExistential(self.base_Protocol, do: function_genericOpen))
                    }
                    func function() throws {
                        func function_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) throws -> Void {
                            var localBase: _OpenBase_ {
                                get {
                                    self.base_Protocol as! _OpenBase_
                                }
                            };
                            do {
                                return try implicitCast(localBase.function())
                            } catch let error {
                                throw implicitCast(error)
                            }
                        };
                        return try implicitCast(_openExistential(self.base_Protocol, do: function_genericOpen))
                    }
                    func function() async throws {
                        func function_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) async throws -> Void {
                            var localBase: _OpenBase_ {
                                get {
                                    self.base_Protocol as! _OpenBase_
                                }
                            };
                            do {
                                return try await implicitCast(localBase.function())
                            } catch let error {
                                throw implicitCast(error)
                            }
                        };
                        return try await implicitCast(_openExistential(self.base_Protocol, do: function_genericOpen))
                    }
                    func function() throws(any Error) {
                        func function_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) throws(any Error) -> Void {
                            var localBase: _OpenBase_ {
                                get {
                                    self.base_Protocol as! _OpenBase_
                                }
                            };
                            do {
                                return try implicitCast(localBase.function())
                            } catch let error {
                                throw implicitCast(error)
                            }
                        };
                        return try implicitCast(_openExistential(self.base_Protocol, do: function_genericOpen))
                    }
                    func function() throws(SomeError) {
                        func function_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) throws(SomeError) -> Void {
                            var localBase: _OpenBase_ {
                                get {
                                    self.base_Protocol as! _OpenBase_
                                }
                            };
                            do {
                                return try implicitCast(localBase.function())
                            } catch let error {
                                throw implicitCast(error)
                            }
                        };
                        return try implicitCast(_openExistential(self.base_Protocol, do: function_genericOpen))
                    }
                    func function() throws(Never) {
                        func function_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) throws(Never) -> Void {
                            var localBase: _OpenBase_ {
                                get {
                                    self.base_Protocol as! _OpenBase_
                                }
                            };
                            return implicitCast(localBase.function())
                        };
                        return implicitCast(_openExistential(self.base_Protocol, do: function_genericOpen))
                    }
                }
                """
            }
        }

        @Test(.tags(.implementation))
        func `Standard functions with implementation specifiers`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Implementation(.external) func function() -> Any
                    @Implementation(.type(Type.self)) func function() -> Any
                    @Implementation(.value(1)) func function() -> Any
                    @Implementation(.error) func function() -> Any
                }
                """
            } diagnostics: {
                """
                @TypeErased
                protocol Protocol {
                    @Implementation(.external) func function() -> Any
                    ┬─────────────────────────
                    ╰─ 🛑 Non-static requirements cannot have an explicit implementation
                    @Implementation(.type(Type.self)) func function() -> Any
                    ┬────────────────────────────────
                    ╰─ 🛑 Non-static requirements cannot have an explicit implementation
                    @Implementation(.value(1)) func function() -> Any
                    ┬─────────────────────────
                    ╰─ 🛑 Non-static requirements cannot have an explicit implementation
                    @Implementation(.error) func function() -> Any
                    ┬──────────────────────
                    ╰─ 🛑 Non-static requirements cannot have an explicit implementation
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
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                    func function() {
                        base_Protocol.function()
                    }
                    func function(label: Any) {
                        base_Protocol.function(label: label)
                    }
                    func function(_ param0: Any) {
                        base_Protocol.function(param0)
                    }
                    func function(label input: Any) {
                        base_Protocol.function(label: input)
                    }
                    func function(_ input: Any) {
                        base_Protocol.function(input)
                    }
                    func function(label _: Any) {
                        base_Protocol.function(label: label)
                    }
                    func function(_ param0: Any) {
                        base_Protocol.function(param0)
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
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                    func function() async {
                        await base_Protocol.function()
                    }
                    func function() throws {
                        try base_Protocol.function()
                    }
                    func function() async throws {
                        try await base_Protocol.function()
                    }
                    func function() throws(any Error) {
                        try base_Protocol.function()
                    }
                    func function() throws(SomeError) {
                        try base_Protocol.function()
                    }
                    func function() throws(Never) {
                        base_Protocol.function()
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
                protocol Protocol {
                    static func function()
                }
                 ╰─ 🛑 Static requirements of type erased protocols must have an explicit implementation
                """
            }
        }

        @Test(.tags(.static, .implementation))
        func `Static function with implementation value`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Implementation(.value(1)) static func function() -> Any
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    static func function() -> Any
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                    static func function() -> Any {
                        implicitCast(1)
                    }
                }
                """
            }
        }

        @Test(.tags(.static, .parameters, .implementation))
        func `Static function with implementation type with varying parameter and input labels`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Implementation(.type(Type.self)) static func function()
                    @Implementation(.type(Type.self)) static func function(label: Any)
                    @Implementation(.type(Type.self)) static func function(_: Any)
                    @Implementation(.type(Type.self)) static func function(label input: Any)
                    @Implementation(.type(Type.self)) static func function(_ input: Any)
                    @Implementation(.type(Type.self)) static func function(label _: Any)
                    @Implementation(.type(Type.self)) static func function(_ _: Any)
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
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                    static func function() {
                        implicitCast(Type.function())
                    }
                    static func function(label: Any) {
                        implicitCast(Type.function(label: implicitCast(label)))
                    }
                    static func function(_ param0: Any) {
                        implicitCast(Type.function(implicitCast(param0)))
                    }
                    static func function(label input: Any) {
                        implicitCast(Type.function(label: implicitCast(input)))
                    }
                    static func function(_ input: Any) {
                        implicitCast(Type.function(implicitCast(input)))
                    }
                    static func function(label _: Any) {
                        implicitCast(Type.function(label: implicitCast(label)))
                    }
                    static func function(_ param0: Any) {
                        implicitCast(Type.function(implicitCast(param0)))
                    }
                }
                """
            }
        }

        @Test(.tags(.static, .modifiers, .implementation))
        func `Static function with implementation type with varying modifiers`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Implementation(.type(Type.self)) static func function() async
                    @Implementation(.type(Type.self)) static func function() throws
                    @Implementation(.type(Type.self)) static func function() async throws
                    @Implementation(.type(Type.self)) static func function() throws(any Error)
                    @Implementation(.type(Type.self)) static func function() throws(SomeError)
                    @Implementation(.type(Type.self)) static func function() throws(Never)
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
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                    static func function() async {
                        await implicitCast(Type.function())
                    }
                    static func function() throws {
                        try implicitCast(Type.function())
                    }
                    static func function() async throws {
                        try await implicitCast(Type.function())
                    }
                    static func function() throws(any Error) {
                        try implicitCast(Type.function())
                    }
                    static func function() throws(SomeError) {
                        try implicitCast(Type.function())
                    }
                    static func function() throws(Never) {
                        implicitCast(Type.function())
                    }
                }
                """
            }
        }

        @Test(.tags(.static, .implementation))
        func `Static function with external implementation`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Implementation(.external) static func function()
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    static func function()
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                }
                """
            }
        }

        @Test(.tags(.static, .implementation))
        func `Static function with no implementation`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Implementation(.error) static func function()
                }
                """
            } expansion: {
                #"""
                protocol Protocol {
                    static func function()
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                    static func function() {
                        preconditionFailure("Tried to access static member \(#function) from type eraser")
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
                    @Implementation(.error) static func function() async
                    @Implementation(.error) static func function() throws
                    @Implementation(.error) static func function() async throws
                    @Implementation(.error) static func function() throws(any Error)
                    @Implementation(.error) static func function() throws(SomeError)
                    @Implementation(.error) static func function() throws(Never)
                }
                """
            } diagnostics: {
                """
                @TypeErased(options: .exportStaticToObjectLevel)
                ┬───────────────────────────────────────────────
                ╰─ 🛑 Internal error: No options match
                protocol Protocol {
                    @Implementation(.error) static func function() async
                    @Implementation(.error) static func function() throws
                    @Implementation(.error) static func function() async throws
                    @Implementation(.error) static func function() throws(any Error)
                    @Implementation(.error) static func function() throws(SomeError)
                    @Implementation(.error) static func function() throws(Never)
                }
                """
            }
        }

        @Test(.tags(.static, .option, .parameters))
        func `Static function with exportStaticToObjectLevel flag with varying parameter and input labels`() {
            assertMacro {
                """
                @TypeErased(options: .exportStaticToObjectLevel)
                protocol Protocol {
                    @Implementation(.error) static func function()
                    @Implementation(.error) static func function(label: Any)
                    @Implementation(.error) static func function(_: Any)
                    @Implementation(.error) static func function(label input: Any)
                    @Implementation(.error) static func function(_ input: Any)
                    @Implementation(.error) static func function(label _: Any)
                    @Implementation(.error) static func function(_ _: Any)
                }
                """
            } diagnostics: {
                """
                @TypeErased(options: .exportStaticToObjectLevel)
                ┬───────────────────────────────────────────────
                ╰─ 🛑 Internal error: No options match
                protocol Protocol {
                    @Implementation(.error) static func function()
                    @Implementation(.error) static func function(label: Any)
                    @Implementation(.error) static func function(_: Any)
                    @Implementation(.error) static func function(label input: Any)
                    @Implementation(.error) static func function(_ input: Any)
                    @Implementation(.error) static func function(label _: Any)
                    @Implementation(.error) static func function(_ _: Any)
                }
                """
            }
        }
    }

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
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                    subscript() -> Any {
                        get {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Any  {
                                var localBase: _OpenBase_ {
                                    get {
                                        self.base_Protocol as! _OpenBase_
                                    }
                                };
                                return implicitCast(localBase[])
                            };
                            return implicitCast(_openExistential(self.base_Protocol, do: subscript_genericOpen))
                        }
                    }
                    subscript(label: Any) -> Any {
                        get {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Any  {
                                var localBase: _OpenBase_ {
                                    get {
                                        self.base_Protocol as! _OpenBase_
                                    }
                                };
                                return implicitCast(localBase[implicitCast(label)])
                            };
                            return implicitCast(_openExistential(self.base_Protocol, do: subscript_genericOpen))
                        }
                    }
                    subscript(_ param0: Any) -> Any {
                        get {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Any  {
                                var localBase: _OpenBase_ {
                                    get {
                                        self.base_Protocol as! _OpenBase_
                                    }
                                };
                                return implicitCast(localBase[implicitCast(param0)])
                            };
                            return implicitCast(_openExistential(self.base_Protocol, do: subscript_genericOpen))
                        }
                    }
                    subscript(label input: Any) -> Any {
                        get {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Any  {
                                var localBase: _OpenBase_ {
                                    get {
                                        self.base_Protocol as! _OpenBase_
                                    }
                                };
                                return implicitCast(localBase[label: implicitCast(input)])
                            };
                            return implicitCast(_openExistential(self.base_Protocol, do: subscript_genericOpen))
                        }
                    }
                    subscript(_ input: Any) -> Any {
                        get {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Any  {
                                var localBase: _OpenBase_ {
                                    get {
                                        self.base_Protocol as! _OpenBase_
                                    }
                                };
                                return implicitCast(localBase[implicitCast(input)])
                            };
                            return implicitCast(_openExistential(self.base_Protocol, do: subscript_genericOpen))
                        }
                    }
                    subscript(label param0: Any) -> Any {
                        get {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Any  {
                                var localBase: _OpenBase_ {
                                    get {
                                        self.base_Protocol as! _OpenBase_
                                    }
                                };
                                return implicitCast(localBase[label: implicitCast(param0)])
                            };
                            return implicitCast(_openExistential(self.base_Protocol, do: subscript_genericOpen))
                        }
                    }
                    subscript(_ param0: Any) -> Any {
                        get {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Any  {
                                var localBase: _OpenBase_ {
                                    get {
                                        self.base_Protocol as! _OpenBase_
                                    }
                                };
                                return implicitCast(localBase[implicitCast(param0)])
                            };
                            return implicitCast(_openExistential(self.base_Protocol, do: subscript_genericOpen))
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
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                    subscript() -> Any {
                        get {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Any  {
                                var localBase: _OpenBase_ {
                                    get {
                                        self.base_Protocol as! _OpenBase_
                                    }
                                };
                                return implicitCast(localBase[])
                            };
                            return implicitCast(_openExistential(self.base_Protocol, do: subscript_genericOpen))
                        }
                        set {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) {
                                var localBase: _OpenBase_ {
                                    get {
                                        self.base_Protocol as! _OpenBase_
                                    }
                                    set {
                                        self.base_Protocol = newValue
                                    }
                                };
                                return localBase[] = implicitCast(newValue)
                            };
                            _openExistential(self.base_Protocol, do: subscript_genericOpen)
                        }
                    }
                    subscript(label: Any) -> Any {
                        get {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Any  {
                                var localBase: _OpenBase_ {
                                    get {
                                        self.base_Protocol as! _OpenBase_
                                    }
                                };
                                return implicitCast(localBase[implicitCast(label)])
                            };
                            return implicitCast(_openExistential(self.base_Protocol, do: subscript_genericOpen))
                        }
                        set {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) {
                                var localBase: _OpenBase_ {
                                    get {
                                        self.base_Protocol as! _OpenBase_
                                    }
                                    set {
                                        self.base_Protocol = newValue
                                    }
                                };
                                return localBase[implicitCast(label)] = implicitCast(newValue)
                            };
                            _openExistential(self.base_Protocol, do: subscript_genericOpen)
                        }
                    }
                    subscript(_ param0: Any) -> Any {
                        get {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Any  {
                                var localBase: _OpenBase_ {
                                    get {
                                        self.base_Protocol as! _OpenBase_
                                    }
                                };
                                return implicitCast(localBase[implicitCast(param0)])
                            };
                            return implicitCast(_openExistential(self.base_Protocol, do: subscript_genericOpen))
                        }
                        set {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) {
                                var localBase: _OpenBase_ {
                                    get {
                                        self.base_Protocol as! _OpenBase_
                                    }
                                    set {
                                        self.base_Protocol = newValue
                                    }
                                };
                                return localBase[implicitCast(param0)] = implicitCast(newValue)
                            };
                            _openExistential(self.base_Protocol, do: subscript_genericOpen)
                        }
                    }
                    subscript(label input: Any) -> Any {
                        get {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Any  {
                                var localBase: _OpenBase_ {
                                    get {
                                        self.base_Protocol as! _OpenBase_
                                    }
                                };
                                return implicitCast(localBase[label: implicitCast(input)])
                            };
                            return implicitCast(_openExistential(self.base_Protocol, do: subscript_genericOpen))
                        }
                        set {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) {
                                var localBase: _OpenBase_ {
                                    get {
                                        self.base_Protocol as! _OpenBase_
                                    }
                                    set {
                                        self.base_Protocol = newValue
                                    }
                                };
                                return localBase[label: implicitCast(input)] = implicitCast(newValue)
                            };
                            _openExistential(self.base_Protocol, do: subscript_genericOpen)
                        }
                    }
                    subscript(_ input: Any) -> Any {
                        get {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Any  {
                                var localBase: _OpenBase_ {
                                    get {
                                        self.base_Protocol as! _OpenBase_
                                    }
                                };
                                return implicitCast(localBase[implicitCast(input)])
                            };
                            return implicitCast(_openExistential(self.base_Protocol, do: subscript_genericOpen))
                        }
                        set {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) {
                                var localBase: _OpenBase_ {
                                    get {
                                        self.base_Protocol as! _OpenBase_
                                    }
                                    set {
                                        self.base_Protocol = newValue
                                    }
                                };
                                return localBase[implicitCast(input)] = implicitCast(newValue)
                            };
                            _openExistential(self.base_Protocol, do: subscript_genericOpen)
                        }
                    }
                    subscript(label param0: Any) -> Any {
                        get {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Any  {
                                var localBase: _OpenBase_ {
                                    get {
                                        self.base_Protocol as! _OpenBase_
                                    }
                                };
                                return implicitCast(localBase[label: implicitCast(param0)])
                            };
                            return implicitCast(_openExistential(self.base_Protocol, do: subscript_genericOpen))
                        }
                        set {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) {
                                var localBase: _OpenBase_ {
                                    get {
                                        self.base_Protocol as! _OpenBase_
                                    }
                                    set {
                                        self.base_Protocol = newValue
                                    }
                                };
                                return localBase[label: implicitCast(param0)] = implicitCast(newValue)
                            };
                            _openExistential(self.base_Protocol, do: subscript_genericOpen)
                        }
                    }
                    subscript(_ param0: Any) -> Any {
                        get {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Any  {
                                var localBase: _OpenBase_ {
                                    get {
                                        self.base_Protocol as! _OpenBase_
                                    }
                                };
                                return implicitCast(localBase[implicitCast(param0)])
                            };
                            return implicitCast(_openExistential(self.base_Protocol, do: subscript_genericOpen))
                        }
                        set {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) {
                                var localBase: _OpenBase_ {
                                    get {
                                        self.base_Protocol as! _OpenBase_
                                    }
                                    set {
                                        self.base_Protocol = newValue
                                    }
                                };
                                return localBase[implicitCast(param0)] = implicitCast(newValue)
                            };
                            _openExistential(self.base_Protocol, do: subscript_genericOpen)
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
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                    subscript() -> Any {
                        get async {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) async -> Any  {
                                var localBase: _OpenBase_ {
                                    get {
                                        self.base_Protocol as! _OpenBase_
                                    }
                                };
                                return await implicitCast(localBase[])
                            };
                            return await implicitCast(_openExistential(self.base_Protocol, do: subscript_genericOpen))
                        }
                    }
                    subscript() -> Any {
                        get throws {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) throws -> Any  {
                                var localBase: _OpenBase_ {
                                    get {
                                        self.base_Protocol as! _OpenBase_
                                    }
                                };
                                do {
                                    return try implicitCast(localBase[])
                                } catch let error {
                                    throw implicitCast(error)
                                }
                            };
                            return try implicitCast(_openExistential(self.base_Protocol, do: subscript_genericOpen))
                        }
                    }
                    subscript() -> Any {
                        get async throws {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) async throws -> Any  {
                                var localBase: _OpenBase_ {
                                    get {
                                        self.base_Protocol as! _OpenBase_
                                    }
                                };
                                do {
                                    return try await implicitCast(localBase[])
                                } catch let error {
                                    throw implicitCast(error)
                                }
                            };
                            return try await implicitCast(_openExistential(self.base_Protocol, do: subscript_genericOpen))
                        }
                    }
                    subscript() -> Any {
                        get throws(any Error) {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) throws(any Error) -> Any  {
                                var localBase: _OpenBase_ {
                                    get {
                                        self.base_Protocol as! _OpenBase_
                                    }
                                };
                                do {
                                    return try implicitCast(localBase[])
                                } catch let error {
                                    throw implicitCast(error)
                                }
                            };
                            return try implicitCast(_openExistential(self.base_Protocol, do: subscript_genericOpen))
                        }
                    }
                    subscript() -> Any {
                        get throws(SomeError) {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) throws(SomeError) -> Any  {
                                var localBase: _OpenBase_ {
                                    get {
                                        self.base_Protocol as! _OpenBase_
                                    }
                                };
                                do {
                                    return try implicitCast(localBase[])
                                } catch let error {
                                    throw implicitCast(error)
                                }
                            };
                            return try implicitCast(_openExistential(self.base_Protocol, do: subscript_genericOpen))
                        }
                    }
                    subscript() -> Any {
                        get throws(Never) {
                            func subscript_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) throws(Never) -> Any  {
                                var localBase: _OpenBase_ {
                                    get {
                                        self.base_Protocol as! _OpenBase_
                                    }
                                };
                                return implicitCast(localBase[])
                            };
                            return implicitCast(_openExistential(self.base_Protocol, do: subscript_genericOpen))
                        }
                    }
                }
                """
            }
        }

        @Test(.tags(.implementation))
        func `Standard subscripts with implementation specifiers`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Implementation(.external) subscript() -> Any { get }
                    @Implementation(.type(Type.self)) subscript() -> Any { get }
                    @Implementation(.value(1)) subscript() -> Any { get }
                    @Implementation(.error) subscript() -> Any { get }
                }
                """
            } diagnostics: {
                """
                @TypeErased
                protocol Protocol {
                    @Implementation(.external) subscript() -> Any { get }
                    ┬─────────────────────────
                    ╰─ 🛑 Non-static requirements cannot have an explicit implementation
                    @Implementation(.type(Type.self)) subscript() -> Any { get }
                    ┬────────────────────────────────
                    ╰─ 🛑 Non-static requirements cannot have an explicit implementation
                    @Implementation(.value(1)) subscript() -> Any { get }
                    ┬─────────────────────────
                    ╰─ 🛑 Non-static requirements cannot have an explicit implementation
                    @Implementation(.error) subscript() -> Any { get }
                    ┬──────────────────────
                    ╰─ 🛑 Non-static requirements cannot have an explicit implementation
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
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                    subscript() -> Any {
                        get {
                            base_Protocol[]
                        }
                    }
                    subscript(label: Any) -> Any {
                        get {
                            base_Protocol[label]
                        }
                    }
                    subscript(_ param0: Any) -> Any {
                        get {
                            base_Protocol[param0]
                        }
                    }
                    subscript(label input: Any) -> Any {
                        get {
                            base_Protocol[label: input]
                        }
                    }
                    subscript(_ input: Any) -> Any {
                        get {
                            base_Protocol[input]
                        }
                    }
                    subscript(label param0: Any) -> Any {
                        get {
                            base_Protocol[label: param0]
                        }
                    }
                    subscript(_ param0: Any) -> Any {
                        get {
                            base_Protocol[param0]
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
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                    subscript() -> Any {
                        get {
                            base_Protocol[]
                        }
                        set {
                            base_Protocol[] = newValue
                        }
                    }
                    subscript(label: Any) -> Any {
                        get {
                            base_Protocol[label]
                        }
                        set {
                            base_Protocol[label] = newValue
                        }
                    }
                    subscript(_ param0: Any) -> Any {
                        get {
                            base_Protocol[param0]
                        }
                        set {
                            base_Protocol[param0] = newValue
                        }
                    }
                    subscript(label input: Any) -> Any {
                        get {
                            base_Protocol[label: input]
                        }
                        set {
                            base_Protocol[label: input] = newValue
                        }
                    }
                    subscript(_ input: Any) -> Any {
                        get {
                            base_Protocol[input]
                        }
                        set {
                            base_Protocol[input] = newValue
                        }
                    }
                    subscript(label param0: Any) -> Any {
                        get {
                            base_Protocol[label: param0]
                        }
                        set {
                            base_Protocol[label: param0] = newValue
                        }
                    }
                    subscript(_ param0: Any) -> Any {
                        get {
                            base_Protocol[param0]
                        }
                        set {
                            base_Protocol[param0] = newValue
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
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                    subscript() -> Any {
                        get async {
                            await base_Protocol[]
                        }
                    }
                    subscript() -> Any {
                        get throws {
                            try base_Protocol[]
                        }
                    }
                    subscript() -> Any {
                        get async throws {
                            try await base_Protocol[]
                        }
                    }
                    subscript() -> Any {
                        get throws(any Error) {
                            try base_Protocol[]
                        }
                    }
                    subscript() -> Any {
                        get throws(SomeError) {
                            try base_Protocol[]
                        }
                    }
                    subscript() -> Any {
                        get throws(Never) {
                            try base_Protocol[]
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
                protocol Protocol {
                    static subscript() -> Any { get }
                }
                 ╰─ 🛑 Static requirements of type erased protocols must have an explicit implementation
                """
            }
        }

        @Test(.tags(.static, .implementation))
        func `Static subscript with implementation value without setter`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Implementation(.value(1)) static subscript() -> Any { get }
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    static subscript() -> Any { get }
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                    static subscript() -> Any {
                        get {
                            implicitCast(1)
                        }
                    }
                }
                """
            }
        }

        @Test(.tags(.static, .implementation))
        func `Static subscript with implementation value with setter`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Implementation(.value(1)) static subscript() -> Any { get set }
                }
                """
            } expansion: {
                #"""
                protocol Protocol {
                    static subscript() -> Any { get set }
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                    static subscript() -> Any {
                        get {
                            implicitCast(1)
                        }
                        set {
                            preconditionFailure("Tried to access static member \(#function) from type eraser")
                        }
                    }
                }
                """#
            }
        }

        @Test(.tags(.static, .parameters, .implementation))
        func `Static subscript with implementation type with varying parameter and input labels without setters`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Implementation(.type(Type.self)) static subscript() -> Any { get }
                    @Implementation(.type(Type.self)) static subscript(label: Any) -> Any { get }
                    @Implementation(.type(Type.self)) static subscript(_: Any) -> Any { get }
                    @Implementation(.type(Type.self)) static subscript(label input: Any) -> Any { get }
                    @Implementation(.type(Type.self)) static subscript(_ input: Any) -> Any { get }
                    @Implementation(.type(Type.self)) static subscript(label _: Any) -> Any { get }
                    @Implementation(.type(Type.self)) static subscript(_ _: Any) -> Any { get }
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

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                    static subscript() -> Any {
                        get {
                            implicitCast(Type[])
                        }
                    }
                    static subscript(label: Any) -> Any {
                        get {
                            implicitCast(Type[implicitCast(label)])
                        }
                    }
                    static subscript(_ param0: Any) -> Any {
                        get {
                            implicitCast(Type[implicitCast(param0)])
                        }
                    }
                    static subscript(label input: Any) -> Any {
                        get {
                            implicitCast(Type[label: implicitCast(input)])
                        }
                    }
                    static subscript(_ input: Any) -> Any {
                        get {
                            implicitCast(Type[implicitCast(input)])
                        }
                    }
                    static subscript(label param0: Any) -> Any {
                        get {
                            implicitCast(Type[label: implicitCast(param0)])
                        }
                    }
                    static subscript(_ param0: Any) -> Any {
                        get {
                            implicitCast(Type[implicitCast(param0)])
                        }
                    }
                }
                """
            }
        }

        @Test(.tags(.static, .parameters, .implementation))
        func `Static subscript with implementation type with varying parameter and input labels with setters`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Implementation(.type(Type.self)) static subscript() -> Any { get set }
                    @Implementation(.type(Type.self)) static subscript(label: Any) -> Any { get set }
                    @Implementation(.type(Type.self)) static subscript(_: Any) -> Any { get set }
                    @Implementation(.type(Type.self)) static subscript(label input: Any) -> Any { get set }
                    @Implementation(.type(Type.self)) static subscript(_ input: Any) -> Any { get set }
                    @Implementation(.type(Type.self)) static subscript(label _: Any) -> Any { get set }
                    @Implementation(.type(Type.self)) static subscript(_ _: Any) -> Any { get set }
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

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                    static subscript() -> Any {
                        get {
                            implicitCast(Type[])
                        }
                        set {
                            Type[] = implicitCast(newValue)
                        }
                    }
                    static subscript(label: Any) -> Any {
                        get {
                            implicitCast(Type[implicitCast(label)])
                        }
                        set {
                            Type[implicitCast(label)] = implicitCast(newValue)
                        }
                    }
                    static subscript(_ param0: Any) -> Any {
                        get {
                            implicitCast(Type[implicitCast(param0)])
                        }
                        set {
                            Type[implicitCast(param0)] = implicitCast(newValue)
                        }
                    }
                    static subscript(label input: Any) -> Any {
                        get {
                            implicitCast(Type[label: implicitCast(input)])
                        }
                        set {
                            Type[label: implicitCast(input)] = implicitCast(newValue)
                        }
                    }
                    static subscript(_ input: Any) -> Any {
                        get {
                            implicitCast(Type[implicitCast(input)])
                        }
                        set {
                            Type[implicitCast(input)] = implicitCast(newValue)
                        }
                    }
                    static subscript(label param0: Any) -> Any {
                        get {
                            implicitCast(Type[label: implicitCast(param0)])
                        }
                        set {
                            Type[label: implicitCast(param0)] = implicitCast(newValue)
                        }
                    }
                    static subscript(_ param0: Any) -> Any {
                        get {
                            implicitCast(Type[implicitCast(param0)])
                        }
                        set {
                            Type[implicitCast(param0)] = implicitCast(newValue)
                        }
                    }
                }
                """
            }
        }

        @Test(.tags(.static, .modifiers, .implementation))
        func `Static subscript with implementation type with varying modifiers`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Implementation(.type(Type.self)) static subscript() -> Any { get async }
                    @Implementation(.type(Type.self)) static subscript() -> Any { get throws }
                    @Implementation(.type(Type.self)) static subscript() -> Any { get async throws }
                    @Implementation(.type(Type.self)) static subscript() -> Any { get throws(any Error) }
                    @Implementation(.type(Type.self)) static subscript() -> Any { get throws(SomeError) }
                    @Implementation(.type(Type.self)) static subscript() -> Any { get throws(Never) }
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

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                    static subscript() -> Any {
                        get async {
                            await implicitCast(Type[])
                        }
                    }
                    static subscript() -> Any {
                        get throws {
                            try implicitCast(Type[])
                        }
                    }
                    static subscript() -> Any {
                        get async throws {
                            try await implicitCast(Type[])
                        }
                    }
                    static subscript() -> Any {
                        get throws(any Error) {
                            try implicitCast(Type[])
                        }
                    }
                    static subscript() -> Any {
                        get throws(SomeError) {
                            try implicitCast(Type[])
                        }
                    }
                    static subscript() -> Any {
                        get throws(Never) {
                            try implicitCast(Type[])
                        }
                    }
                }
                """
            }
        }

        @Test(.tags(.static, .implementation))
        func `Static subscript with external implementation`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Implementation(.external) static subscript() -> Any { get }
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    static subscript() -> Any { get }
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                }
                """
            }
        }

        @Test(.tags(.static, .implementation))
        func `Static subscripts with no implementation`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Implementation(.error) static subscript() -> Any { get }
                    @Implementation(.error) static subscript() -> Any { get set }
                }
                """
            } expansion: {
                #"""
                protocol Protocol {
                    static subscript() -> Any { get }
                    static subscript() -> Any { get set }
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                    static subscript() -> Any {
                        get {
                            preconditionFailure("Tried to access static member \(#function) from type eraser")
                        }
                    }
                    static subscript() -> Any {
                        get {
                            preconditionFailure("Tried to access static member \(#function) from type eraser")
                        }
                        set {
                            preconditionFailure("Tried to access static member \(#function) from type eraser")
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
                    @Implementation(.none) static subscript() -> Any { get }
                    @Implementation(.none) static subscript(label: Any) -> Any { get }
                    @Implementation(.none) static subscript(_: Any) -> Any { get }
                    @Implementation(.none) static subscript(label input: Any) -> Any { get }
                    @Implementation(.none) static subscript(_ input: Any) -> Any { get }
                    @Implementation(.none) static subscript(label _: Any) -> Any { get }
                    @Implementation(.none) static subscript(_ _: Any) -> Any { get }
                }
                """
            } diagnostics: {
                """
                @TypeErased(options: .exportStaticToObjectLevel)
                ┬───────────────────────────────────────────────
                ╰─ 🛑 Internal error: No options match
                protocol Protocol {
                    @Implementation(.none) static subscript() -> Any { get }
                    @Implementation(.none) static subscript(label: Any) -> Any { get }
                    @Implementation(.none) static subscript(_: Any) -> Any { get }
                    @Implementation(.none) static subscript(label input: Any) -> Any { get }
                    @Implementation(.none) static subscript(_ input: Any) -> Any { get }
                    @Implementation(.none) static subscript(label _: Any) -> Any { get }
                    @Implementation(.none) static subscript(_ _: Any) -> Any { get }
                }
                """
            }
        }

        @Test(.tags(.static, .option, .parameters))
        func `Static subscripts with exportStaticToObjectLevel flag with varying parameter and input labels with setters`() {
            assertMacro {
                """
                @TypeErased(options: .exportStaticToObjectLevel)
                protocol Protocol {
                    @Implementation(.none) static subscript() -> Any { get set }
                    @Implementation(.none) static subscript(label: Any) -> Any { get set }
                    @Implementation(.none) static subscript(_: Any) -> Any { get set }
                    @Implementation(.none) static subscript(label input: Any) -> Any { get set }
                    @Implementation(.none) static subscript(_ input: Any) -> Any { get set }
                    @Implementation(.none) static subscript(label _: Any) -> Any { get set }
                    @Implementation(.none) static subscript(_ _: Any) -> Any { get set }
                }
                """
            } diagnostics: {
                """
                @TypeErased(options: .exportStaticToObjectLevel)
                ┬───────────────────────────────────────────────
                ╰─ 🛑 Internal error: No options match
                protocol Protocol {
                    @Implementation(.none) static subscript() -> Any { get set }
                    @Implementation(.none) static subscript(label: Any) -> Any { get set }
                    @Implementation(.none) static subscript(_: Any) -> Any { get set }
                    @Implementation(.none) static subscript(label input: Any) -> Any { get set }
                    @Implementation(.none) static subscript(_ input: Any) -> Any { get set }
                    @Implementation(.none) static subscript(label _: Any) -> Any { get set }
                    @Implementation(.none) static subscript(_ _: Any) -> Any { get set }
                }
                """
            }
        }

        @Test(.tags(.static, .option, .modifiers))
        func `Static subscripts with exportStaticToObjectLevel flag with varying modifiers`() {
            assertMacro {
                """
                @TypeErased(options: .exportStaticToObjectLevel)
                protocol Protocol {
                    @Implementation(.none) static subscript() -> Any { get async }
                    @Implementation(.none) static subscript() -> Any { get throws }
                    @Implementation(.none) static subscript() -> Any { get async throws }
                    @Implementation(.none) static subscript() -> Any { get throws(any Error) }
                    @Implementation(.none) static subscript() -> Any { get throws(SomeError) }
                    @Implementation(.none) static subscript() -> Any { get throws(Never) }
                }
                """
            } diagnostics: {
                """
                @TypeErased(options: .exportStaticToObjectLevel)
                ┬───────────────────────────────────────────────
                ╰─ 🛑 Internal error: No options match
                protocol Protocol {
                    @Implementation(.none) static subscript() -> Any { get async }
                    @Implementation(.none) static subscript() -> Any { get throws }
                    @Implementation(.none) static subscript() -> Any { get async throws }
                    @Implementation(.none) static subscript() -> Any { get throws(any Error) }
                    @Implementation(.none) static subscript() -> Any { get throws(SomeError) }
                    @Implementation(.none) static subscript() -> Any { get throws(Never) }
                }
                """
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
                protocol Protocol {
                    init()
                }
                 ╰─ 🛑 Static requirements of type erased protocols must have an explicit implementation
                """
            }
        }

        @Test(.tags(.parameters, .implementation))
        func `Initializers with implementation type with varying parameter and input labels`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Implementation(.type(Type.self)) init()
                    @Implementation(.type(Type.self)) init(label: Any)
                    @Implementation(.type(Type.self)) init(_: Any)
                    @Implementation(.type(Type.self)) init(label input: Any)
                    @Implementation(.type(Type.self)) init(_ input: Any)
                    @Implementation(.type(Type.self)) init(label _: Any)
                    @Implementation(.type(Type.self)) init(_ _: Any)
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

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                    init() {
                        self.init(Type())
                    }
                    init(label: Any) {
                        self.init(Type(label: implicitCast(label)))
                    }
                    init(_ param0: Any) {
                        self.init(Type(implicitCast(param0)))
                    }
                    init(label input: Any) {
                        self.init(Type(label: implicitCast(input)))
                    }
                    init(_ input: Any) {
                        self.init(Type(implicitCast(input)))
                    }
                    init(label _: Any) {
                        self.init(Type(label: implicitCast(label)))
                    }
                    init(_ param0: Any) {
                        self.init(Type(implicitCast(param0)))
                    }
                }
                """
            }
        }

        @Test(.tags(.modifiers, .implementation))
        func `Initializers with implementation type with varying modifiers`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Implementation(.type(Type.self)) init() async
                    @Implementation(.type(Type.self)) init() throws
                    @Implementation(.type(Type.self)) init() async throws
                    @Implementation(.type(Type.self)) init() throws(any Error)
                    @Implementation(.type(Type.self)) init() throws(SomeError)
                    @Implementation(.type(Type.self)) init() throws(Never)
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

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
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

        @Test(.tags(.implementation))
        func `Optional initializer with implementation type`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Implementation(.type(Type.self)) init?()
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    init?()
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
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

        @Test(.tags(.implementation))
        func `Initializer with external implementation`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Implementation(.external) init()
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    init()
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                }
                """
            }
        }

        @Test(.tags(.implementation))
        func `Initializer with no implementation`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Implementation(.error) init()
                }
                """
            } expansion: {
                #"""
                protocol Protocol {
                    init()
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                    init() {
                        preconditionFailure("Tried to access static member \(#function) from type eraser")
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
                ╰─ 🛑 Associated type 'T' does not have an associated eraser
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
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                        associatedtype T1 = Type
                        associatedtype T2 = Type
                        associatedtype T3 = Type
                        associatedtype T4 = Type
                        associatedtype T5 = Type
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
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
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                        associatedtype T1 = Any
                        associatedtype T2: Interface = AnyInterface
                        associatedtype T3: Interface, Protocol = AnyInterfaceAndProtocol
                        associatedtype T4: Interface, Protocol = AnyInterfaceAndProtocol
                        associatedtype T5: Interface, Protocol, Class = AnyInterfaceAndProtocolAndClass
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
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
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                    typealias T = Int
                }
                """
            }
        }
    }

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

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol, ErasedEquatable {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
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

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol, ErasedHashable {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
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

                """
            } expansion: {
                """
                protocol Protocol: Identifiable {}

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol, ErasedIdentifiable {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                }
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
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol, ErasedIdentifiable {
                        associatedtype ID = AnyHashable
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol
                protocol Protocol: Identifiable where ID == Int {}

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    typealias ID = Int
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol, ErasedIdentifiable {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol
                protocol Protocol: Identifiable where Self.ID == Int {}

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                    typealias ID = Int
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol, ErasedIdentifiable {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol
                protocol Protocol: Identifiable<Int> {}

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol, ErasedIdentifiable {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol
                protocol Protocol: Identifiable {
                    var id: Int { get }
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol, ErasedIdentifiable {
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                }

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                }

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                }

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                }

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                    var id: Int {
                        get {
                            func id_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Int  {
                                var localBase: _OpenBase_ {
                                    get {
                                        self.base_Protocol as! _OpenBase_
                                    }
                                };
                                return implicitCast(localBase.id)
                            };
                            return implicitCast(_openExistential(self.base_Protocol, do: id_genericOpen))
                        }
                    }
                }
                """
            }
        }
    }

    @Suite(.tags(.implementation))
    struct `Implementation Macro Tests` {
        @Test func `Multiple implementation specifiers`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Implementation(.error)
                    @Implementation(.external)
                    static var variable: Any { get }
                }
                """
            } diagnostics: {
                """
                @TypeErased
                protocol Protocol {
                    @Implementation(.error)
                    ┬──────────────────────
                    ╰─ 🛑 Static requirements must have a single explicit implementation
                    @Implementation(.external)
                    ┬─────────────────────────
                    ╰─ 🛑 Static requirements must have a single explicit implementation
                    static var variable: Any { get }
                }
                """
            }
        }
    }

    @Suite(.tags(.option))
    struct `Options Macro Tests` {
        @Test func `Multiple option specifiers`() {
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
                    ╰─ 🛑 Trailing closure must be used
                    @Options(.assureNoAssociates)
                    ┬────────────────────────────
                    ╰─ 🛑 Trailing closure must be used
                    var variable: Any { get }
                }
                """
            }
        }
    }

    @Suite(.tags(.option, .associateAndAssociateEraser))
    struct `Associate And AssociateEraser Macro Tests` {
        @Test func associate() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Associate<any Protocol>("AS")
                    var variable: Any { get }
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    var variable: Any { get }
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                        associatedtype AS: Protocol = AnyProtocol
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                        var variable: Any {
                        get {
                            func variable_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Any  {
                                var localBase: _OpenBase_ {
                                    get {
                                        self.base_Protocol as! _OpenBase_
                                    }
                                };
                                return implicitCast(localBase.variable)
                            };
                            return implicitCast(_openExistential(self.base_Protocol, do: variable_genericOpen))
                        }
                    }
                }
                """
            }
        }

        @Test(.tags(.associateAndAssociateEraser))
        func `Associate with non protocol`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @Associate<Struct>("AS")
                    var variable: Any { get }
                }
                """
            } diagnostics: {
                """
                @TypeErased
                ┬──────────
                ╰─ 🛑 The protocols must be prefixed with 'any'
                protocol Protocol {
                    @Associate<Struct>("AS")
                    var variable: Any { get }
                }
                """
            }
        }

        @Test(.tags(.associateAndAssociateEraser))
        func `Associate eraser`() {
            assertMacro {
                """
                @TypeErased
                protocol Protocol {
                    @AssociateEraser<Eraser>("AS")
                    var variable: Any { get }
                }
                """
            } expansion: {
                """
                protocol Protocol {
                    var variable: Any { get }
                }

                /// A type erased `Protocol` value.
                internal struct AnyProtocol: TypeEraser, ErasedProtocol {
                    /// The value wrapped by this instance.
                    internal var base: any Protocol
                    /// Create an instance that type-erases `Protocol`.
                    internal init(_ erasing: some Protocol) {
                        self.base = erasing
                    }
                    /// Create an instance that type-erases `Protocol`.
                    internal init(erasing: any Protocol) {
                        self.base = erasing
                    }
                }

                internal enum _ErasedStorageProtocol {
                    internal protocol ErasedProtocol: TypeEraser, Protocol {
                        associatedtype AS = Eraser
                    }
                }

                internal typealias ErasedProtocol = _ErasedStorageProtocol.ErasedProtocol

                internal extension _ErasedStorageProtocol.ErasedProtocol {
                    private var base_Protocol: any Protocol {
                        get {
                            base as! any Protocol
                        }
                        set {
                            base = newValue as! _Base_
                        }
                    }
                        var variable: Any {
                        get {
                            func variable_genericOpen<_OpenBase_: Protocol>(_: _OpenBase_) -> Any  {
                                var localBase: _OpenBase_ {
                                    get {
                                        self.base_Protocol as! _OpenBase_
                                    }
                                };
                                return implicitCast(localBase.variable)
                            };
                            return implicitCast(_openExistential(self.base_Protocol, do: variable_genericOpen))
                        }
                    }
                }
                """
            }
        }
    }
}

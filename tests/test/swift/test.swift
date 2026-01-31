// Swift syntax highlighting test file
// Covers: keywords, types, strings, numbers, comments, attributes

import Foundation
import SwiftUI

/// A documentation comment for the protocol
protocol Drawable {
    func draw() -> String
    var description: String { get }
}

/**
 * Multi-line documentation comment
 * for the Shape class
 */
@available(iOS 15.0, macOS 12.0, *)
public class Shape: Drawable {
    private var name: String
    internal let sides: Int
    public static var count = 0

    // MARK: - Initialization

    required init(name: String, sides: Int) {
        self.name = name
        self.sides = sides
        Self.count += 1
    }

    deinit {
        Self.count -= 1
    }

    func draw() -> String {
        return "Drawing \(name) with \(sides) sides"
    }

    var description: String {
        get { return name }
        set { name = newValue }
    }
}

// Struct with generics
struct Container<T: Equatable>: Hashable {
    var items: [T] = []

    mutating func add(_ item: T) {
        items.append(item)
    }

    subscript(index: Int) -> T {
        return items[index]
    }
}

// Enum with associated values
enum Result<Success, Failure: Error> {
    case success(Success)
    case failure(Failure)

    var isSuccess: Bool {
        switch self {
        case .success: return true
        case .failure: return false
        }
    }
}

// Actor for concurrency
actor Counter {
    private var value = 0

    func increment() {
        value += 1
    }

    nonisolated func description() -> String {
        return "Counter actor"
    }
}

// Extension with protocol conformance
extension Int: Drawable {
    func draw() -> String { String(self) }
    var description: String { "Integer: \(self)" }
}

// Numbers: decimal, binary, octal, hex, float
let decimal = 42
let binary = 0b101010
let octal = 0o52
let hex = 0x2A
let float = 3.14159
let scientific = 1.25e-2
let hexFloat = 0xC.3p0
let bigNumber = 1_000_000
let negativeFloat = -273.15

// Strings
let simple = "Hello, World!"
let escaped = "Tab:\tNewline:\nQuote:\""
let unicode = "Unicode: \u{1F600}"
let interpolated = "Value is \(decimal) and \(float)"
let multiline = """
    This is a multiline
    string literal with
    interpolation: \(hex)
    """
let raw = #"Raw string with "quotes" and \n not escaped"#
let rawInterpolated = #"Value: \#(decimal)"#

// Control flow
func processValue(_ value: Int?) -> String {
    guard let v = value else {
        return "nil"
    }

    if v < 0 {
        return "negative"
    } else if v == 0 {
        return "zero"
    }

    for i in 0..<v {
        print(i)
    }

    var sum = 0
    while sum < v {
        sum += 1
    }

    repeat {
        sum -= 1
    } while sum > 0

    switch v {
    case 0:
        return "zero"
    case 1...10:
        return "small"
    case let x where x > 100:
        return "large: \(x)"
    default:
        break
    }

    defer {
        print("Cleanup")
    }

    return "done"
}

// Error handling
enum NetworkError: Error {
    case timeout
    case notFound(url: String)
}

func fetchData() throws -> Data {
    throw NetworkError.timeout
}

func handleError() {
    do {
        let data = try fetchData()
        print(data)
    } catch NetworkError.timeout {
        print("Timeout!")
    } catch {
        print("Unknown error: \(error)")
    }

    let result = try? fetchData()
    let forced = try! Data()
    _ = result
    _ = forced
}

// Async/await
func asyncOperation() async throws -> Int {
    try await Task.sleep(nanoseconds: 1_000_000)
    return 42
}

@MainActor
func updateUI() async {
    let value = await (try? asyncOperation()) ?? 0
    print(value)
}

// Closures
let closure = { (x: Int) -> Int in
    return x * 2
}

let shortClosure: (Int) -> Int = { $0 * 2 }

let sorted = [3, 1, 2].sorted { $0 < $1 }

// Property wrappers
@propertyWrapper
struct Clamped {
    private var value: Int
    private let range: ClosedRange<Int>

    var wrappedValue: Int {
        get { value }
        set { value = min(max(newValue, range.lowerBound), range.upperBound) }
    }

    init(wrappedValue: Int, _ range: ClosedRange<Int>) {
        self.range = range
        self.value = min(max(wrappedValue, range.lowerBound), range.upperBound)
    }
}

// Compiler directives
#if DEBUG
let debugMode = true
#elseif RELEASE
let debugMode = false
#else
let debugMode = false
#endif

#if swift(>=5.5)
// Swift 5.5+ code
#endif

// Special literals
func logLocation(file: String = #file, line: Int = #line, function: String = #function) {
    print("\(file):\(line) - \(function)")
}

// Keywords as identifiers (backticks)
let `class` = "not a class"
let `self` = "not self"

// Operators
precedencegroup ExponentiationPrecedence {
    higherThan: MultiplicationPrecedence
    associativity: right
}

infix operator **: ExponentiationPrecedence

func ** (base: Double, power: Double) -> Double {
    return pow(base, power)
}

// Type aliases and opaque types
typealias StringDict = Dictionary<String, Any>
typealias Completion = (Result<Data, Error>) -> Void

func makeShape() -> some Drawable {
    return Shape(name: "Square", sides: 4)
}

// Main entry point
@main
struct App {
    static func main() async {
        print("Hello, Swift!")
    }
}

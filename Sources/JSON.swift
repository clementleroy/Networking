import Foundation

/// The ParsingError codes generated by JSON.
enum ParsingError: Error {
    case notFound, failed
}

enum JSON: Equatable {
    case none

    case dictionary(Data, [String: Any])

    case array(Data, [[String: Any]])

    var dictionary: [String: Any] {
        get {
            switch self {
            case .dictionary(_, let body):
                return body
            default:
                return [String: Any]()
            }
        }
    }

    var array: [[String: Any]] {
        get {
            switch self {
            case .array(_, let body):
                return body
            default:
                return [[String: Any]]()
            }
        }
    }

    init(_ data: Data) throws {
        let body = try JSONSerialization.jsonObject(with: data, options: [])

        if let dictionary = body as? [String: Any] {
            self = .dictionary(data, dictionary)
        } else if let array = body as? [[String: Any]] {
            self = .array(data, array)
        } else {
            self = JSON.none
        }
    }

    init(_ dictionary: [String: Any]) {
        let data = try! JSONSerialization.data(withJSONObject: dictionary, options: [])

        self = .dictionary(data, dictionary)
    }

    init(_ array: [[String: Any]]) {
        let data = try! JSONSerialization.data(withJSONObject: array, options: [])

        self = .array(data, array)
    }
}

public extension FileManager {
    /// Returns a JSON object from a file.
    ///
    /// - Parameters:
    ///   - fileName: The name of the file, the expected extension is `.json`.
    ///   - bundle: The Bundle where the file is located, by default is the main bundle.
    /// - Returns: A JSON object, it can be either a Dictionary or an Array.
    /// - Throws: An error if it wasn't able to process the file.
    public static func json(from fileName: String, bundle: Bundle = Bundle.main) throws -> Any? {
        var json: Any?

        guard let url = URL(string: fileName), let filePath = bundle.path(forResource: url.deletingPathExtension().absoluteString, ofType: url.pathExtension) else { throw ParsingError.notFound }
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else { throw ParsingError.failed }

        json = try data.toJSON()

        return json
    }
}

func ==(lhs: JSON, rhs: JSON) -> Bool {
    return lhs.array.debugDescription == rhs.array.debugDescription && lhs.dictionary.debugDescription == rhs.dictionary.debugDescription
}

extension Data {

    /// Serializes Data into a JSON object.
    ///
    /// - Returns: A JSON object, it can be either a Dictionary or an Array.
    /// - Throws: An error if it couldn't serialize the data into json.
    public func toJSON() throws -> Any? {
        var json: Any?
        do {
            json = try JSONSerialization.jsonObject(with: self, options: [])
        } catch {
            throw ParsingError.failed
        }

        return json
    }
}

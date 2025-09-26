import Foundation

struct FPError: Error {
    let statusCode: Int
    let message: String?
}

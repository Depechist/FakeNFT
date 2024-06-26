import Foundation

struct Collection: Decodable {
    let id: String
    let name: String
    let cover: URL
    let author: String
    let description: String
    let nfts: [String]
    let createdAt: String
}

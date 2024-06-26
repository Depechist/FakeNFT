import Foundation

struct Profile: Decodable {
    let id: String
    let name: String
    let avatar: URL
    let description: String
    let website: URL
    let nfts: [String]
    let likes: [String]
}

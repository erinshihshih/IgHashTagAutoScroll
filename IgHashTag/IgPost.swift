// To parse the JSON, add this file to your project and do:
//
//   let findSetting = try FindSetting(json)

import Foundation
import RealmSwift

class IgPost: Object, Decodable {
    @objc dynamic var id: String = ""
    @objc dynamic var content: String = ""
    @objc dynamic var imgUrl: String = ""
    @objc dynamic var fetchTime: Double = 0.0
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "key"
        case content
        case imgUrl = "img_url"
    }
    
    public required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.imgUrl = try container.decode(String.self, forKey: .imgUrl)
        self.content = try container.decode(String.self, forKey: .content)
        self.fetchTime = NSDate().timeIntervalSince1970
    }
}

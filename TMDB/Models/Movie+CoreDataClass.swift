//
//  Movie+CoreDataClass.swift
//  TMDB
//
//  Created by Preetam Jadakar on 24/01/21.
//
//

import Foundation
import CoreData

@objc(Movie)
public class Movie: NSManagedObject, Codable {

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        do {
            try container.encode(id , forKey: .id)
        } catch {
            print("errors", error)
        }
    }
    
    required convenience public init(from decoder: Decoder) throws {
        // return the context from the decoder userinfo dictionary
        guard let contextUserInfoKey = CodingUserInfoKey(rawValue: "context"),
        let managedObjectContext = decoder.userInfo[contextUserInfoKey] as? NSManagedObjectContext,
        let entity = NSEntityDescription.entity(forEntityName: "Movie", in: managedObjectContext)
        else {
            fatalError("decode failure")
        }
        // Super init of the NSManagedObject
        self.init(entity: entity, insertInto: managedObjectContext)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
            id = try values.decode(Int64.self, forKey: .id)
            title = try values.decode(String.self, forKey: .title)
            poster_path = try values.decode(String.self, forKey: .poster_path)
            vote_average = try values.decode(Float.self, forKey: .vote_average)
        } catch {
            print ("error", error)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case poster_path
        case vote_average
    }
}

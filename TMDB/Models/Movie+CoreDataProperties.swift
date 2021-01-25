//
//  Movie+CoreDataProperties.swift
//  TMDB
//
//  Created by Preetam Jadakar on 24/01/21.
//
//

import Foundation
import CoreData


extension Movie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Movie> {
        return NSFetchRequest<Movie>(entityName: "Movie")
    }

    @NSManaged public var id: Int64
    @NSManaged public var title: String?
    @NSManaged public var poster_path: String?
    @NSManaged public var vote_average: Float
    @NSManaged public var isFavorited: Bool
    @NSManaged public var dateAdded: Date?

}

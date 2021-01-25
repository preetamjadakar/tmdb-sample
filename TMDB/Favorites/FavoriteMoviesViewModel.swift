//
//  FavoriteMoviesViewModel.swift
//  TMDB
//
//  Created by Preetam Jadakar on 24/01/21.
//

import Foundation
import CoreData

class FavoriteMoviesViewModel {
    var dataSource = [Movie]()

    
    func loadFavorites(_ completion: @escaping(Bool) -> Void) {
        let request: NSFetchRequest<Movie> = Movie.fetchRequest()
        let sort = NSSortDescriptor(key: favoritedDateKey, ascending: false)
        request.sortDescriptors = [sort]
        let predicate = NSPredicate(format: "\(favoritesKey) == true")
        request.predicate = predicate
        do {
            dataSource = try Database.shared.context.fetch(request)
            completion(true)
        } catch {
            print("Fetch failed")
            completion(false)
        }
    }
}

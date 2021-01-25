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
    var errorCallBack: ((String) -> Void)?
    private var storageType: StorageType!

    init(storage: StorageType) {
        storageType = storage
    }
    
    func loadFavorites(_ completion: @escaping(Bool) -> Void) {
        let request: NSFetchRequest<Movie> = Movie.fetchRequest()
        let sort = NSSortDescriptor(key: favoritedDateKey, ascending: false)
        request.sortDescriptors = [sort]
        let predicate = NSPredicate(format: "\(favoritesKey) == true")
        request.predicate = predicate
        do {
            dataSource = try storageType.context.fetch(request)
            completion(true)
        } catch {
            self.errorCallBack?(error.localizedDescription)
            completion(false)
        }
    }
    
    func markFavorite(for index: Int) {
        let movieModel = dataSource[index]
        //update coreData
        movieModel.setValue(!movieModel.isFavorited, forKey: favoritesKey)
        storageType.saveContext()
        dataSource.remove(at: index)
    }
}

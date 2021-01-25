//
//  MoviesViewModel.swift
//  TMDB
//
//  Created by Preetam Jadakar on 24/01/21.
//

import Foundation
import CoreData
import Network

class MoviesViewModel {
    var dataSource = [Movie]()
    var currentPage = 1
    var pageSize = 20
    var totalPages = Int()
    var shouldFetchSavedData = true
    
    var errorCallBack: ((String) -> Void)?
    private var storageType: StorageType!
    
    init(storage: StorageType) {
        storageType = storage
    }
    
    func markFavorite(for index: Int) {
        let movieModel = dataSource[index]
        //update coreData
        movieModel.setValue(!movieModel.isFavorited, forKey: favoritesKey)
        movieModel.setValue(Date(), forKey: favoritedDateKey)
        storageType.saveContext()
    }
    
    func fetchFirstPageData(completion: @escaping(Bool) -> Void) {
        currentPage = 1
        dataSource = []
        self.isNetworkAvailable { (available) in
            if available {
                self.storageType.clearStorage()
                self.fetchMovies(completion)
            } else {
                self.loadFetchedData(completion)
            }
        }
    }
    
    func fetchNextPageData(completion: @escaping(Bool) -> Void) {
        currentPage += 1
        self.isNetworkAvailable { (available) in
            if available {
                guard self.currentPage <= self.totalPages  else { return }
                self.fetchMovies(completion)
            } else {
                self.loadFetchedData(completion)
            }
        }
    }
    
    private func loadFetchedData(_ completion: @escaping(Bool) -> Void) {
        guard shouldFetchSavedData else {
            completion(false)
            return            
        }
        let request: NSFetchRequest<Movie> = Movie.fetchRequest()
        request.fetchOffset = (currentPage-1)*pageSize
        request.fetchLimit = pageSize
        do {
            let movies = try storageType.context.fetch(request)
            shouldFetchSavedData = movies.count > 0
            dataSource.append(contentsOf: movies)
            completion(true)
        } catch {
            self.errorCallBack?(error.localizedDescription)
            completion(false)
        }
    }
    
    private func fetchMovies(_ completion: @escaping(Bool) -> Void) {
        guard let urlString = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=34c902e6393dc8d970be5340928602a7&language=en-US&page=\(currentPage)") else { return }
        URLSession.shared.dataTask(with: urlString) {[weak self] (data, response, error) in
            guard let data = data else {
                self?.errorCallBack?(error?.localizedDescription ?? defaultErrorMessage)
                return
            }
            do {
                guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext else {
                    fatalError("Failed to retrieve managed object context")
                }
                let decoder = JSONDecoder()
                // Assign the NSManagedIbject Context to the decoder
                decoder.userInfo[codingUserInfoKeyManagedObjectContext] = self?.storageType.context
                let response = try decoder.decode(MoviesResponseModel.self, from: data)
                self?.totalPages = response.total_pages
                self?.storageType.saveContext()
                self?.loadFetchedData { (success) in
                    completion(success)
                }
            } catch {
                self?.errorCallBack?(error.localizedDescription)
                completion(false)
            }
        }.resume()
    }
    
    func isNetworkAvailable( completion:@escaping((Bool) -> Void)) {
        let pathMonitor = NWPathMonitor()
        pathMonitor.pathUpdateHandler = { path in
            if path.status == NWPath.Status.satisfied {
                pathMonitor.cancel()
                completion(true)
            } else {
                pathMonitor.cancel()
                completion(false)
            }
        }
        pathMonitor.start(queue: DispatchQueue.main)
    }
}

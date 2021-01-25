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

    func fetchFirstPageData(completion: @escaping(Bool) -> Void) {
        currentPage = 1
        dataSource = []
        self.isNetworkAvailable { (available) in
            if available {
                Database.shared.clearStorage()
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
            let movies = try Database.shared.context.fetch(request)
            shouldFetchSavedData = movies.count > 0
            dataSource.append(contentsOf: movies)
            completion(true)
        } catch {
            completion(false)
        }
    }
    
    private func fetchMovies(_ completion: @escaping(Bool) -> Void) {
        guard let urlString = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=34c902e6393dc8d970be5340928602a7&language=en-US&page=\(currentPage)") else { return }
        URLSession.shared.dataTask(with: urlString) { (data, response, error) in
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                // Assign the NSManagedIbject Context to the decoder
                decoder.userInfo[CodingUserInfoKey(rawValue: "context")!] = Database.shared.context
                let response = try decoder.decode(MoviesResponseModel.self, from: data)
                self.totalPages = response.total_pages
                Database.shared.saveContext()
                self.loadFetchedData { (success) in
                    completion(success)
                }
            } catch {
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

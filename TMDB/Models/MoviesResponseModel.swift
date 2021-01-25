//
//  MoviesResponseModel.swift
//  TMDB
//
//  Created by Preetam Jadakar on 24/01/21.
//

import Foundation

struct MoviesResponseModel: Codable {
  let total_pages: Int
  let result: [Movie]
  enum CodingKeys: String, CodingKey {
    case total_pages
    case result = "results"
  }
}

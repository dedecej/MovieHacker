//
//  Movie.swift
//  MovieHacker
//
//  Created by Jan Dědeček and Tomaš Novella on 13/08/2017.
//  Copyright © 2017 Jan Dědeček and Tomaš Novella. All rights reserved.
//

import Foundation

// Date formatter will be used to parse date
let dateFormatter = { () -> DateFormatter in
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "yyyy-MM-dd"
  return dateFormatter
}()

let decoder = { () -> JSONDecoder in
  let decoder = JSONDecoder()
  decoder.dateDecodingStrategy = .formatted(dateFormatter)
  return decoder
}()

struct Movie: Codable {
  let title: String
  let poster_path: String?
  let overview: String
  private let release_date: Date?

  var releaseDate: Date? {
    return release_date
  }

  var posterUrl: URL? {
    if let poster_path = poster_path {
      return URL(string: "https://image.tmdb.org/t/p/w500/")?.appendingPathComponent(poster_path)
    } else {
      return nil
    }
  }
}

struct MovieQueryResults: Codable {
  let results: [Movie]
}

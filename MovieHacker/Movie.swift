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

struct Movie
{
  let title: String
  let posterPath: String
  let overview: String
  let releaseDate: Date

  // Parse movie from a json
  init?(json: Any) {
    // Try to cast json to dictionary and load its properties
    guard let object = json as? [AnyHashable: Any],
      let title = object["title"] as? String,
      let posterPath = object["poster_path"] as? String,
      let overview = object["overview"] as? String,
      let releaseDate = dateFormatter.date(from: object["release_date"] as? String ?? "") else {
        return nil
    }

    self.title = title
    self.posterPath = posterPath
    self.overview = overview
    self.releaseDate = releaseDate
  }

  var posterUrl: URL? {
    return URL(string: "https://image.tmdb.org/t/p/w500/")?.appendingPathComponent(posterPath)
  }
}

func parse(json: Any) -> [Movie]?
{
  guard let results = (json as? [AnyHashable: Any])?["results"] as? [Any] else {
    return nil
  }

  return results.flatMap {
    return Movie(json: $0)
  }
}

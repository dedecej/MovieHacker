//
//  Movie.swift
//  MovieHacker
//
//  Created by Jan Dědeček on 13/08/2017.
//  Copyright © 2017 Jan Dědeček. All rights reserved.
//

import Foundation

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

  init?(json: Any) {
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

  return results.flatMap { (result) in
    return Movie(json: result)
  }
}

//
//  ViewController.swift
//  MovieHacker
//
//  Created by Jan Dědeček and Tomaš Novella on 07/08/2017.
//  Copyright © 2017 Jan Dědeček and Tomaš Novella. All rights reserved.
//

import UIKit

let apiKey = ""

class TableViewController: UITableViewController {

  // Task responsible for fetching movies from the server
  var task: URLSessionDataTask?

  // Array loaded with movies
  var model = [Movie]()

  override func viewDidLoad() {
    super.viewDidLoad()

    let today = dateFormatter.string(from: Date())
    let oneMonthLater = dateFormatter.string(from: Date().addingTimeInterval(3600*24*30))

    let url = URL(string: "https://api.themoviedb.org/3/discover/movie"
      + "?primary_release_date.gte=\(today)"
      + "&primary_release_date.lte=\(oneMonthLater)"
      + "&api_key=\(apiKey)&region=us&with_release_type=3&sort_by=primary_release_date.asc")!

    // Fetch movies from the server
    task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
      // Parse JSON into array of movies
      if let data = data, let query = try? decoder.decode(MovieQueryResults.self, from: data) {
        DispatchQueue.main.async {
          // Set the model and reload table's content
          self?.model = query.results
          // This (UI) task must be performed on main thread
          self?.tableView.reloadData()
        }
      }
    }
    task?.resume()
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Pass selected movie to the presented view controller
    if let movie = sender as? Movie, let controller = segue.destination as? MovieDetailViewController {
      controller.movie = movie
    }
  }

  // MARK: - UITableViewDataSource

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return model.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    let movie = model[indexPath.row]
    cell.textLabel?.text = movie.title
    cell.detailTextLabel?.text = movie.overview

    // iOS keeps only a few cells in the memory. Every time user scrolls, iOS either creates new cell or
    // reuses cell, which has been scrolled away. Therefore it is not good idea to perform image fetching, every time
    // this method is called.

    if let posterUrl = movie.posterUrl {
      // Try to fetch image from the cache
      if let image = image(from: posterUrl) {
        cell.imageView?.image = image
      } else {
        // Try to load image from the server
        loadImage(from: posterUrl) { [weak self] (_) -> Void in
          // Self is captured only weakly, otherwise we would bound life cycle of this view to life cycle of image fetch task.
          self?.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
      }
    }

    return cell
  }

  // MARK: - UITableViewDelegate

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // Display detail of selected movie
    performSegue(withIdentifier: "ShowMovieSegue", sender: model[indexPath.row])
  }
}



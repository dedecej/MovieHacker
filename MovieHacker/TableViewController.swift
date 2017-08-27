//
//  ViewController.swift
//  MovieHacker
//
//  Created by Jan Dědeček on 07/08/2017.
//  Copyright © 2017 Jan Dědeček. All rights reserved.
//

import UIKit

let apiKey = ""

class TableViewController: UITableViewController {

  var task: URLSessionDataTask?

  var model = [Movie]()

  let imageCache = NSCache<NSString, UIImage>()

  let taskCache = NSCache<NSString, URLSessionDataTask>()

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    tableView.cellLayoutMarginsFollowReadableWidth = true

    let today = dateFormatter.string(from: Date())
    let oneMonthLater = dateFormatter.string(from: Date().addingTimeInterval(3600*24*30))

    //let url = URL(string: "https://api.themoviedb.org/3/movie/upcoming?api_key=\(apiKey)&region=us")!
    let url = URL(string: "https://api.themoviedb.org/3/discover/movie"
      + "?primary_release_date.gte=\(today)"
      + "&primary_release_date.lte=\(oneMonthLater)"
      + "&api_key=\(apiKey)&region=us&with_release_type=3&sort_by=primary_release_date.asc")!

    task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
      if let data = data,
        let json = try? JSONSerialization.jsonObject(with: data),
        let model = parse(json: json) {
        DispatchQueue.main.async {
          self?.model = model
          self?.tableView.reloadData()
        }
      }
    }
    task?.resume()
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let movie = sender as? Movie, let controller = segue.destination as? MovieDetailViewController {
      controller.movie = movie
    }
  }

  // UITableViewDataSource

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return model.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    let movie = model[indexPath.row]
    cell.textLabel?.text = movie.title
    cell.detailTextLabel?.text = movie.overview

    if let posterUrl = movie.posterUrl {
      if let image = image(from: posterUrl) {
        cell.imageView?.image = image
      } else {
        loadImage(from: posterUrl) { [weak self] (_) -> Void in
          self?.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
      }
    }

    return cell
  }

  // UITableViewDelegate

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: "ShowMovieSegue", sender: model[indexPath.row])
  }

  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
  {
    cell.layoutMargins = .zero
    cell.separatorInset = .zero
    tableView.layoutMargins = .zero
    tableView.separatorInset = .zero
  }
}



//
//  MovieDetailViewController.swift
//  MovieHacker
//
//  Created by Jan Dědeček and Tomaš Novella on 13/08/2017.
//  Copyright © 2017 Jan Dědeček and Tomaš Novella. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {

  var movie: Movie?

  @IBOutlet var movieImageView: UIImageView?
  @IBOutlet var movieDescriptionLabel: UILabel?

  override func viewDidLoad() {
    super.viewDidLoad()
    if let movie = movie {
      // Display detail of the current movie
      navigationItem.title = movie.title
      movieDescriptionLabel?.text = movie.overview

      if let posterUrl = movie.posterUrl {
        loadImage(from: posterUrl) { [weak self] (image) in
          self?.movieImageView?.image = image
        }
      }
    }
  }
}

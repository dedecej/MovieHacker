//
//  MovieDetailViewController.swift
//  MovieHacker
//
//  Created by Jan Dědeček on 13/08/2017.
//  Copyright © 2017 Jan Dědeček. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {

  var movie: Movie?

  @IBOutlet weak var movieImageView: UIImageView?
  @IBOutlet weak var movieDescriptionLabel: UILabel?

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    if let movie = movie {
      //movieImageView.
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

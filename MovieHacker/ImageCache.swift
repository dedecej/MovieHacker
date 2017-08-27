//
//  ImageCache.swift
//  MovieHacker
//
//  Created by Jan Dědeček on 13/08/2017.
//  Copyright © 2017 Jan Dědeček. All rights reserved.
//

import UIKit

private let imageCache = NSCache<NSString, UIImage>()

private var tasks = [URL: (URLSessionDataTask, [(UIImage?) -> Void])]()

func image(from url: URL) -> UIImage? {
  return imageCache.object(forKey: url.absoluteString as NSString)
}

func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
  if let image = imageCache.object(forKey: url.absoluteString as NSString) {
    completion(image)
    return
  }

  if tasks[url] != nil {
    tasks[url]?.1.append(completion)
    return
  }

  print("Loading \(url)")

  let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
    let image: UIImage?
    if (response as? HTTPURLResponse)?.statusCode == 200,
      let data = data,
      let i = UIImage(data: data) {
        image = i
    } else {
      image = nil
      print(response as Any)
    }

    DispatchQueue.main.async {
      if let task = tasks[url] {
        if let image = image {
          imageCache.setObject(image, forKey: url.absoluteString as NSString)
        }
        for completion in task.1 {
          completion(image)
        }
        tasks.removeValue(forKey: url)
      }
    }
  }

  task.resume()
  tasks[url] = (task, [completion])
}

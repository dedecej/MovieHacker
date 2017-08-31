//
//  ImageCache.swift
//  MovieHacker
//
//  Created by Jan Dědeček and Tomaš Novella on 13/08/2017.
//  Copyright © 2017 Jan Dědeček and Tomaš Novella. All rights reserved.
//

import UIKit

// Fetched image cache
private let imageCache = NSCache<NSString, UIImage>()

// Storage of currently performing tasks and theirs completion listeners
private var tasks = [URL: (URLSessionDataTask, [(UIImage?) -> Void])]()

func image(from url: URL) -> UIImage? {
  return imageCache.object(forKey: url.absoluteString as NSString)
}

func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
  // Try to fetch image from the cache
  if let image = imageCache.object(forKey: url.absoluteString as NSString) {
    completion(image)
    return
  }

  // Assign to completion listener into waiters queue
  if tasks[url] != nil {
    tasks[url]?.1.append(completion)
    return
  }

  // We're fetching data, callback is invoked in some background thread. 
  // UI is not thread-safe and can only be manipulated from the main thread. 
  // Therefore we will use dispatch queues from GCD to ensure that the critical code run on main thread.
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
        // Store image into cache and execute waiting listeners
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

  // Start the task
  task.resume()
  tasks[url] = (task, [completion])
}

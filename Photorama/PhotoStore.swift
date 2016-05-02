import UIKit

enum ImageResult {
  case Success(UIImage)
  case Failure(ErrorType)
}

enum PhotoError: ErrorType {
  case ImageCreationError
}

class PhotoStore {
  let session: NSURLSession = {
    let config = NSURLSessionConfiguration.defaultSessionConfiguration()
    return NSURLSession(configuration: config)
  }()
  
  func fetchRecentPhotos(completion completion: (PhotosResult) -> Void) {
    let url = FlickrAPI.recentPhotosURL()
    let request = NSURLRequest(URL: url)
    let task = session.dataTaskWithRequest(request) {
      [unowned self] (data, response, error) in
      
      self.printResponse(response)
      
      let result = self.processRecentPhotosRequest(data: data, error: error)
      completion(result)
    }
    task.resume()
  }
  
  private func printResponse(response: NSURLResponse?) {
    if let response = response as? NSHTTPURLResponse {
      print("\nstatus = \(response.statusCode) \(NSHTTPURLResponse.localizedStringForStatusCode(response.statusCode))")
      print("header fields:")
      response.allHeaderFields.forEach({ (key, value) in
        print("\(key) = \(value)")
      })
      print("\n")
    }
  }
  
  func processRecentPhotosRequest(data data: NSData?, error: NSError?) -> PhotosResult {
    guard let jsonData = data else {
      return .Failure(error!)
    }
    
    return FlickrAPI.photosFromJSONData(jsonData)
  }
  
  func fetchImageForPhoto(photo: Photo, completion: (ImageResult) -> Void) {
    
    if let image = photo.image {
      completion(.Success(image))
      return
    }
    
    let photoURL = photo.remoteURL
    let request = NSURLRequest(URL: photoURL)
    let task = session.dataTaskWithRequest(request) {
      [unowned self] (data, response, error) in
      
      self.printResponse(response)
      
      let result = self.processImageRequest(data: data, error: error)
      if case let .Success(image) = result {
        photo.image = image
      }
      
      completion(result)
    }
    task.resume()
  }
  
  func processImageRequest(data data: NSData?, error: NSError?) -> ImageResult {
    guard let imageData = data, image = UIImage(data: imageData) else {
      if data == nil {
        return .Failure(error!)
      } else {
        return .Failure(PhotoError.ImageCreationError)
      }
    }
    
    return .Success(image)
  }
}

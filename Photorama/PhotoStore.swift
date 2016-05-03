import UIKit
import CoreData

enum ImageResult {
  case Success(UIImage)
  case Failure(ErrorType)
}

enum PhotoError: ErrorType {
  case ImageCreationError
}

class PhotoStore {
  let coreDataStack = CoreDataStack(modelName: "Photorama")
  let imageStore = ImageStore()
  
  let session: NSURLSession = {
    let config = NSURLSessionConfiguration.defaultSessionConfiguration()
    return NSURLSession(configuration: config)
  }()
  
  func fetchRecentPhotos(completion completion: (PhotosResult) -> Void) {
    let url = FlickrAPI.recentPhotosURL()
    let request = NSURLRequest(URL: url)
    let task = session.dataTaskWithRequest(request) {
      [weak self] (data, response, error) in
      guard let strongSelf = self else { return }
      
      //strongSelf.printResponse(response)
      
      var result = strongSelf.processRecentPhotosRequest(data: data, error: error)
      if case let .Success(photos) = result {
        strongSelf.coreDataStack.mainQueueContext.performBlockAndWait() {
          try! strongSelf.coreDataStack.privateQueueContext.obtainPermanentIDsForObjects(photos)
        }
        
        let objectIDs = photos.map{ $0.objectID }
        let predicate = NSPredicate(format: "self IN %@", objectIDs)
        let sortByDateTaken = NSSortDescriptor(key: "dateTaken", ascending: true)
        
        do {
          try strongSelf.coreDataStack.saveChanges()
          
          let mainQueuePhotos = try strongSelf.fetchMainQueuePhotos(predicate: predicate, sortDescriptors: [sortByDateTaken])
          result = .Success(mainQueuePhotos)
        } catch {
          result = .Failure(error)
        }
      }
      
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
    
    return FlickrAPI.photosFromJSONData(jsonData, inContext: coreDataStack.privateQueueContext)
  }
  
  func fetchImageForPhoto(photo: Photo, completion: (ImageResult) -> Void) {
    
    let photoKey = photo.photoKey
    if let image = imageStore.imageForKey(photoKey) {
      photo.image = image
      completion(.Success(image))
      return
    }
    
    let photoURL = photo.remoteURL
    let request = NSURLRequest(URL: photoURL)
    let task = session.dataTaskWithRequest(request) {
      [weak self] (data, response, error) in
      guard let strongSelf = self else { return }
      
      //strongSelf.printResponse(response)
      
      let result = strongSelf.processImageRequest(data: data, error: error)
      if case let .Success(image) = result {
        photo.image = image
        strongSelf.imageStore.setImage(image, forKey: photoKey)
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
  
  func fetchMainQueuePhotos(predicate predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) throws -> [Photo] {
    let fetchRequest = NSFetchRequest(entityName: "Photo")
    fetchRequest.predicate = predicate
    fetchRequest.sortDescriptors = sortDescriptors
    
    let mainQueueContext = coreDataStack.mainQueueContext
    var mainQueuePhotos: [Photo]?
    var fetchRequestError: ErrorType?
    
    mainQueueContext.performBlockAndWait() {
      do {
        mainQueuePhotos = try mainQueueContext.executeFetchRequest(fetchRequest) as? [Photo]
      } catch {
        fetchRequestError = error
      }
    }
    
    guard let photos = mainQueuePhotos else {
      throw fetchRequestError!
    }
    
    return photos
  }
  
  func fetchMainQueueTags(predicate predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) throws -> [NSManagedObject] {
    let fetchRequest = NSFetchRequest(entityName: "Tag")
    fetchRequest.predicate = predicate
    fetchRequest.sortDescriptors = sortDescriptors
    
    let mainQueueContext = coreDataStack.mainQueueContext
    var mainQueueTags: [NSManagedObject]?
    var fetchError: ErrorType?
    
    mainQueueContext.performBlockAndWait() {
      do {
        mainQueueTags = try mainQueueContext.executeFetchRequest(fetchRequest) as? [NSManagedObject]
      } catch {
        fetchError = error
      }
    }
    
    guard let tags = mainQueueTags else {
      throw fetchError!
    }
    
    return tags
  }
  
  func save() {
    do {
      try coreDataStack.saveChanges()
    } catch {
      print("error saving: \(error)")
    }
  }
}

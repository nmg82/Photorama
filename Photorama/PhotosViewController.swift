import UIKit

class PhotosViewController: UIViewController {
  @IBOutlet var imageView: UIImageView!
  var store: PhotoStore!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    store.fetchRecentPhotos() {
      [unowned self] result in
      
      switch result {
      case let .Success(photos):
        print("successfully found \(photos.count) recent photos")
        
        if let firstPhoto = photos.first {
          self.store.fetchImageForPhoto(firstPhoto, completion: { (result) in
            switch result {
            case let .Success(image):
              NSOperationQueue.mainQueue().addOperationWithBlock({ 
                self.imageView.image = image
              })
            case let .Failure(error):
              print("error downloading image: \(error)")
            }
          })
        }
      case let .Failure(error):
        print("error fetching recent photos: \(error)")
      }
    }
  }
}
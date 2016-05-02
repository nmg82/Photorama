import UIKit

class PhotoInfoViewController: UIViewController {
  @IBOutlet var imageView: UIImageView!
  
  var store: PhotoStore!
  var photo: Photo! {
    didSet {
      navigationItem.title = photo.title
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    store.fetchImageForPhoto(photo) { (result) in
      switch result {
      case let .Success(image):
        NSOperationQueue.mainQueue().addOperationWithBlock({ 
          [unowned self] in
          self.imageView.image = image
        })
      case let .Failure(error):
        print("error fetching image for photo: \(error)")
      }
    }
  }
}

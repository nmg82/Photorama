import UIKit

class PhotoInfoViewController: UIViewController {
  @IBOutlet var imageView: UIImageView!
  @IBOutlet var favoriteButton: UIBarButtonItem!
  
  var store: PhotoStore!
  var photo: Photo! {
    didSet {
      navigationItem.title = photo.title
      photo.viewCount += 1
      navigationItem.prompt = "\(photo.viewCount) total views"
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    store.fetchImageForPhoto(photo) { (result) in
      switch result {
      case let .Success(image):
        NSOperationQueue.mainQueue().addOperationWithBlock({ 
          [weak self] in
          guard let strongSelf = self else { return }
          strongSelf.imageView.image = image
        })
      case let .Failure(error):
        print("error fetching image for photo: \(error)")
      }
    }
    
    if photo.favorite {
      favoriteButton.title = "Remove Favorite"
    } else {
      favoriteButton.title = "Favorite"
    }
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    store.save()
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ShowTags" {
      let navigationControler = segue.destinationViewController as! UINavigationController
      let tagController = navigationControler.topViewController as! TagsViewController
      tagController.store = store
      tagController.photo = photo
    }
  }
  
  @IBAction func favoriteTapped(sender: UIBarButtonItem) {
    photo.favorite = !photo.favorite
    
    if photo.favorite {
      sender.title = "Remove Favorite"
    } else {
      sender.title = "Favorite"
    }
  }
}

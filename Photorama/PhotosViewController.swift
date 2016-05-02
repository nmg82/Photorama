import UIKit

class PhotosViewController: UIViewController {
  @IBOutlet var collectionView: UICollectionView!
  
  var store: PhotoStore!
  let photoDataSource = PhotoDataSource()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView.dataSource = photoDataSource
    collectionView.delegate = self
    
    store.fetchRecentPhotos() {
      [unowned self] result in
      
      switch result {
      case let .Success(photos):
        self.photoDataSource.photos = photos
      case let .Failure(error):
        self.photoDataSource.photos.removeAll()
        print("error fetching recent photos: \(error)")
      }
      
      NSOperationQueue.mainQueue().addOperationWithBlock({ 
        self.collectionView.reloadSections(NSIndexSet(index: 0))
      })
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ShowPhoto" {
      if let selectedIndexPath = collectionView.indexPathsForSelectedItems()?.first {
        let photo = photoDataSource.photos[selectedIndexPath.row]
        let photoInfoViewController = segue.destinationViewController as! PhotoInfoViewController
        photoInfoViewController.photo = photo
        photoInfoViewController.store = store
      }
    }
  }
}

extension PhotosViewController: UICollectionViewDelegate {
  func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
    let photo = photoDataSource.photos[indexPath.row]
    
    //download the image data, which could take some time
    store.fetchImageForPhoto(photo) {
      [unowned self] (result) in
      
      NSOperationQueue.mainQueue().addOperationWithBlock({
        //the index path for the photo might have changed between 
        //the time the request started and finished, so find the most
        //recent index path
        let photoIndex = self.photoDataSource.photos.indexOf(photo)!
        let photoIndexPath = NSIndexPath(forRow: photoIndex, inSection: 0)
        
        if let cell = self.collectionView.cellForItemAtIndexPath(photoIndexPath) as? PhotoCollectionViewCell {
          cell.updateWithImage(photo.image)
        }
      })
    }
  }
}


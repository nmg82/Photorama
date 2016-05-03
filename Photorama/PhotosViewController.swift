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
      [weak self] result in
      guard let strongSelf = self else { return }
      
      switch result {
      case let .Success(photos):
        strongSelf.photoDataSource.photos = photos
      case let .Failure(error):
        strongSelf.photoDataSource.photos.removeAll()
        print("error fetching recent photos: \(error)")
      }
      
      NSOperationQueue.mainQueue().addOperationWithBlock({ 
        strongSelf.collectionView.reloadData()
      })
    }
  }
  
  override func viewDidLayoutSubviews() {
    collectionView.reloadData()
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
      [weak self] (result) in
      guard let strongSelf = self else { return }
      
      NSOperationQueue.mainQueue().addOperationWithBlock({
        //the index path for the photo might have changed between 
        //the time the request started and finished, so find the most
        //recent index path
        let photoIndex = strongSelf.photoDataSource.photos.indexOf(photo)!
        let photoIndexPath = NSIndexPath(forRow: photoIndex, inSection: 0)
        
        if let cell = strongSelf.collectionView.cellForItemAtIndexPath(photoIndexPath) as? PhotoCollectionViewCell {
          cell.updateWithImage(photo.image)
        }
      })
    }
  }
}

extension PhotosViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    
    let numberOfColumns: CGFloat = 4
    let viewFrameWidth = self.view.frame.width
    let padding:CGFloat = 3 
    
    let width = (viewFrameWidth / numberOfColumns) - padding
    let height = width
    
    return CGSize(width: width, height: height)
  }
}


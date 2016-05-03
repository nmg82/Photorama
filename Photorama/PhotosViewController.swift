import UIKit

class PhotosViewController: UIViewController {
  @IBOutlet var collectionView: UICollectionView!
  
  var store: PhotoStore!
  let photoDataSource = PhotoDataSource()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView.dataSource = photoDataSource
    collectionView.delegate = self
    
    fetchRecentPhotos()
  }
  
  private func fetchRecentPhotos() {
    fetchPhotos()
  }
  
  private func fetchFavoritePhotos() {
    let predicate = NSPredicate(format: "favorite == true")
    fetchPhotos(predicate: predicate)
  }
  
  private func fetchPhotos(predicate predicate: NSPredicate? = nil) {
    store.fetchRecentPhotos() {
      [weak self] result in
      guard let strongSelf = self else { return }
      
      let sortByDateTaken = NSSortDescriptor(key: "dateTaken", ascending: true)
      let favoritePhotos = try! strongSelf.store.fetchMainQueuePhotos(predicate: predicate, sortDescriptors: [sortByDateTaken])
      
      NSOperationQueue.mainQueue().addOperationWithBlock() {
        strongSelf.photoDataSource.photos = favoritePhotos
        strongSelf.collectionView.reloadData()
      }
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
  
  @IBAction func filterPhotosControlChanged(sender: UISegmentedControl) {
    switch sender.selectedSegmentIndex {
    case 0:
      fetchRecentPhotos()
    default:
      fetchFavoritePhotos()
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
    let viewFrameWidth = view.frame.width
    let padding:CGFloat = 3 
    
    let width = (viewFrameWidth / numberOfColumns) - padding
    let height = width
    
    return CGSize(width: width, height: height)
  }
}


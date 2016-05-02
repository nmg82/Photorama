import UIKit

class PhotoDataSource: NSObject, UICollectionViewDataSource {
  var photos = [Photo]()
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return photos.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("UICollectionViewCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
    let photo = photos[indexPath.row]
    cell.updateWithImage(photo.image)
    return cell
  }
}

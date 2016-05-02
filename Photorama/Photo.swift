import UIKit

class Photo {
  let title: String
  let remoteURL: NSURL
  let photoID: String
  let dateTaken: NSDate
  var image: UIImage?
  
  init(title: String, remoteURL: NSURL, let photoID: String, let dateTaken: NSDate) {
    self.title = title
    self.remoteURL = remoteURL
    self.photoID = photoID
    self.dateTaken = dateTaken
  }
}

//MARK: - Equatable
extension Photo: Equatable {}
func == (lhs: Photo, rhs: Photo) -> Bool {
  return lhs.photoID == rhs.photoID
}

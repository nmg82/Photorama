import Foundation
import CoreData
import UIKit

class Photo: NSManagedObject {

  var image: UIImage?
  
  override func awakeFromInsert() {
    super.awakeFromInsert()
    
    title = ""
    photoID = ""
    remoteURL = NSURL()
    photoKey = NSUUID().UUIDString
    dateTaken = NSDate()
    viewCount = 0
  }
  
  func addTagObject(tag: NSManagedObject) {
    let currentTags = mutableSetValueForKey("tags")
    currentTags.addObject(tag)
  }
  
  func removeTagObject(tag: NSManagedObject) {
    let currentTags = mutableSetValueForKey("tags")
    currentTags.removeObject(tag)
  }
  
}

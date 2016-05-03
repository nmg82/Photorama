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
  }
  
}

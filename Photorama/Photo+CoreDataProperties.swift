import Foundation
import CoreData

extension Photo {
  
  @NSManaged var favorite: Bool
  @NSManaged var dateTaken: NSDate
  @NSManaged var photoID: String
  @NSManaged var photoKey: String
  @NSManaged var remoteURL: NSURL
  @NSManaged var title: String
  @NSManaged var viewCount: Int32
  @NSManaged var tags: Set<NSManagedObject>
  
}

import CoreData

class CoreDataStack {
  
  let managedObjectModelName: String
  private lazy var managedObjectModel: NSManagedObjectModel = {
    let modelURL = NSBundle.mainBundle().URLForResource(self.managedObjectModelName, withExtension: "momd")!
    return NSManagedObjectModel(contentsOfURL: modelURL)!
  }()
  
  private let applicationDocumentsDirectory: NSURL = {
    let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    return urls.first!
  }()
  
  private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
    
    let pathComponent = "\(self.managedObjectModelName).sqlite"
    let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(pathComponent)
    let store = try! coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
    
    return coordinator
  }()
  
  required init(modelName: String) {
    managedObjectModelName = modelName
  }
  
  lazy var mainQueueContext: NSManagedObjectContext = {
    let moc = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    moc.persistentStoreCoordinator = self.persistentStoreCoordinator
    moc.name = "Main Queue Context (UI Context)"
    return moc
  }()
  
  func saveChanges() throws {
    var error: ErrorType?
    mainQueueContext.performBlockAndWait() {
      if self.mainQueueContext.hasChanges {
        do {
          try self.mainQueueContext.save()
        } catch let saveError {
          error = saveError
        }
      }
    }
    
    if let error = error {
      throw error
    }
  }
}

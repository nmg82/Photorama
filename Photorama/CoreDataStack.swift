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
  
  lazy var privateQueueContext: NSManagedObjectContext = {
    let moc = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
    moc.parentContext = self.mainQueueContext
    moc.name = "Primary Private Queue Context"
    return moc
  }()
  
  func saveChanges() throws {
    var error: ErrorType?
    
    privateQueueContext.performBlockAndWait() {
      [weak self] in
      guard let strongSelf = self else { return }
      
      if strongSelf.privateQueueContext.hasChanges {
        do {
          try strongSelf.privateQueueContext.save()
        } catch let saveError {
          error = saveError
        }
      }
    }
    
    if let error = error {
      throw error
    }
    
    mainQueueContext.performBlockAndWait() {
      [weak self] in
      guard let strongSelf = self else { return }
      
      if strongSelf.mainQueueContext.hasChanges {
        do {
          try strongSelf.mainQueueContext.save()
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

import UIKit
import CoreData

class TagsDataSource: NSObject, UITableViewDataSource {
  var tags: [NSManagedObject] = []
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tags.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCell", forIndexPath: indexPath)
    let tag = tags[indexPath.row]
    let name = tag.valueForKey("name") as! String
    cell.textLabel?.text = name
    
    return cell
  }
}

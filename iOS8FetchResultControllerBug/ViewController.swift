//
//  ViewController.swift
//  iOS8FetchResultControllerBug
//
//  Created by Yu, William on 8/17/16.
//  Copyright © 2016 iwllyu. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var tableView: UITableView!
    private static let reuseId = "NotificationCell"
    
    private lazy var frc: NSFetchedResultsController = {
        let request = NSFetchRequest(entityName: Item.entityName())
        request.sortDescriptors = [
            NSSortDescriptor(key: ItemAttributes.date.rawValue, ascending: false)
        ]
        request.fetchBatchSize = 10
        
        let moc = self.appDelegate.managedObjectContext
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: ItemAttributes.date_section_title.rawValue, cacheName: nil)
        frc.delegate = self
        
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notifications"
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        do {
            try frc.performFetch()
        } catch {
            NSLog("Failed to fetch from fetchedResultsController: \(error)")
        }
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK: -
//MARK: UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let notification = frc.objectAtIndexPath(indexPath) as? StoredNotification
        
        if let notification = notification {
            notification.isRead = true
            appDelegate.saveContext()
            
            NextViewController.pushViewController(notification)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        //        UIStyles.styleTableSectionHeader(view)
    }
}


//MARK: -
//MARK: UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = frc.sections where sections.count > 0 {
            return sections.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = frc.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let orginalDateString = frc.sections?[section].name
        return NSDate.getStorageDate(orginalDateString)?.getDisplayString()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ViewController.reuseId, forIndexPath: indexPath) as! NotificationCell
        
        configureCell(cell, atIndexPath: indexPath)
        cell.updateConstraintsIfNeeded() //multi line labels on iOS8
        
        return cell
    }
    
    func configureCell(cell: NotificationCell, atIndexPath indexPath: NSIndexPath) {
        // Fetch Record
        let storedNotification = frc.objectAtIndexPath(indexPath) as? StoredNotification
        cell.configureCell(storedNotification)
    }
    
    //Swipe/slide to delete
    //    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    //        if editingStyle == .Delete {
    //            if var sn = frc.objectAtIndexPath(indexPath) as? StoredNotification {
    //                sn.isDeleted_ = true
    //                appDelegate.saveContext()
    //
    //            } else {
    //                log.error("Could not cast object to StoredNotification")
    //            }
    //
    //        }
    //    }
}


//MARK: -
//MARK: NSFetchedResultsControllerDelegate
extension ViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        log.info("begin updates")
        //        let request = NSFetchRequest(entityName: StoredNotification.entityName())
        //        request.sortDescriptors = [
        //            NSSortDescriptor(key: StoredNotificationAttributes.date_notified.rawValue, ascending: false)
        //        ]
        //        do{
        //            let fetchedObjects = try appDelegate.managedObjectContext.executeFetchRequest(request) as? [StoredNotification]
        //            if let fetchedObjects = fetchedObjects {
        //                for object in fetchedObjects {
        //                    log.debug(object)
        //                }
        //            }
        //        } catch {
        //            log.error(error)
        //        }
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
        log.info("end updates")
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        let typeString: String = {
            switch type {
            case .Insert:
                return "Insert"
            case .Delete:
                return "Delete"
            case .Update:
                return "Update"
            case .Move:
                return "Move"
            }
        }()
        let message = (anObject as! StoredNotification).message
        log.info("anObject: \(message), indexPath: \(indexPath), newIndexPath: \(newIndexPath), type: \(typeString)")
        switch (type) {
        case .Insert:
            if let indexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
        case .Delete:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
        case .Update:
            if let indexPath = indexPath {
                //                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! NotificationCell
                configureCell(cell, atIndexPath: indexPath)
            }
        case .Move:
            guard let indexPath = indexPath, newIndexPath = newIndexPath else {
                return
            }
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .None)
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        let typeString: String = {
            switch type {
            case .Insert:
                return "Insert"
            case .Delete:
                return "Delete"
            case .Update:
                return "Update"
            case .Move:
                return "Move"
            }
        }()
        log.info("sectionInfo: \(sectionInfo), sectionIndex: \(sectionIndex), type: \(typeString)")
        switch (type) {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Move:
            //            log.info("Move Section \(sectionIndex) sectionInfo: \(sectionInfo)")
            break;
        case .Update:
            //            log.info("Update Section \(sectionIndex) sectionInfo: \(sectionInfo)")
            break;
            
        }
    }
}


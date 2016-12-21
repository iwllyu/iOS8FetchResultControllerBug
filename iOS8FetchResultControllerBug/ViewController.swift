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
    private static let reuseId = "ItemCell"
    
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
        title = "Items"
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
    
    //MARK: Toolbar Actions
    
    @IBAction func addItem(sender: AnyObject) {
        itemService.addItem(NSDate())
    }
}

//MARK: -
//MARK: UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSLog("didSelectRowAtIndexPath \(indexPath)")
        let item = frc.objectAtIndexPath(indexPath) as? Item
        
        if let item = item {
            item.isRead = true
            appDelegate.saveContext()
            
            NextViewController.pushViewController(item)
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
            NSLog("numberOfSectionsInTableView \(sections.count)")
            return sections.count
        }
        NSLog("numberOfSectionsInTableView fall through")
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let sections = frc.sections {
            let sectionInfo = sections[section]
            NSLog("numberOfRowsInSection \(section): \(sectionInfo.numberOfObjects)")
            return sectionInfo.numberOfObjects
        }
        NSLog("numberOfRowsInSection fall through")
        return 0
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let dateString = frc.sections?[section].name {
            return dateString
        } else {
            return "Could Not Find titleForHeaderInSection"
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ViewController.reuseId, forIndexPath: indexPath) as! ItemCell
        
        configureCell(cell, atIndexPath: indexPath)
        cell.updateConstraintsIfNeeded() //multi line labels on iOS8
        
        return cell
    }
    
    func configureCell(cell: ItemCell, atIndexPath indexPath: NSIndexPath) {
        // Fetch Record
        let item = frc.objectAtIndexPath(indexPath) as? Item
        cell.configureCell(item)
    }
}


//MARK: -
//MARK: NSFetchedResultsControllerDelegate
extension ViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        NSLog("controllerWillChangeContent")
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
        NSLog("controllerDidChangeContent")
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
        let message = (anObject as! Item).message
        NSLog("type: \(typeString): anObject: \(message), indexPath: \(indexPath), newIndexPath: \(newIndexPath)")
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
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! ItemCell
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
        NSLog("sectionInfo: \(sectionInfo), sectionIndex: \(sectionIndex), type: \(typeString)")
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


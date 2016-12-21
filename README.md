# iOS8FetchResultControllerBug

This project demonstrates a bug with fetched result controller and UITableView on iOS 8.0-8.4

## Getting Started

Env: This was written in Xcode 7.3.1 in Swift 2.2. You can check swift version with `xcrun swift -version`

1. Clone this project
2. Run this project on a iOS8 device, or an iOS 8 simulator. To download iOS8 simulators go to Xcode -> Preferences -> Components -> select and download simulator
3. When the project is launched, notice the UITB has 6 items.
4. Tap any of the items, you will be taken to another view controller with information of the item
5. Note the error in the console 
> 2016-12-21 15:29:42.009 iOS8FetchResultControllerBug[10548:2541664] CoreData: error: Serious application error.  Exception was caught during Core Data change processing.  This is usually a bug within an observer of NSManagedObjectContextObjectsDidChangeNotification.  Invalid update: invalid number of rows in section 0.  The number of rows contained in an existing section after the update (6) must be equal to the number of rows contained in that section before the update (6), plus or minus the number of rows inserted or deleted from that section (1 inserted, 0 deleted) and plus or minus the number of rows moved into or out of that section (0 moved in, 0 moved out). with userInfo (null)
6. Behavior of the table is now unexpected. Adding items doesn't update the table, tapping an item will open another item. It appears as though the visible table is not updating with the FRC.

## The Bug

1. Tap an item
2. didSelectRowAtIndexPath updates the item to is_read = true and saves the context
3. NSFetchedResultControllerDelegate updates the cell, as expected 
> 2016-12-21 16:03:45.167 iOS8FetchResultControllerBug[11791:2569368] type: Update: anObject: Optional("Message 3"), indexPath: Optional(<NSIndexPath: 0xc000000000018016> {length = 2, path = 0 - 3}), newIndexPath: nil
4. NSFetchedResultControllerDelegate also tries to do an insert, which causes the NSInternalInconsistencyException
> 2016-12-21 16:03:45.167 iOS8FetchResultControllerBug[11791:2569368] type: Insert: anObject: Optional("Message 3"), indexPath: Optional(<NSIndexPath: 0xc000000000018016> {length = 2, path = 0 - 3}), newIndexPath: Optional(<NSIndexPath: 0xc000000000018016> {length = 2, path = 0 - 3})

## Workarounds?

I could just reload the entire table instead of relying on `didChangeObject`, probably
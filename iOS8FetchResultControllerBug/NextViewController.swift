//
//  NextViewController.swift
//  iOS8FetchResultControllerBug
//
//  Created by Yu, William on 12/10/16.
//  Copyright © 2016 iwllyu. All rights reserved.
//

import UIKit

import UIKit

class NextViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var isRead: UILabel!
    
    var item: Item?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure(item)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configure(item: Item?) {
        guard let item = item else {
            NSLog("item was nil")
            return
        }
        
        titleLabel.text = item.title
        messageLabel.text = item.message
        isRead.text = String(item.isRead)
    }
    
    
    static func pushViewController(item: Item?) -> NextViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: NextViewController = storyboard.instantiateViewControllerWithIdentifier("NextViewController") as! NextViewController
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        (appDelegate.window?.rootViewController as! UINavigationController).pushViewController(vc, animated: true)
        vc.item = item
        return vc
    }
    
    
}
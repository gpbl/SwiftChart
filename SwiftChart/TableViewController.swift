//
//  TableViewController.swift
//  SwiftChart
//
//  Created by Giampaolo Bellavite on 15/11/14.
//  Copyright (c) 2014 Giampaolo Bellavite. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, UITableViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("ChartSegue", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let indexPath = tableView.indexPathForSelectedRow()
        let dvc = segue.destinationViewController as ChartViewController
        dvc.selectedChart = indexPath!.row
    }
    
}

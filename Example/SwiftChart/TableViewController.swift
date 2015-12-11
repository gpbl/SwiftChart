//
//  TableViewController.swift
//  SwiftChart
//
//  Created by Giampaolo Bellavite on 15/11/14.
//  Copyright (c) 2014 Giampaolo Bellavite. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 4 {
            performSegueWithIdentifier("StockChartSegue", sender: nil)
        }
        else {
            performSegueWithIdentifier("BasicChartSegue", sender: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "BasicChartSegue" {
            let indexPath = tableView.indexPathForSelectedRow
            let dvc = segue.destinationViewController as! BasicChartViewController
            dvc.selectedChart = indexPath!.row
        }
    }
    
}

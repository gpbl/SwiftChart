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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row == 4 {
            performSegue(withIdentifier: "StockChartSegue", sender: nil)
        }
        else {
            performSegue(withIdentifier: "BasicChartSegue", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BasicChartSegue" {
            let indexPath = tableView.indexPathForSelectedRow
            let dvc = segue.destination as! BasicChartViewController
            dvc.selectedChart = (indexPath! as NSIndexPath).row
        }
    }
    
}

//
//  MainMenuTableViewController.swift
//  InterviewProject
//
//  Created by Stephen Murphy on 1/24/16.
//  Copyright © 2016 Stephen Murphy. All rights reserved.
//

import UIKit

class MainMenuTableViewController: UITableViewController {
    var selectedIndex = 0
    
    let cityArray = ["Charlotte", "Boston", "Seattle"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath)
        cell.textLabel?.text = cityArray[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndex = indexPath.row
        performSegueWithIdentifier("WeatherSegue", sender: self)
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "WeatherSegue" {
            if let destinationViewController = segue.destinationViewController as? WeatherViewController {
                destinationViewController.cityName = cityArray[selectedIndex]
            }
        }
    }
}

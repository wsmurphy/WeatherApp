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
    
    let cityArray = ["Charlotte", "Boston", "Seattle", "dfghjgfdh"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath)
        cell.textLabel?.text = cityArray[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "WeatherSegue", sender: self)
        
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "WeatherSegue" {
            if let destinationViewController = segue.destination as? WeatherViewController {
                destinationViewController.cityName = cityArray[selectedIndex]
            }
        }
    }
}

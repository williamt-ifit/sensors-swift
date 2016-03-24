//
//  SensorListViewController.swift
//  SwiftySensorsExample
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2016 Kinetic. All rights reserved.
//

import UIKit
import SwiftySensors

class SensorListViewController: UITableViewController {
    
    private var sensors: [Sensor] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SensorManager.instance.onSensorDiscovered.listen(self) { [weak self] sensor in
            guard let s = self else { return }
            if !s.sensors.contains(sensor) {
                s.sensors.append(sensor)
                s.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        sensors = SensorManager.instance.sensors
        tableView.reloadData()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sensors.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let sensorCell = tableView.dequeueReusableCellWithIdentifier("SensorCell")!
        let sensor = sensors[indexPath.row]
        sensorCell.textLabel?.text = sensor.peripheral.name
        return sensorCell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let sensorDetails = segue.destinationViewController as? SensorDetailsViewController {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            if indexPath.row >= sensors.count { return }
            sensorDetails.sensor = sensors[indexPath.row]
        }
    }
    
}


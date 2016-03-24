//
//  SensorDetailsViewController.swift
//  SwiftySensors
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2016 Kinetic. All rights reserved.
//

import UIKit
import SwiftySensors

class SensorDetailsViewController: UIViewController {
    
    var sensor: Sensor!
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var connectButton: UIButton!
    @IBOutlet var tableView: UITableView!
    
    private var services: [Service] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sensor.onServiceDiscovered.listen(self) { [weak self] sensor, service in
            guard let s = self else { return }
            s.rebuildData()
        }
        sensor.onStateChanged.listen(self) { [weak self] sensor in
            self?.updateConnectButton()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        nameLabel.text = sensor.peripheral.name
        updateConnectButton()
        
        rebuildData()
    }
    
    private func rebuildData() {
        services = Array(sensor.services.values)
        tableView.reloadData()
    }
    
    private func updateConnectButton() {
        switch sensor.peripheral.state {
        case .Connected:
            connectButton.setTitle("Connected", forState: .Normal)
            connectButton.enabled = true
        case .Connecting:
            connectButton.setTitle("Connecting", forState: .Normal)
            connectButton.enabled = false
        case .Disconnected:
            connectButton.setTitle("Disconnected", forState: .Normal)
            connectButton.enabled = true
            
            rebuildData()
        case .Disconnecting:
            connectButton.setTitle("Disconnecting", forState: .Normal)
            connectButton.enabled = false
        }
    }
    
    @IBAction func connectButtonHandler(sender: AnyObject) {
        if sensor.peripheral.state == .Connected {
            SensorManager.instance.disconnectFromSensor(sensor)
        } else if sensor.peripheral.state == .Disconnected {
            SensorManager.instance.connectToSensor(sensor)
        }
            
    }
}



extension SensorDetailsViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let serviceCell = tableView.dequeueReusableCellWithIdentifier("ServiceCell")!
        let service = services[indexPath.row]
        
        serviceCell.textLabel?.text = "\(service)"
        return serviceCell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }
}

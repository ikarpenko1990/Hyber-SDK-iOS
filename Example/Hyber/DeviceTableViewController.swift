//
//  DeviceTableViewController.swift
//  Hyber
//
//  Created by Taras on 12/12/16.
//  Copyright © 2016 Incuube. All rights reserved.
//

import UIKit
import Hyber
import RealmSwift

class DeviceTableViewController: UITableViewController {
    let realm = try! Realm()
    var deviceList: Results<Device>!
    
    @IBAction func logoutAction(_ sender: Any) {
        Hyber.LogOut()
    }

    @IBOutlet var deviceListsTableView: UITableView!

    
    func readAndUpdateUI() {
        deviceList = realm.objects(Device.self)
        self.deviceListsTableView.setEditing(false, animated: true)
        self.deviceListsTableView.reloadData()
       
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        firtLoadView()
        deviceListsTableView.es_addPullToRefresh {
            [weak self] in
         self?.loadDeviceList()
        }
        
    }
    
    func firtLoadView() {
        if UserDefaults.standard.object(forKey: "firtsLoadDevice") == nil {
            loadDeviceList()
            UserDefaults.standard.set("loaded", forKey: "firtsLoadDevice")
            UserDefaults.standard.synchronize()
        } else {
            readAndUpdateUI()
        }
    }
    
    
    func loadDeviceList() {
        Hyber.getDeviceList(completionHandler: { (success) -> Void in
            if success {
                self.readAndUpdateUI()
                self.deviceListsTableView.es_stopPullToRefresh(completion: true)
            } else {
                self.deviceListsTableView.es_stopPullToRefresh(completion: false)
                self.getErrorAlert()
            }
        })

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    //MARK: - TABLE VIEW Controller
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let lists = deviceList {
            return lists.count
        }
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell", for: indexPath) as? DeviceTableViewCell
        if (cell != nil) {
            let list = self.deviceList[indexPath.row]
            cell?.DeviceName.text = list.value(forKey: "deviceName") as! String?
            cell?.deviceId.text = list.value(forKey: "deviceId") as! String?
            let ios = "ios"
            let type = list.value(forKey: "osType") as! String?
                if type == ios {
                    cell?.osTypeImage.image = UIImage(named: "iosIcon")
                } else {
                    cell?.osTypeImage.image = UIImage(named: "androidIcon")
                }
            
            cell?.osVersion.text = list.value(forKey: "osVersion") as! String?
        
            let phone = "phone"
            let typeDevice = list.value(forKey: "deviceType") as! String?
            
             if typeDevice == phone {
                cell?.deviceTypeImage.image = UIImage(named: "iPhone")
             } else {
                cell?.deviceTypeImage.image = UIImage(named: "tablet")
             }
            
            cell?.updateDevice.text = list.value(forKey:"updatedAt") as! String?
            
            DispatchQueue.main.async {
                let active = list.value(forKey: "isActive") as! Bool?
                    if active == true {
                        cell?.currentDevice.isHidden = false
                    } else {
                    cell?.currentDevice.isHidden = true
                    }
                }
            }
        
        return cell!
    }
    

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    


    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alertController = UIAlertController(title: "ATTENTION", message: "You are sure to delete device?", preferredStyle: .alert)
            let devices = deviceList[indexPath.row]
            let confirmAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
                Hyber.revokeDevice(deviceId:[devices.value(forKey: "deviceId") as Any] , completionHandler: { (success) -> Void in
                        if success {
                        } else {
                            Hyber.getDeviceList(completionHandler:{(success) -> Void in
                                if success{
                                self.deviceListsTableView.reloadData()
                                }
                            })
                        }
                    })
                }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
                alertController.addAction(confirmAction)
                alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
   
    //MARK: - Data Function
    
    func getErrorAlert() {
        let alertController = UIAlertController(title: "Network error", message: "Something wrong. Please try later", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel) { (_) in }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }

}

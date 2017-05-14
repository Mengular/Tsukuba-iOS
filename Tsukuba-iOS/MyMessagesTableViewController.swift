//
//  MyMessagesTableViewController.swift
//  Tsukuba-iOS
//
//  Created by lidaye on 10/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import UIKit
import ESPullToRefresh

class MyMessagesTableViewController: UITableViewController {
    
    var sell = true
    
    let messageManager = MessageManager.sharedInstance
    var messages: [Message] = []
    var selectedMessage: Message!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setCustomBack()
        self.navigationItem.title = sell ? "My sell post" : "My buy post"
        
        tableView.es_addPullToRefresh {
            // action to be performed (pull data from some source)
            self.messageManager.loadMyMessage(self.sell) { (success, messages) in
                self.messages = messages
                self.tableView.reloadData()
                self.tableView.es_stopPullToRefresh()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.es_startPullToRefresh()
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editMessageSegue" {
            segue.destination.setValue(selectedMessage.mid, forKey: "messageId")
        }
    }

    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myMessageCell", for: indexPath) as! MyMessageTableViewCell
        cell.fillWithMessage(messages[indexPath.row])
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedMessage = messages[indexPath.row]
        self.performSegue(withIdentifier: "editMessageSegue", sender: self)
    }

    // MARK: - Action
    @IBAction func changeMessageType(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            sell = true
        case 1:
            sell = false
        default:
            break
        }
        tableView.es_startPullToRefresh()
    }

}
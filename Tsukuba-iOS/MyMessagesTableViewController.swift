//
//  MyMessagesTableViewController.swift
//  Tsukuba-iOS
//
//  Created by lidaye on 10/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import UIKit
import DGElasticPullToRefresh

class MyMessagesTableViewController: UITableViewController {
    
    var sell = true
    
    let messageManager = MessageManager.sharedInstance
    var messages: [Message] = []

    deinit {
        self.tableView?.dg_removePullToRefresh()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = sell ? "My sell post" : "My buy post"
        setDGElasticPullToRefresh()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func setDGElasticPullToRefresh() {
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor.lightGray
        self.tableView?.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            self?.messageManager.loadMyMessage((self?.sell)!) { (success, messages) in
                self?.messages = messages
                self?.tableView.reloadData()
                self?.tableView.dg_stopLoading()
            }
        }, loadingView: loadingView)
        self.tableView?.dg_setPullToRefreshFillColor(UIColor.red)
        self.tableView?.dg_setPullToRefreshBackgroundColor((self.tableView?.backgroundColor)!)
    }

}

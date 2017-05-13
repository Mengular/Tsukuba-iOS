//
//  PostViewController.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 07/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import UIKit
import Eureka
import NVActivityIndicatorView

class CreateMessageViewController: FormViewController, NVActivityIndicatorViewable {

    let dao = DaoManager.sharedInstance
    let messgaeManager = MessageManager.sharedInstance
    
    var category: Category!
    var selections: [Selection]!
    
    var selectionSections: [SelectableSection<ListCheckRow<String>>]! = []
    var messageTitle: String?
    var sell = true
    var price = 0
    var introduction = ""
    
    var mid: String!
    
    var navigationOptionsBackup : RowNavigationOptions?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        selections = dao.selectionDao.findEnableByCategory(category)
        
        self.setCustomBack()
        self.view.tintColor = Color.main
        ListCheckRow<String>.defaultCellSetup = { cell, row in
            cell.tintColor = Color.main
        }
        
        navigationOptions = RowNavigationOptions.Enabled.union(.SkipCanNotBecomeFirstResponderRow)
        navigationOptionsBackup = navigationOptions
        
        form
            +++ Section(NSLocalizedString("message_basic_info", comment: ""))
            
            <<< SegmentedRow<String>() {
                $0.title = NSLocalizedString("message_type_choose", comment: "")
                $0.options = [NSLocalizedString("message_type_sell", comment: ""), NSLocalizedString("message_type_buy", comment: "")]
                $0.value = NSLocalizedString("message_type_sell", comment: "")
            }.onChange({ (row) in
                self.sell = (row.value! == NSLocalizedString("message_type_sell", comment: ""))
            })
            
            <<< TextRow() {
                $0.title = NSLocalizedString("message_title", comment: "")
                $0.placeholder = NSLocalizedString("message_title_placeholder", comment: "")
            }.onChange({ (row) in
                self.messageTitle = row.value
            })
        
            <<< IntRow(){
                $0.title = NSLocalizedString("message_price", comment: "")
                $0.placeholder = "0"
            }.onChange({ (row) in
                self.price = row.value ?? 0
            })
        
            <<< TextAreaRow() {
                $0.placeholder = NSLocalizedString("message_introduction_placeholder", comment: "")
            }.onChange({ (row) in
                self.introduction = row.value ?? ""
            })
        
        for selection in selections {
            let selectionSection = SelectableSection<ListCheckRow<String>>(selection.identifier!,
                                                                           selectionType: .singleSelection(enableDeselection: true))
            for option in dao.optionDao.findEnableBySelection(selection) {
                selectionSection <<< ListCheckRow<String>() { row in
                    row.title = option.identifier
                    row.selectableValue = option.oid
                }
            }
            form +++ selectionSection
            selectionSections.append(selectionSection)
        }

    }

    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pictureSegue" {
            segue.destination.setValue(mid, forKey: "mid")
        }
    }
    
    // MARK: Action
    @IBAction func createMessage(_ sender: Any) {
        if messageTitle == nil {
            showAlert(title: NSLocalizedString("tip_name", comment: ""),
                      content: "Please input a post title.",
                      controller: self)
            return
        }
        
        var oids: [String] = []
        for section in selectionSections {
            if let oid = section.selectedRow()?.value {
                oids.append(oid)
            }
        }

        startAnimating()
        
        messgaeManager.create(title: messageTitle!,
                       introudction: introduction,
                       sell: sell,
                       price: price,
                       oids: oids,
                       cid: category.cid!)
        { (success, mid) in
            self.stopAnimating()
            if success {
                self.mid = mid!
                self.performSegue(withIdentifier: "pictureSegue", sender: self)
            } else {
                showAlert(title: NSLocalizedString("tip_name", comment: ""),
                          content: NSLocalizedString("create_message_fail", comment: ""),
                          controller: self)
            }
        }

    }
}

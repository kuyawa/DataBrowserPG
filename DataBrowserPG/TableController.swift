//
//  TableController.swift
//  DataBrowserPG
//
//  Created by Mac Mini on 1/15/17.
//  Copyright © 2017 Armonia. All rights reserved.
//

import Cocoa
import Foundation


class TableController : NSObject, NSTableViewDataSource, NSTableViewDelegate {
    var list       : [String] = []
    var tableView  : NSTableView?
    var onSelected : (_ name: String) -> Void = { name in }
    
    func assign(_ table: NSTableView) {
        tableView = table
        tableView?.delegate   = self
        tableView?.dataSource = self
        tableView?.target     = self
    }
    
    func reload() {
        tableView?.reloadData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellId = (tableColumn?.identifier)!  // "tableName"
        let text   = list[row]
        
        if let cell = tableView.make(withIdentifier: cellId, owner: self) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        
        return nil
    }
    
    func setSelectionMethod(_ method: @escaping (_ name:String) -> Void) {
        onSelected = method
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let index = tableView?.selectedRow ?? -1
        if index > -1 {
            let name = list[index]
            onSelected(name)
        }
    }
}

// END

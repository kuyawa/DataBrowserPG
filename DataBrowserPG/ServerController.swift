//
//  ServerController.swift
//  DataBrowserPG
//
//  Created by Mac Mini on 1/16/17.
//  Copyright © 2017 Armonia. All rights reserved.
//

import Cocoa
import Foundation


class ServerController : NSObject, NSTableViewDataSource, NSTableViewDelegate {
    var list       : [Server] = []
    var tableView  : NSTableView?
    var onSelected : (_ server: Server) -> Void = { server in }
    
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
        let cellId = (tableColumn?.identifier)!  // "serverName"
        let text   = list[row].name
        
        if let cell = tableView.make(withIdentifier: cellId, owner: self) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        
        return nil
    }
    
    func setSelectionMethod(_ method: @escaping (_ server: Server) -> Void) {
        onSelected = method
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let index = tableView?.selectedRow ?? -1
        if index > -1 {
            let server = list[index]
            onSelected(server)
        }
    }
}


// END

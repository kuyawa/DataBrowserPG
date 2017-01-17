//
//  SchemaController.swift
//  DataBrowserPG
//
//  Created by Mac Mini on 1/16/17.
//  Copyright © 2017 Armonia. All rights reserved.
//

import Cocoa
import Foundation


class SchemaController: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    var DB = Database()
    
    var tableName = ""
    var tableView : NSTableView?
    var fields    = DataResults()  //["name":"company", "type":"text", "length":40, "width":120]
    var records   = DataResults()
    var schema    = DataSchema()
    
    var start = 0
    var limit = 100
    var total = 0
    
    func setContext(in db:Database) {
        DB = db
    }
    
    func getSchema() {
        fields = [
            ["ordinal": 0, "name": "ordinal",  "type": "integer",           "length": 12, "decimals": 0, "default": "", "isnull": true, "autoinc": false],
            ["ordinal": 1, "name": "name",     "type": "character varying", "length": 40, "decimals": 0, "default": "", "isnull": true, "autoinc": false],
            ["ordinal": 2, "name": "type",     "type": "character varying", "length": 40, "decimals": 0, "default": "", "isnull": true, "autoinc": false],
            ["ordinal": 3, "name": "length",   "type": "integer",           "length": 12, "decimals": 0, "default": "", "isnull": true, "autoinc": false],
            ["ordinal": 4, "name": "decimals", "type": "integer",           "length": 12, "decimals": 0, "default": "", "isnull": true, "autoinc": false],
            ["ordinal": 5, "name": "default",  "type": "character varying", "length": 40, "decimals": 0, "default": "", "isnull": true, "autoinc": false],
            ["ordinal": 6, "name": "isnull",   "type": "boolean",           "length":  1, "decimals": 0, "default": "", "isnull": true, "autoinc": false],
            ["ordinal": 7, "name": "autoinc",  "type": "boolean",           "length":  1, "decimals": 0, "default": "", "isnull": true, "autoinc": false]
        ]
        schema.parseFields(fields)
    }
    
    func getRecords() {
        let results = DB.schema(tableName)
        //print("Results: ", results)
        records = results
        start   = 0
        limit   = 100
        total   = results.count
    }
    
    func getRecordCount() -> String {
        return "\(total) Field" + (total == 1 ? "" : "s")
    }
    
    func clear() {
        clearRows()
        clearColumns()
    }
    
    func clearRows() {
        if let last = tableView?.numberOfRows {
            //let range = NSRange(location: 0, length: last)
            let all = IndexSet(integersIn: 0 ..< last)
            tableView?.removeRows(at: all, withAnimation: .slideUp)
        }
    }
    
    func clearColumns() {
        if let table = tableView {
            for col in table.tableColumns {
                table.removeTableColumn(col)
            }
        }
    }
    
    func makeTable() {
        guard let tableView = tableView else { return }
        
        clearRows()
        clearColumns()
        
        var nib = NSNib(nibNamed: "BaseTableCell", bundle: .main)
        
        for field in schema.fields {
            let name = field.name
            var size = field.width
            if size < 80 { size = 80 }    // Min
            if size > 300 { size = 300 }  // Max
            
            let col = NSTableColumn(identifier: name)
            col.headerCell.title = name
            col.headerCell.alignment = .center
            col.width = CGFloat(size)
            if col.width < 1.0 { col.width = 40.0 }
            col.isEditable = true
            tableView.addTableColumn(col)
            
            switch field.base {
            case .Text    : nib = NSNib(nibNamed: "BaseTableCell"   , bundle: .main)
            case .Integer : nib = NSNib(nibNamed: "NumericTableCell", bundle: .main)
            case .Real    : nib = NSNib(nibNamed: "NumericTableCell", bundle: .main)
            case .Date    : nib = NSNib(nibNamed: "BaseTableCell"   , bundle: .main) // TODO: Date table cell
            case .Bool    : nib = NSNib(nibNamed: "BoolTableCell"   , bundle: .main) // TODO: Bool table cell
            case .Binary  : nib = NSNib(nibNamed: "BaseTableCell"   , bundle: .main) // Replace text with "Binary"
            }
            
            tableView.register(nib, forIdentifier: name)
        }
        
        tableView.usesAlternatingRowBackgroundColors = true
        tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        tableView.delegate   = self
        tableView.dataSource = self
        tableView.target     = self
        tableView.font       = NSFont.monospacedDigitSystemFont(ofSize: 12.0, weight: NSFontWeightRegular)
    }
    
    func reload() {
        tableView?.reloadData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return records.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let item   = records[row]
        let cellId = (tableColumn?.identifier)!
        var text   = (item[cellId] as AnyObject).debugDescription!
        //var image: NSImage?
        
        switch item[cellId] {
        case let value as String   : text = value
        case let value as Int      : text = String(value)
        case let value as Double   : text = String(value)
        case let value as NSNumber : text = String(describing: value)
        default: text = "\(item[cellId]!)"
        }
        
        if let cell = tableView.make(withIdentifier: cellId, owner: self) as? NSTableCellView {
            let fieldType = schema.getField(cellId)?.type
            if fieldType == .Boolean {
                (cell as! BoolTableCell).checked = item[cellId] as! Bool
            } else {
                cell.textField?.stringValue = text
            }
            return cell
        }
        
        return nil
    }
    
    /*
    func prev() {
        if start == 0 { return }
        start -= limit
        if start < 0 { start = 0 }
        
        records = DB.browse(tableName, start:start, limit:limit)
        reload()
    }
    
    func next() {
        let edge = total - limit
        if start > edge { return }
        start += limit
        if start > total { start -= limit }
        
        records = DB.browse(tableName, start:start, limit:limit)
        reload()
    }
    */
}


// END

//
//  DataManager.swift
//  DataBrowserPG
//
//  Created by Mac Mini on 1/15/17.
//  Copyright © 2017 Armonia. All rights reserved.
//

import Cocoa

class DataManager: NSViewController {

    enum TabPanel {
        case Browse, Schema
    }
    
    var DB      = Database()
    var tables  = TableController()
    var browser = BrowseController()
    var schema  = SchemaController()
    
    var serverView : NSViewController?

    var currentTab   = TabPanel.Browse
    var currentTable = ""
    var lastSchema   = ""
    var lastBrowse   = ""

    @IBOutlet weak var tabControl : NSTabView!
    
    @IBOutlet weak var tableView  : NSTableView!
    @IBOutlet weak var browseView : NSTableView!
    @IBOutlet weak var schemaView : NSTableView!
    
    @IBOutlet weak var numTables  : NSTextField!
    @IBOutlet weak var numRecords : NSTextField!
    @IBOutlet weak var numFields  : NSTextField!

    
    @IBAction func onBrowseTab(_ sender: AnyObject) {
        currentTab = .Browse
        tabControl.selectFirstTabViewItem(self)
        if lastBrowse != currentTable { browseTable(currentTable) }
    }
    
    @IBAction func onSchemaTab(_ sender: AnyObject) {
        currentTab = .Schema
        tabControl.selectLastTabViewItem(self)
        if lastSchema != currentTable { showSchema(currentTable) }
    }
    
    @IBAction func onSelectServer(_ sender: AnyObject) {
        serverView?.view.window?.setIsVisible(true)
        serverView?.view.window?.makeKeyAndOrderFront(self)
    }
    
    @IBAction func onSelectTable(_ sender: AnyObject) {
        let index = tableView.selectedRow
        let name  = tables.list[index]
        selectTable(name)
    }
    
    @IBAction func onPrevRecords(_ sender: AnyObject) {
        browser.prev()
        showRecordCount()
    }
    
    @IBAction func onNextRecords(_ sender: AnyObject) {
        browser.next()
        showRecordCount()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    func setupTableView() {
        tables = TableController()
        tables.assign(tableView)
        tables.setSelectionMethod(selectTable)
    }
    
   func connect(_ info: String) {
        DB.connect(info)
        
        //let databases = DB.getDatabases()
        //print("Databases: ", databases)
        
        tables.list = DB.getTables()
        showTables()
        showTableCount()
        selectFirstTable()
    }
    
    
    func showTables() {
        tables.reload()
    }
    
    func showTableCount() {
        numTables.stringValue = tables.list.count.plural("Table")
    }
    
    func showRecordCount() {
        numRecords.stringValue = browser.getRecordCount()
    }
    
    func showFieldCount() {
        numFields.stringValue = schema.getRecordCount()
    }
    
    func selectFirstTable() {
        if tables.list.count > 0 {
            let first = tables.list.first!
            selectTable(first)
        }
    }
    
    func selectTable(_ name: String) {
        currentTable = name
        if currentTab == .Browse {
            browseTable(name)
        } else {
            showSchema(name)
        }
    }

    func browseTable(_ name: String) {
        if name.isEmpty { return }
        // show records
        browser.tableView = browseView
        browser.tableName = name
        browser.setContext(in: DB)
        browser.getSchema()
        browser.getRecords()
        browser.makeTable()
        browser.reload()
        showRecordCount()
    }

    func showSchema(_ name: String) {
        if name.isEmpty { return }
        // show fields
        schema.tableView = schemaView
        schema.tableName = name
        schema.setContext(in: DB)
        schema.getSchema()
        schema.getRecords()
        schema.makeTable()
        schema.reload()
        showFieldCount()
    }
    
}


// End

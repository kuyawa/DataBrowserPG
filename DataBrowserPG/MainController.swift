//
//  ViewController.swift
//  DataBrowserPG
//
//  Created by Mac Mini on 1/15/17.
//  Copyright © 2017 Armonia. All rights reserved.
//

import Cocoa

class MainController: NSViewController, NSTextFieldDelegate {
    
    var settings = Settings()
    var server   = Server()
    var servers  = [Server]()
    var serverController = ServerController()
    
    var dataManager    : DataManager?
    var dataBrowser    : NSWindow?
    var dataController : NSWindowController?
    
    var hidePass = false
    
    
    @IBOutlet weak var serverView : NSTableView!
    @IBOutlet weak var numServers : NSTextField!
    
    @IBOutlet weak var textName: NSTextField!
    @IBOutlet weak var textHost: NSTextField!
    @IBOutlet weak var textPort: NSTextField!
    @IBOutlet weak var textUser: NSTextField!
    @IBOutlet weak var textPass: NSTextField!
    @IBOutlet weak var textData: NSTextField!
    @IBOutlet weak var textSafe: NSSecureTextField!
    
    @IBOutlet weak var warning: NSTextField!
    
    @IBAction func onTogglePass(_ sender: AnyObject) {
        togglePass()
    }

    @IBAction func onNewServer(_ sender: AnyObject) {
        serverNew()
    }
    
    @IBAction func onSaveServer(_ sender: AnyObject) {
        serverSave()
    }
    
    @IBAction func onRemoveServer(_ sender: AnyObject) {
        serverRemove()
    }
    
    @IBAction func onConnect(_ sender: AnyObject) {
        serverConnect()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        start()
    }

    func start() {
        textPass.delegate = self
        textSafe.delegate = self
        textPass.target = self
        textSafe.target = self
        togglePass()
        
        setupServerView()
        settings.load()
        server.loadDefault()
        
        if settings.servers.count == 0 {
            settings.servers.append(server)
            settings.save()
        }
        
        servers = settings.servers
        serverController.list = servers
        serverController.reload()

        let select = settings.findServerIndex(name: server.name)
        serverView.selectRowIndexes([select], byExtendingSelection: false)
    }
    
    func setupServerView() {
        //serverController = ServerController()
        serverController.assign(serverView)
        serverController.setSelectionMethod(selectServer)
    }
    
    func showServers() {
        serverController.reload()
    }
    
    func showServerCount() {
        numServers.stringValue = serverController.list.count.plural("Server")
    }
    
    func selectFirstServer() {
        if serverController.list.count > 0 {
            let first = serverController.list.first!
            selectServer(first)
        }
    }

    func selectServer(_ server: Server) {
        self.server = server
        setFields(server)
    }
    
    func assignFields(to server: Server) {
        server.name = textName.stringValue
        server.host = textHost.stringValue
        server.port = textPort.stringValue
        server.user = textUser.stringValue
        server.pass = textPass.stringValue
        server.data = textData.stringValue
        server.info = server.parseFields()
    }
    
    func setFields(_ server: Server) {
        textName.stringValue = server.name
        textHost.stringValue = server.host
        textPort.stringValue = server.port
        textUser.stringValue = server.user
        textPass.stringValue = server.pass
        textSafe.stringValue = server.pass
        textData.stringValue = server.data
    }
    
    func setFields(name: String, host: String, port: String, user: String, pass: String, data: String) {
        textName.stringValue = name
        textHost.stringValue = host
        textPort.stringValue = port
        textUser.stringValue = user
        textPass.stringValue = pass
        textSafe.stringValue = pass
        textData.stringValue = data
    }
    
    func clearFields() {
        textName.stringValue = ""
        textHost.stringValue = ""
        textPort.stringValue = ""
        textUser.stringValue = ""
        textPass.stringValue = ""
        textSafe.stringValue = ""
        textData.stringValue = ""
    }
    
    func parseFields() -> String {
        let host = textHost.stringValue
        let port = textPort.stringValue
        let user = textUser.stringValue
        let pass = textPass.stringValue
        let data = textData.stringValue
        let info = "host=\(host) port=\(port) user=\(user) password=\(pass) dbname=\(data)"

        return info
    }

    func serverNew() {
        clearFields()
        server = Server()
        server.name = "<new server>"
        servers.append(server)
        serverController.list = servers
        serverController.reload()
        setFields(server)
        textName.becomeFirstResponder()
    }
    
    func serverSave() {
        assignFields(to: server)
        serverController.list = servers
        serverController.reload()
        settings.servers = serverController.list
        settings.save()
    }
    
    func serverRemove() {
        // TODO: remove from list, remove from settings.txt, clear fields
    }
    
    func serverConnect() {
        hideMessage()

        let name = textName.stringValue
        let info = parseFields()
       
        server = Server(name, info)
        let ok = server.connect()
        server.disconnect()
        
        if ok {
            server.saveDefault()
            showMessage("Server connected")
            showDataManager(info)
        } else {
            showWarning("Server unavailable")
        }
    }
    
    func showDataManager(_ info: String) {
        dataManager = DataManager()
        dataBrowser = NSWindow(contentViewController: dataManager!)
        dataBrowser?.title = "DataBrowser for PostgreSQL"
        dataBrowser?.minSize = NSSize.init(width: 600, height: 400)
        dataController = NSWindowController(window: dataBrowser)
        dataController?.showWindow(self)
        dataManager?.serverView = self
        dataManager?.connect(info)
        self.view.window?.setIsVisible(false)
    }

    
    // UI Utils
    func showWarning(_ text: String) {
        print(text)
        warning.stringValue = text
        warning.textColor = NSColor.red
        warning.isHidden = false
    }
    
    func showMessage(_ text: String) {
        print(text)
        warning.stringValue = text
        warning.textColor = NSColor.init(red: 0.0, green: 0.6, blue: 0.0, alpha: 1.0)
        warning.isHidden = false
    }
    
    func hideMessage() {
        warning.isHidden = true
    }
    
    func togglePass() {
        hidePass = !hidePass
        if hidePass {
            textPass.isEnabled = false
            textPass.isHidden  = true
            textSafe.isHidden  = false
            textSafe.isEnabled = true
        } else {
            textSafe.isEnabled = false
            textSafe.isHidden  = true
            textPass.isHidden  = false
            textPass.isEnabled = true
        }
    }
    
    // Keep them synchronized
    override func controlTextDidChange(_ obj: Notification) {
        if let textField = obj.object as? NSTextField {
            if textField.identifier == "textPass" {
                textSafe.stringValue = textField.stringValue
            } else {
                textPass.stringValue = textField.stringValue
            }
        }
    }
    
}


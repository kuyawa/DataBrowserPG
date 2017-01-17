//
//  Server.swift
//  DataBrowserPG
//
//  Created by Mac Mini on 1/15/17.
//  Copyright © 2017 Armonia. All rights reserved.
//

import Foundation

class Server {
    var name: String = ""
    var host: String = ""
    var port: String = ""
    var user: String = ""
    var pass: String = ""
    var data: String = ""
    
    var url:  URL?
    var info: String = ""  // This is the only field used for connection
    
    var connection: PGConnection?
    var database: Database?
    
    init() {}
    
    init(_ name: String, _ info: String){
        self.name = name
        self.info = info
        parseInfo(info)
    }
    
    deinit{
        disconnect()
    }
    
    func connect() -> Bool {
        if info.isEmpty {
            print("DB ERROR: Server info not provided")
            return false
        }
        
        connection = PGConnection()
        let status = connection?.connectdb(info)
        
        if status == .ok {
            return true
        }
        
        print("DB ERROR: Server info invalid")
        return false
    }
    
    func disconnect() {
        connection?.finish()
    }
    
    // Model
    func saveDefault() {
        //print("Save defaults: ", info)
        if info.isEmpty { return }
        if name.isEmpty { name = "Default" }
        let defaults = UserDefaults.standard
        defaults.set(name, forKey: "name")
        defaults.set(info, forKey: "info")
        defaults.synchronize()
        //print("Synchronized")
    }
    
    func loadDefault() {
        let defaults = UserDefaults.standard
        name = defaults.string(forKey: "name") ?? "Default"
        info = defaults.string(forKey: "info") ?? ""
        //print("Load defaults: ", info)
        if info.isEmpty {
            info = "host=localhost port=5432 user=postgres password= dbname=postgres"
            saveDefault()
        }
        parseInfo(info)
    }
    
    // Utils
    func parseFields() -> String {
        let info = "host=\(host) port=\(port) user=\(user) password=\(pass) dbname=\(data)"
        
        return info
    }
    
    func parseFields(host: String, port: String, user: String, password: String, database: String) -> String {
        // Split info in fields
        self.host = host
        self.port = port
        self.user = user
        self.pass = password
        self.data = database
        
        let info = "host=\(host) port=\(port) user=\(user) password=\(password) dbname=\(database)"
        
        return info
    }
    
    func parseInfo(_ info: String) {
        let fields = info.components(separatedBy: " ")
        let parts  = fields.map{ $0.components(separatedBy: "=") }
        var dixy: [String: String] = [:]
        
        for field in parts {
            dixy[field[0]] = field[1]
        }
        
        host = dixy["host"] ?? "localhost"
        port = dixy["port"] ?? "5432"
        user = dixy["user"] ?? ""
        pass = dixy["password"] ?? ""
        data = dixy["dbname"] ?? ""

    }
    
    func parseURL(_ url: URL) -> String {
        host = url.host ?? "localhost"
        port = String(describing: (url.port ?? 5432))
        user = url.user ?? ""
        pass = url.password ?? ""
        data = url.query ?? ""

        let info = "host=\(host) port=\(port) user=\(user) password=\(pass) dbname=\(data)"
        
        return info
    }
}

// End

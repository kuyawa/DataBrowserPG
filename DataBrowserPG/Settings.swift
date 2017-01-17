//
//  Settings.swift
//  DataBrowserPG
//
//  Created by Mac Mini on 1/16/17.
//  Copyright © 2017 Armonia. All rights reserved.
//

import Foundation

class Settings {
    var version :String = "1.0"
    var servers = [Server]()
    
    var appFolder : URL {
        get {
            let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
            let path    = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            let folder  = path.first?.appendingPathComponent(appName, isDirectory: true)
            return folder!
        }
    }

    var fileName: URL {
        get {
            let file = appFolder.appendingPathComponent("Settings.txt")
            return file
        }
    }
    
    func firstTime() {
        print("Settings file not found")
        print("AppFolder: ", appFolder)
        guard FileUtils.verifyFolder(appFolder.path) else { return }
        
        // if not settings.txt in app folder, create it
        if let path = Bundle.main.path(forResource: "Settings", ofType: "txt") {
            do {
                // Save in app folder
                let text = try String(contentsOfFile: path)
                FileUtils.save(fileName, content: text)
                print("Settings file created")
            } catch {
                print("Error accessing settings file")
            }
        }
    }
    
    func load(){
        if !FileUtils.fileExists(fileName) {
            firstTime() // create a basic settings file
        }
        
        // Read file settings.txt as json
        let json = FileUtils.loadAsJson(fileName)
        
        // assign values from file
        if let ver  = json?["version"] as? String { self.version = ver }
        if let list = json?["servers"] as? NSArray {
            for item in list {
                if let info = item as? [String: AnyObject] {
                    let server = Server()
                    
                    guard
                        let name = info["name"] as? String,
                        let host = info["host"] as? String,
                        let port = info["port"] as? String,
                        let user = info["user"] as? String,
                        let pass = info["pass"] as? String,
                        let data = info["data"] as? String,
                        let url  = info["url"]  as? String
                    else {
                        print("No data \(type(of:info))")
                        break
                    }
                    
                    server.name = name
                    server.host = host
                    server.port = port
                    server.user = user
                    server.pass = pass
                    server.data = data
                    server.url  = URL(string: url)
                    
                    self.servers.append(server)
                } else {
                    print("No item \(type(of:item))")
                }
            }
        } else {
            print("No servers")
        }
        
        print("-")
    }
    
    func save() {
        let json = self.toJson()
        print("Saving settings in ", fileName)
        print(json)
        FileUtils.save(fileName, content: json)
    }
    
    func toDictionary() -> [String:Any] {
        var data = [String: Any]()
        data["version"] = self.version
        var items = [[String: Any]]()  // Array of dicks
        
        for item in self.servers {
            var server = [String: Any]()
            server["name"] = item.name
            server["host"] = item.host
            server["port"] = item.port
            server["user"] = item.user
            server["pass"] = item.pass
            server["data"] = item.data
            server["url"]  = item.url?.path ?? ""
            items.append(server)
        }
        data["servers"] = items
        
        return data
    }
    
    func toJson() -> String {
        let data = self.toDictionary()
        return data.toJson() // uses Dictionary extension from DataUtils
    }
    
    func findServerIndex(name: String) -> Int {
        var index = 0
        for item in servers {
            if item.name.lowercased() == name.lowercased() {
                print("Server found at #\(index)")
                return index
            }
            index += 1
        }
        return -1
    }
    
    func addServer(_ server: Server) -> Bool {
        // name and url are required
        let index = findServerIndex(name: server.name)
        
        if index >= 0 {
            print("Server already exists")
            //AlertOK("Server already exists").show()
            return false
        }
        
        self.servers.append(server)
        self.save()
        
        return true
    }
    
    func removeServer(name :String) {
        let index = findServerIndex(name: name)
        if index >= 0 {
            self.removeServer(at: index)
        }
    }
    
    func removeServer(at index :Int) {
        self.servers.remove(at: index)
        self.save()
    }
}


// End

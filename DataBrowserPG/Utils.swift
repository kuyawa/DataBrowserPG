//
//  Utils.swift
//  DataBrowserPG
//
//  Created by Mac Mini on 1/16/17.
//  Copyright © 2017 Armonia. All rights reserved.
//

import Foundation


extension Int {
    func plural(_ text: String) -> String {
        let word = text + (self == 1 ? "" : "s")
        return("\(self) \(word)")
    }
}

extension Dictionary {
    func toJson() -> String {
        let invalidJson = "{\"error\": \"Invalid JSON\"}"
        do {
            let json = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(data: json, encoding: String.Encoding.utf8) ?? invalidJson
        } catch let error as NSError {
            print(error)
            return invalidJson
        }
    }
}

class FileUtils {
    static func fileExists(_ url: URL) -> Bool {
        if FileManager.default.fileExists(atPath: url.path) {
            return true
        }
        return false
    }

    static func verifyFolder(_ path: String) -> Bool {
        do {
            var isDir :ObjCBool = false
            let filer = FileManager.default
            
            if filer.fileExists(atPath: path, isDirectory: &isDir) {
                if isDir.boolValue {
                    return true
                } else {
                    print("Exists as file. Creating as folder")
                }
            } else {
                print("Folder does not exist. Creating new folder in \(path)")
            }
            
            // Create new folder
            try filer.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
            
        } catch let error as NSError {
            print("Error verifying folder: \(path)")
            print(error)
            return false
        }
        
        return true
    }
    
    // Load file from Documents/App folder
    static func load(_ url: URL) -> String {
        var content :String = ""
        
        do {
            if fileExists(url) {
                try content = String(contentsOf: url, encoding: String.Encoding.utf8)
            } else {
                print("File not found: \(url.path)")
            }
        } catch let error as NSError {
            print("Error reading file in \(url.path)")
            print(error)
        }
        
        return content
    }
    
    
    static func loadAsJson(_ url: URL) -> [String:AnyObject]? {
        let content :String = self.load(url)
        //print("|"+content+"|")
        if let data = content.data(using: String.Encoding.utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]
                return json
            } catch let error as NSError {
                print("Error parsing json from \(url.path)")
                print(error)
            }
        }
        return nil
    }
    
    // Save file to Documents/App folder
    static func save(_ url: URL, content: String) {
        do {
            try content.write(to: url, atomically: false, encoding: String.Encoding.utf8)
            print("File saved: ", url.path)
        } catch let error as NSError {
            print("Error writing file to ", url.path)
            print(error)
        }
    }
    
    static func saveAsJson(_ url: URL, data: [String: AnyObject]) {
        let invalidJson = "{\"error\": \"Invalid JSON\"}"
        do {
            let json = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            let text = String(data: json, encoding: String.Encoding.utf8) ?? invalidJson
            self.save(url, content: text)
        } catch let error as NSError {
            print("Error saving json for ", url.path)
            print(error)
        }
    }

}

// End

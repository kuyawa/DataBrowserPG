//
//  Database.swift
//  DataBrowserPG
//
//  Created by Mac Mini on 1/15/17.
//  Copyright © 2017 Armonia. All rights reserved.
//

import Foundation

/*
 
 let db = Database()
 let result = db.exec(sql, args)    // return rowsAffected
 let result = db.query(sql, args)   // return [[Any]]
 let result = db.value(sql, args)   // return String|Int
 let result = db.result(sql, args)  // return PGResult
 
 */

typealias Parameters  = Dictionary<String, Any>
typealias DataResults = [Dictionary<String, Any>]

class Database {
    
    var info = "host=localhost port=5432 user=postgres password= dbname=postgres"
    var db   = PGConnection()
    
    init() {}
        
    deinit {
        disconnect()
    }
    
    func connect(_ serverInfo: String) {
        info = serverInfo
        db = PGConnection()
        let status = db.connectdb(info)
        guard status == .ok else {
            print("DB Error initializing datastore");
            return
        }
    }
    
    func disconnect() {
        db.finish()
    }
    
    func getDatabases() -> [String] {
        var databases = [String]()
        let sql = "Select datname as database From pg_database Where datistemplate=false Order by database Limit 10"
        let result = db.exec(statement: sql)
        
        guard result.status() == PGResult.StatusType.tuplesOK else {
            print("DB Fail: No results");
            return databases
        }
        
        let nFields = result.numFields()
        let nTuples = result.numTuples()
        
        guard nFields > 0 else {
            print("DB Fail: No records");
            return databases
        }
        
        for index in 0..<nTuples {
            let name = result.getFieldString(tupleIndex: index, fieldIndex: 0)
            databases.append(name!)
        }
        
        result.clear()
        
        return databases
    }
    
    func getTables() -> [String] {
        var tables = [String]()
        let sql = "select table_name as table from information_schema.tables where table_schema = 'public' order by table_name"
        //extended info: Select * From pg_catalog.pg_tables Where schemaname != 'pg_catalog' And schemaname != 'information_schema'
        let result = db.exec(statement: sql)
        
        guard result.status() == PGResult.StatusType.tuplesOK else {
            print("DB Fail: No results");
            return tables
        }
        
        let nFields = result.numFields()
        let nTuples = result.numTuples()
        
        guard nFields > 0 else {
            print("DB Fail: No records");
            return tables
        }
        
        for index in 0..<nTuples {
            let name = result.getFieldString(tupleIndex: index, fieldIndex: 0)
            tables.append(name!)
        }
        
        result.clear()
        
        return tables
    }
    
    func result(_ sql: String, _ args: [Any]? = nil) -> PGResult {
        var result: PGResult
        
        if args == nil {
            result = db.exec(statement: sql)
        } else {
            result = db.exec(statement: sql, params: args!)
        }
        
        return result
        
    }
    
    func exec(_ sql: String, _ args: [Any]? = nil) -> Int {
        var status = 0
        var result: PGResult
        if args == nil {
            result = db.exec(statement: sql)
        } else {
            result = db.exec(statement: sql, params: args!)
        }
        
        guard result.status() == PGResult.StatusType.tuplesOK else {
            print("DB Fail: No results");
            print("Error: ", result.errorMessage())
            return status
        }
        
        status = result.statusInt()
        result.clear()
        
        return status
        
    }
    
    func query(_ sql: String, _ args: [Any]? = nil) -> DataResults {
        var rows = DataResults()
        var result: PGResult
        
        if args == nil {
            result = db.exec(statement: sql)
        } else {
            result = db.exec(statement: sql, params: args!)
        }
        
        guard result.status() == PGResult.StatusType.tuplesOK else {
            print("DB Fail: No results");
            print("Error: ", result.errorMessage())
            return rows
        }
        
        let nFields = result.numFields()
        let nTuples = result.numTuples()
        
        guard nFields > 0 else {
            print("DB Fail: No records");
            print("Error: ", result.errorMessage())
            return rows
        }
        
        for index in 0..<nTuples {
            var row: [String: Any] = [:]
            for field in 0..<nFields {
                let fieldName = result.fieldName(index: field)!
                let fieldType = Int32(result.fieldType(index: field)!)
                
                var cell: Any
                switch fieldType {
                case   16: cell = result.getFieldBool(  tupleIndex: index, fieldIndex: field) ?? false  // bool
                case   20: cell = result.getFieldInt(   tupleIndex: index, fieldIndex: field) ?? 0      // bigint
                case   21: cell = result.getFieldInt(   tupleIndex: index, fieldIndex: field) ?? 0      // smallint
                case   23: cell = result.getFieldInt(   tupleIndex: index, fieldIndex: field) ?? 0      // integer
                case   25: cell = result.getFieldString(tupleIndex: index, fieldIndex: field) ?? ""     // text
                case  700: cell = result.getFieldFloat( tupleIndex: index, fieldIndex: field) ?? 0.0    // real
                case  701: cell = result.getFieldDouble(tupleIndex: index, fieldIndex: field) ?? 0.0    // double
                case  790: cell = result.getFieldString(tupleIndex: index, fieldIndex: field) ?? ""     // money
                case 1042: cell = result.getFieldString(tupleIndex: index, fieldIndex: field) ?? ""     // character
                case 1043: cell = result.getFieldString(tupleIndex: index, fieldIndex: field) ?? ""     // varchar
                case 1082: cell = result.getFieldString(tupleIndex: index, fieldIndex: field) ?? ""     // date
                case 1114: cell = result.getFieldString(tupleIndex: index, fieldIndex: field) ?? ""     // timestamp
                case 1184: cell = result.getFieldString(tupleIndex: index, fieldIndex: field) ?? ""     // timestamp timezone
                case 1700: cell = result.getFieldDouble(tupleIndex: index, fieldIndex: field) ?? 0.0    // numeric
                case 2950: cell = result.getFieldString(tupleIndex: index, fieldIndex: field) ?? ""     // uuid
                default  : cell = result.getFieldString(tupleIndex: index, fieldIndex: field) ?? ""     // undefined
                }

                row[fieldName] = cell
            }
            rows.append(row)
        }
        
        result.clear()
        
        return rows
        
    }
    
    func getValue(_ sql: String, _ args: [Any]? = nil) -> String {
        var value = ""
        var result: PGResult
        if args == nil {
            result = db.exec(statement: sql)
        } else {
            result = db.exec(statement: sql, params: args!)
        }
        
        guard result.status() == PGResult.StatusType.tuplesOK else {
            print("DB Fail: No results");
            print("Error: ", result.errorMessage())
            return value
        }
        
        let nFields = result.numFields()
        let nTuples = result.numTuples()
        
        guard nFields > 0, nTuples > 0 else {
            print("DB Fail: No records");
            print("Error: ", result.errorMessage())
            return value
        }
        
        value = result.getFieldString(tupleIndex: 0, fieldIndex: 0) ?? ""
        
        result.clear()
        
        return value
    }
    
    func getValue(_ sql: String, _ args: [Any]? = nil) -> Int {
        var value = 0
        var result: PGResult
        if args == nil {
            result = db.exec(statement: sql)
        } else {
            result = db.exec(statement: sql, params: args!)
        }
        
        guard result.status() == PGResult.StatusType.tuplesOK else {
            print("DB Fail: No results");
            print("Error: ", result.errorMessage())
            return value
        }
        
        let nFields = result.numFields()
        let nTuples = result.numTuples()
        
        guard nFields > 0, nTuples > 0 else {
            print("DB Fail: No records");
            print("Error: ", result.errorMessage())
            return value
        }
        
        value = result.getFieldInt(tupleIndex: 0, fieldIndex: 0) ?? 0
        
        result.clear()
        
        return value
    }
    
    func browse(_ table: String, start: Int? = 0, limit: Int? = 100) -> DataResults {
        let sql = "Select * From \(table) Offset $1 Limit $2"
        let rows = query(sql, [start!, limit!])

        return rows
    }
    
    func schema(_ table: String) -> DataResults {
        let sql = "Select ordinal_position as ordinal, column_name as name, data_type as type, character_maximum_length as length, numeric_scale as decimals, is_nullable='YES' as isnull, column_default as default, left(column_default, 7)='nextval' as autoinc From INFORMATION_SCHEMA.COLUMNS Where table_name = $1 Order by ordinal"
        let fields = query(sql, [table])
        return fields
    }
    
    func recordCount(_ table: String) -> Int {
        let sql = "Select count(1) From \(table)"
        let num: Int = getValue(sql)
        return num
    }
    
}

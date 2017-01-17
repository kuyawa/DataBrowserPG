//
//  Schema.swift
//  DataBrowserPG
//
//  Created by Mac Mini on 1/15/17.
//  Copyright © 2017 Armonia. All rights reserved.
//

import Foundation

// Primitive types
enum FieldTypePrimitive: String {
    case Text, Integer, Real, Blob
}

// For use in formatting tables
enum FieldTypeBase: String {
    case Text, Integer, Real, Date, Bool, Binary
}

// TODO: Postgres types
enum FieldType: String {
    case Text, Varchar, NVarchar, Character, NChar, Clob, Uuid,
    Int, Integer, TinyInt, SmallInt, MediumInt, BigInt, Uint, Int2, Int8, Serial, BigSerial,
    Real, Double, Float, Number, Numeric, Decimal, Money,
    Date, Datetime, Timestamp,
    Boolean,
    Binary, Blob
}

class DataSchema: NSObject {
    var tableName = ""
    var fields    = [TableField]()
    var indexes   = [TableIndexes]()
    
    
    func parseFields(_ cols: DataResults) {
        fields.removeAll()

        for item in cols {
            let field = TableField()
            field.ordinal = item["ordinal"] as! Int
            field.name = item["name"] as! String
            let len = item["length"] as! Int
            let dec = item["decimals"] as! Int
            let (base, type, length, decs, width) = parseType(item["type"] as! String)
            field.base     = base
            field.type     = type
            field.length   = length
            field.decimals = decs
            field.width    = width
            field.isNull   = item["isnull"]  as! Bool //String == "YES"
            field.defValue = item["default"] as! String
            field.autoInc  = item["autoinc"] as! Bool
            if len > length { field.length = len }
            if len > width  { field.width  = len }
            if dec > decs   { field.decimals = dec }
            
            fields.append(field)
        }
    }
    
    func parseType(_ field: String) -> (FieldTypeBase, FieldType, Int, Int, Int) {
        let text   = field.uppercased()
        var base   = FieldTypeBase.Text
        var type   = FieldType.Varchar
        var length = 1
        let decs   = 0
        var width  = 0

        // Type
        if text.hasPrefix("CHARACTER VAR")  { type = .Varchar;   base = .Text;    length = 40; width = 200 }
        else if text.hasPrefix("VARCHAR")   { type = .Varchar;   base = .Text;    length = 40; width = 200 }
        else if text.hasPrefix("NVARCHAR")  { type = .NVarchar;  base = .Text;    length = 40; width = 200 }
        else if text.hasPrefix("CHARACTER") { type = .Character; base = .Text;    length = 40; width = 200 }
        else if text.hasPrefix("TEXT")      { type = .Text;      base = .Text;    length = 80; width = 400 }
        else if text.hasPrefix("INTEGER")   { type = .Integer;   base = .Integer; length = 12; width =  80 }
        else if text.hasPrefix("BIGINT")    { type = .BigInt;    base = .Integer; length = 12; width =  80 }
        else if text.hasPrefix("SMALLINT")  { type = .SmallInt;  base = .Integer; length = 12; width =  80 }
        else if text.hasPrefix("MONEY")     { type = .Money;     base = .Real;    length = 12; width =  80 }
        else if text.hasPrefix("REAL")      { type = .Real;      base = .Real;    length = 12; width =  80 }
        else if text.hasPrefix("DOUBLE")    { type = .Double;    base = .Real;    length = 12; width =  80 }
        else if text.hasPrefix("NUMERIC")   { type = .Numeric;   base = .Real;    length = 12; width =  80 }
        else if text.hasPrefix("TIMESTAMP") { type = .Timestamp; base = .Date;    length = 20; width = 200 }
        else if text.hasPrefix("DATETIME")  { type = .Datetime;  base = .Date;    length = 20; width = 200 }
        else if text.hasPrefix("DATE")      { type = .Date;      base = .Date;    length = 20; width = 100 }
        else if text.hasPrefix("BOOLEAN")   { type = .Boolean;   base = .Bool;    length = 20; width =  60 }
        else if text.hasPrefix("BINARY")    { type = .Binary;    base = .Binary;  length = 40; width =  60 }
        else if text.hasPrefix("BLOB")      { type = .Binary;    base = .Binary;  length = 40; width =  60 }
        else if text.hasPrefix("UUID")      { type = .Uuid;      base = .Text;    length = 40; width = 300 }
        else { type = .Text; base = .Text; length = 80 }
        // Types: Point? Multipoint? Linestring?
        
        return (base, type, length, decs, width)
    }
    
    func getField(_ name: String) -> TableField? {
        for field in fields {
            if field.name == name { return field }
        }
        
        return nil
    }
    
}

class TableField: NSObject {
    var ordinal  = 0
    var name     = ""
    var base     = FieldTypeBase.Text
    var type     = FieldType.Text
    var length   = 1
    var decimals = 0
    var width    = 0   // Used in table columns
    var defValue = ""
    var isNull   = false
    var autoInc  = false
    var primary  = false
}

// TODO: indexes?
class TableIndexes: NSObject {
    var name = ""
}


// End

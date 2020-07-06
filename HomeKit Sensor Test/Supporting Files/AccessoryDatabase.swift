//
//  AccessoryDatabase.swift
//  HomekitDemo
//
//  Created by Xcode User on 2018-05-25.
//  Copyright © 2018 Xcode User. All rights reserved.
//
import SQLite
import Foundation

protocol JSONRepresentable {
    var JSONRepresentation: AnyObject { get }
}

protocol JSONSerializable: JSONRepresentable {
}

extension JSONSerializable {
    var JSONRepresentation: AnyObject {
        var representation = [String: AnyObject]()
        
        for case let (label?, value) in Mirror(reflecting: self).children {
            switch value {
            case let value as JSONRepresentable:
                representation[label] = value.JSONRepresentation
                
            case let value as NSObject:
                representation[label] = value
                
            default:
                // Ignore any unserializable properties
                break
            }
        }
        
        return representation as AnyObject
    }
}

extension JSONSerializable {
    func toJSON() -> String? {
        let representation = JSONRepresentation
        
        guard JSONSerialization.isValidJSONObject(representation) else {
            return nil
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: representation, options: [])
            return String(data: data, encoding: String.Encoding.utf8)
        } catch {
            return nil
        }
    }
}

class AccessoryDatabase {
    
    struct accessoryData: JSONSerializable {
        let sensorName: String
        let sensorHome: String
        let sensorRoom: String
        let sensorType: String
        let sensorValue: Double
        let sensorDate: String
    }
    
    // Table Setup
    let accessoryTable = Table("Accessory")
    let id = Expression<Int64>("id")
    let sensorName = Expression<String>("sensorName")
    let sensorHome = Expression<String>("sensorHome")
    let sensorRoom = Expression<String>("sensorRoom")
    let sensorType = Expression<String>("sensorType")
    let sensorValue = Expression<Double>("sensorValue")
    let sensorDate = Expression<String>("sensorDate")
    // Database Creation
    let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent("AccessoryDatabase.sqlite")
    
    var db: Connection? = nil
    
    // Checks for old database file and deletes it
    func deleteDatabase() {
        do {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(atPath: fileURL.path)
            }
        }
        catch let error as NSError {
            print("Something went wrong deleting database file: \(error)")
        }
    }
    // Creates table
    func createTable() {
        do {
            db = try Connection(fileURL.path)
            print("Connected to database.")
            do {
                try db?.run(accessoryTable.create { t in
                    t.column(id, primaryKey: true)
                    t.column(sensorName)
                    t.column(sensorHome)
                    t.column(sensorRoom)
                    t.column(sensorType)
                    t.column(sensorValue)
                    t.column(sensorDate)
                })
            } catch {
                print("Error creating table")
            }
        } catch {
            print("Error connecting to database")
        }
    }
    // Retrieves total number of selected rows based on a name
    func retrieveCount(select: String, count: Int) -> Int{
        let query = accessoryTable.select(*)
            .filter(sensorName == select)
        var sensorCount = count
        do {
            for accessorys in (try db?.prepare(query))! {
                sensorCount = Int(accessorys[sensorValue])
            }
        } catch {
            print("Error retrieving total selected rows")
        }
        return sensorCount
    }
    // Retrieves rows with selected name
    func retrieveName(select: String) -> [String]{
        let query = accessoryTable.select(*).filter(sensorName == select)
        var logList = [String]()
        do {
            for accessorys in (try db?.prepare(query))! {
                logList.insert("Type: \(accessorys[sensorType]), Data: \(accessorys[sensorValue]), Time: \(accessorys[sensorDate])", at: 0)
            }
        } catch {
            print("Error retrieving selected name rows")
        }
        return logList
    }
    // Retrieves all rows
    func retrieveAll() -> [String]{
        let query = accessoryTable.select(*)
        var logList = [String]()
        do {
            for accessorys in (try db?.prepare(query))! {
                let log = accessoryData(sensorName:accessorys[sensorName],sensorHome:accessorys[sensorHome],sensorRoom:accessorys[sensorRoom],sensorType:accessorys[sensorType],sensorValue:accessorys[sensorValue],sensorDate:accessorys[sensorDate])
                if let json = log.toJSON() {
                    logList.append(json)
                }
            }
        } catch {
            print("Error retrieving all rows")
        }
        return logList
    }
    // Retrieves last row inserted
    func retrieveLast() -> [String]{
        let query = accessoryTable.select(*).order(id.desc).limit(1)
        var logList = [String]()
        do {
            for accessorys in (try db?.prepare(query))! {
                let log = accessoryData(sensorName:accessorys[sensorName],sensorHome:accessorys[sensorHome],sensorRoom:accessorys[sensorRoom],sensorType:accessorys[sensorType],sensorValue:accessorys[sensorValue],sensorDate:accessorys[sensorDate])
                if let json = log.toJSON() {
                    logList.append(json)
                }
            }
        } catch {
            print("Error retrieving last row")
        }
        return logList
    }
    // Inserting rows into table
    func insertRow(name: String, home: String, room: String, sensorType: String, sensorValue: Double, date: String){
        do {
            db = try Connection(fileURL.path)
            print("Connected to database.")
            let insert = accessoryTable.insert(self.sensorName <- name, self.sensorHome <- home, self.sensorRoom <- room, self.sensorType <- sensorType, self.sensorValue <- sensorValue, self.sensorDate <- date)
            do {
                try db?.run(insert)
            } catch {
                print("Eror insert to table")
            }
        } catch {
            print("Error connecting to database")
        }
    }
}

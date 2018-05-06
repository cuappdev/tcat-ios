//
//  JsonFileManager.swift
//  TCAT
//
//  Created by Monica Ong on 4/22/18.
//  Copyright © 2018 cuappdev. All rights reserved.
//

import UIKit
import SwiftyJSON
import Zip

enum JsonType {
    case routeJson
    case delayJson(rowNum: Int)
    
    func rawValue() -> String {
        switch self {
        case .routeJson:
            return "routeJson"
        case .delayJson(_):
            return "delayJson"
        }
    }
}

class JsonFileManager {
    
    // MARK: Singleton vars
    
    static let shared = JsonFileManager()
    
    // MARK: File vars
    
    private let documentsURL: URL
    private let logURL: URL
    private let zipURL: URL
    private let logFileName = "log.txt"
    private let zipFileName = "log.zip"
    
    // MARK: Print vars
    
    private let fileName = "JsonFileManager"
    
    // MARK: Initialization
    
    private init() {
        documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        logURL = documentsURL.appendingPathComponent(logFileName)
        zipURL = documentsURL.appendingPathComponent(zipFileName)
        
        do {
            let line = "\(getTimeStampString(from: Date())): \(fileName) \(#function): Initialized JsonFileManager\n"
            try line.write(to: logURL, atomically: false, encoding: .utf8)
        }
        catch {
            let line = "\(fileName) \(#function): \(error)"
            print(line)
            
            let logLine = "\(getTimeStampString(from: Date())): \(line)\n"
            try? logLine.write(to: logURL, atomically: false, encoding: .utf8)
        }
    }
    
    // MARK: Manage Zipping
    
    func getZipUrl() -> URL? {
        let fileUrls = getAllFileUrls()
        
        do  {
            try Zip.zipFiles(paths: fileUrls, zipFilePath: zipURL, password: nil, progress: nil)
            printAndLog(timestamp: Date(), line: "\(fileName) \(#function): Zipped all files to \(zipURL)")
            return zipURL
        }
        catch {
            printAndLog(timestamp: Date(), line: "\(fileName) \(#function): \(error)")
            return nil
        }
    }
    
    func deleteZip() {
        if FileManager.default.fileExists(atPath: zipURL.path) {
            do {
                try FileManager.default.removeItem(atPath: zipURL.path)
                
                printAndLog(timestamp: Date(), line: "\(fileName) \(#function): Deleted \(zipFileName)")
            }
            catch let error as NSError {
                printAndLog(timestamp: Date(), line: "\(fileName) \(#function): Error when deleting \(zipFileName) \(error.debugDescription)")
            }
        }
    }
    
    // MARK: Manage Files
    
    private func getAllFileUrls() -> [URL] {
        return [logURL] + getAllJsonURLs()
    }
    
    private func readFromDocuments(fileUrl: URL) -> Data? {
        let filePath = getFilePath(fileURL: fileUrl)
        
        if FileManager.default.fileExists(atPath: filePath), let data = FileManager.default.contents(atPath: filePath) {
            return data
        }
        return nil
    }
    
    private func getFileComponents(fileURL: URL) -> (fileName: String, fileExtension: String) {
        let fileURLParts = fileURL.path.components(separatedBy: "/")
        let fileName = fileURLParts.last
        let filenameParts = fileName?.components(separatedBy: ".")
        
        return (filenameParts![0], filenameParts![1])
    }
    
    private func getFilePath(fileURL: URL) -> String {
        let (fileName: fileName, fileExtension: fileExtension) =  getFileComponents(fileURL: fileURL)
        
        return documentsURL.appendingPathComponent("\(fileName).\(fileExtension)").path
    }
    
    // MARK: Manage Jsons
    
    func saveJson(_ json: JSON, type: JsonType) {
        do {
            let jsonData = try json.rawData()
            
            let jsonFileName = getFileNameString(date: Date(), type: type)
            let jsonFileExtension = "json"
            let jsonFileURL = documentsURL.appendingPathComponent("\(jsonFileName).\(jsonFileExtension)")
            
            try jsonData.write(to: jsonFileURL, options: .atomic)
            
            printAndLog(timestamp: Date(), line: "\(fileName) \(#function): Wrote \(type) to documents directory. Name: \(jsonFileName).\(jsonFileExtension)")
        }
        catch {
            printAndLog(timestamp: Date(), line: "\(fileName) \(#function): \(error)")
        }
    }
    
    func deleteAllJsons() {
        let jsonURLs = getAllJsonURLs()
        
        for url in jsonURLs {
            let jsonFilePath = getFilePath(fileURL: url)
            
            do {
                try FileManager.default.removeItem(atPath: jsonFilePath)
                
                let (fileName: jsonFileName, fileExtension: jsonFileExtension) = getFileComponents(fileURL: url)
                printAndLog(timestamp: Date(), line: "\(fileName) \(#function): Deleted \(jsonFileName).\(jsonFileExtension)")
            }
            catch let error as NSError {
                let (fileName: jsonFileName, fileExtension: jsonFileExtension) =  getFileComponents(fileURL: url)
                printAndLog(timestamp: Date(), line: "\(fileName) \(#function): Error for \(jsonFileName).\(jsonFileExtension) \(error.debugDescription)")
            }
        }
    }
    
    private func getAllJsonURLs() -> [URL]{
        var jsonURLs: [URL] = []
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            
            for url in fileURLs {
                let (fileName: _, fileExtension: fileExtension) = getFileComponents(fileURL: url)
                
                if fileExtension == "json" {
                    jsonURLs.append(url)
                }
            }
            
            return jsonURLs
        }
        catch {
            printAndLog(timestamp: Date(), line: "\(fileName) \(#function):: Error while enumerating files at \(documentsURL.path): \(error.localizedDescription)")
        }
        
        return jsonURLs
    }
    
    // MARK: Manage log
    
    func logSearchParameters(timestamp: Date, startPlace: Place, endPlace: Place, searchTime: Date, searchTimeType: SearchType) {
        logLine(timestamp: timestamp, line: "Search parameters: startPlace: \(startPlace). endPlace: \(endPlace). searchTime: \(Time.dateString(from: searchTime)). searchTimeType: \(searchTimeType)")
    }
    
    func logDelayParemeters(timestamp: Date, stopId: String, tripId: String) {
        logLine(timestamp: timestamp, line: "Delay parameters: stopId: \(stopId). tripId: \(tripId).")
    }
    
    func logUrl(timestamp: Date, urlName: String, url: String) {
        logLine(timestamp: timestamp, line: "\(urlName): \(url)")
    }
    
    func readLog() -> String? {
        if let log = try? String(contentsOf: logURL, encoding: .utf8) {
            return log
        }
        
        print("\(fileName) \(#function): failed")
        return nil
    }
    
    private func logLine(timestamp: Date, line: String) {
        if let data = "\(getTimeStampString(from: timestamp)): \(line)\n".data(using: .utf8), let fileHandle = FileHandle(forWritingAtPath: logURL.path) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)            
        }
        else {
            print("\(fileName) \(#function): failed")
        }
    }
    
    // MARK: Print
    
    func printAllJsons() {
        let jsonURLs = getAllJsonURLs()
        
        print("\(fileName) \(#function):")
        for url in jsonURLs {
            let (fileName: fileName, fileExtension: fileExtension) = getFileComponents(fileURL: url)
            
            print("    \(fileName).\(fileExtension)")
        }
    }
    
    private func printAndLog(timestamp: Date, line: String) {
        print(line)
        logLine(timestamp: timestamp, line: line)
    }
    
    private func printData(_ data: Data) {
        let string = String(data: data, encoding: .utf8)
        print("\(fileName) \(#function): \(string!)")
    }
    
    // MARK: Date Formatting
    
    private func getFileNameString(date: Date, type: JsonType) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd a hh-mm-ss"
        let dateString = formatter.string(from: date)
        let jsonString = type.rawValue()
        
        switch type {
            case .routeJson:
                return "\(dateString) \(jsonString)"
            case .delayJson(rowNum: let num):
                return "\(dateString) \(jsonString) \(num)"
        }
    }
    
    private func getTimeStampString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/y E h:mm:ss a (zzz)"
        return formatter.string(from: date)
    }

}

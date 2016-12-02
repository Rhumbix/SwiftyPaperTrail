//
//  SyslogFormatter.swift
//  SwiftyPaperTrail
//
//  Created by Majd Murad on 12/1/16.
//  Copyright © 2016 Rhumbix, Inc. All rights reserved.
//

import UIKit

/*
    Default formatter. Syslog format is:
    \<xx\>timestamp machineName programName: message
    xx => Log Level
    timestamp => Time in UTC
    machineName => Vendor UUID
    programName => CFBundleDisplayName sans whitespace
 
    Customizations:
    machinName
    programName
    dateFormat
    timezone (default is UTC)
    logLevel (default is debug)
*/

class SyslogFormatter: NSObject {
    static let sharedInstance = SyslogFormatter()
    
    enum LogLevel:String{
        case error = "11"
        case warning = "12"
        case info = "14"
        case debug = "15"
//        case verbose = "15"
    }
    
    var machineName:String = UIDevice.current.identifierForVendor!.uuidString
    var programName:String?
    var dateFormat:String = "yyyy-MM-dd'T'HH:mm:ss"
    var timezone:TimeZone = TimeZone(abbreviation: "UTC")!
    var logLevel:LogLevel = .info
    var dateFormatter:DateFormatter?
    
    private func dateString(date:Date) -> String {
        if dateFormatter == nil {
            dateFormatter = DateFormatter()
            dateFormatter!.dateFormat = dateFormat
            dateFormatter!.timeZone = timezone
        }

        return dateFormatter!.string(from: date)
    }
    
    private func getProgramName() -> String {
        if programName != nil {
            return programName!
        }
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleExecutable")
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")
        
        var programArray:[String] = []
        if let appNameString:String = appName as? String {
            programArray.append(appNameString)
        }
        if let versionString:String = version as? String {
            programArray.append(versionString)
        }
        if let buildString:String = build as? String {
            programArray.append(buildString)
        }

        return programArray.count > 0 ? programArray.joined(separator: "-") : "SwiftyPapertrail"

    }
    func formatLogMessage(message:String) -> String {
        return formatLogMessage(message: message, date:Date())
    }
    
    func formatLogMessage(message:String, date:Date) -> String {
        let timeStamp = dateString(date: date)
        let programName = getProgramName()
        return "<\(logLevel.rawValue)>\(timeStamp) \(machineName) \(programName): \(message)"
    }
}

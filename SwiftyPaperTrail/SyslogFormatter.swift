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
    \<22\>timestamp machineName programName: message
    22 => Syslog Numerical Code. Papertrail wants RFC-5424's 22 Code: Local Use
    timestamp => yyyy-MM-dd'T'HH:mm:ss
        timezone is UTC by default. Papertrail allows you to view the 
        logs in any timezone from settings.
    machineName => CFBundleIdentifier
    programName => CFBundleShortVersionString-CFBundleVersion
 
    Customizations:
    machineName
    programName
*/

class SyslogFormatter: NSObject {
    static let sharedInstance = SyslogFormatter()
    
    var machineName:String?
    var programName:String?
    private var dateFormat:String = "yyyy-MM-dd'T'HH:mm:ss"
    private var dateFormatter:DateFormatter!
    
    override init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
    }
    
    private func dateString(date:Date) -> String {
        return dateFormatter!.string(from: date)
    }
    
    private func getMachineName() -> String {
        if machineName != nil {
            return machineName!
        }
        
        var machineString = "SwiftyPapertrailDefaultMachine"
        let identifier = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier")
        if let idString = identifier as? String {
            machineString = idString
        }
        
        return machineString.trimmingCharacters(in: .whitespaces)
    }
    
    private func getProgramName() -> String {
        if programName != nil {
            return programName!
        }
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")
        
        var programArray:[String] = []

        if let versionString:String = version as? String {
            programArray.append(versionString.trimmingCharacters(in: .whitespaces))
        }
        if let buildString:String = build as? String {
            programArray.append(buildString.trimmingCharacters(in: .whitespaces))
        }

        return programArray.count > 0 ? programArray.joined(separator: "-") : "SwiftyPapertrail"

    }
    
    func formatLogMessage(message:String, date:Date = Date()) -> String {
        let timeStamp = dateString(date: date)
        let machineName = getMachineName()
        let programName = getProgramName()
        return "<14>\(timeStamp) \(machineName) \(programName): \(message)"
    }
}

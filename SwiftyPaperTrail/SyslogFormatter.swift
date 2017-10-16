//
//  SyslogFormatter.swift
//  SwiftyPaperTrail
//
//  Created by Majd Murad on 12/1/16.
//  Copyright © 2016 Rhumbix, Inc. All rights reserved.
//

import UIKit
import SwiftyLogger

/*
    Default formatter. Syslog format is:
    \<22\>timestamp machineName programName: message
    22 => Syslog Numerical Code. Papertrail wants RFC-5424's 22 Code: Local Use
     ^^ The above is wrong.  Priority 22 is actual `mail` facility with at `information`
    timestamp => yyyy-MM-dd'T'HH:mm:ss
        timezone is UTC by default. Papertrail allows you to view the 
        logs in any timezone from settings.
    machineName => CFBundleIdentifier
    programName => CFBundleShortVersionString-CFBundleVersion
 
    Customizations:
    machineName
    programName
*/

public class SyslogFormatter : LogMessageFormatter {
    //WARNING: 30 chars are considered invalid by papertrail
    public var machineName : String = SyslogFormatter.inferMachineName()
    public var programName : String = SyslogFormatter.inferProgramName()
    public var facility : SyslogFacilities = SyslogFacilities.mail

    public init() { }

    public class func inferMachineName() -> String {
        var machineString = "SwiftyPapertrail"
        let identifier = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier")
        if let idString = identifier as? String {
            machineString = idString
        }
        
        return machineString.trimmingCharacters(in: .whitespaces)
    }
    
    public class func inferProgramName() -> String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")
        
        var programArray:[String] = []

        if let versionString:String = version as? String {
            programArray.append(versionString.trimmingCharacters(in: .whitespaces))
        }
        if let buildString:String = build as? String {
            programArray.append(buildString.trimmingCharacters(in: .whitespaces))
        }

        return programArray.count > 0 ? programArray.joined(separator: "-") : "iOS"
    }

    public func format(message logMessage: LogMessage) -> String {
        var severity : UInt8 = SyslogSeverity.error.rawValue
        switch(logMessage.logLevel){
        case .debug:
            severity = SyslogSeverity.debug.rawValue
        case .verbose:
            severity = SyslogSeverity.information.rawValue
        case .info:
            severity = SyslogSeverity.information.rawValue
        case .warning:
            severity = SyslogSeverity.warning.rawValue
        case .error:
            severity = SyslogSeverity.error.rawValue
        case .critical:
            severity = SyslogSeverity.critical.rawValue
        }

        let shortedMessage = shortened(message: logMessage.message)

        var packet = RFC5424Packet()
        packet.host = self.machineName
        packet.application = self.programName
        packet.facility = facility.rawValue

        packet.timestamp = logMessage.timestamp
        packet.message = shortedMessage
        packet.severity = severity


        return packet.asString
    }

    private func shortened( message : String ) -> String {
        if message.characters.count > 1000 {
            let index = message.index(message.startIndex, offsetBy: 1000)
            let result = message.substring(to: index)
            return result + "...truncated @ 1K..."
        } else {
            return message
        }
    }
}

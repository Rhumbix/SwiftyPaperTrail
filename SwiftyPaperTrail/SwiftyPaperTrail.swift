//
//  SwiftyPaperTrail.swift
//  SwiftyPaperTrail
//
//  Created by Majd Murad on 11/30/16.
//  Copyright © 2016 Rhumbix, Inc. All rights reserved.
//

import Foundation

class SwiftyPaperTrail {
    // Callbacks
    var callbacks = TaggedCallbacks()
    
    // Can customize the formatter
    var syslogFormatter = SyslogFormatter()

    // Sockets using CocoaAsyncSocket
    var transport : LogWireTrasnport!
    
    private func validatesSyslogFormat(message:String) -> Bool {
        let pattern = "<14>\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2} .+ .+:.*"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let matches = regex.matches(in: message, options: [], range: NSRange(location: 0, length: message.characters.count))
        
        if matches.isEmpty {
            return true
        } else {
            NSLog("Format does not comply with Papertrail Syslog Formatting")
            return false
        }
    }
    
    private func validatesConfiguration() -> Bool {
        guard transport != nil else {
            NSLog("Transport layer was not configured for SwiftyPaperTrail")
            return false
        }
        return true
    }
    
    func disconnect() {
        transport.disconnect()
    }

    func logMessage(message: String, date:Date = Date(), callBack:(() -> Void)?=nil) {
        if !validatesConfiguration() || !validatesSyslogFormat(message: message) {
            return
        }

        let syslogMessage = syslogFormatter.formatLogMessage(message: message, date: date)
        guard let data = syslogMessage.data(using: String.Encoding.utf8) else {
            print("Something went wrong")
            return
        }

        transport.sendData(data: data, callback: callBack)
    }
}

//
//  SwiftyPaperTrail.swift
//  SwiftyPaperTrail
//
//  Created by Majd Murad on 11/30/16.
//  Copyright © 2016 Rhumbix, Inc. All rights reserved.
//

import SwiftyLogger

public class SwiftyPaperTrail : LoggerTarget {

    
    public var minimumLogLevel: LogLevel?

    public var messageFormatter: LogMessageFormatter?

    public var isAsync: Bool = true

    public var queue: DispatchQueue { get { return transport.queue } set { /* TODO: This should probably do something */ } }
    
    // Can customize the formatter
    var syslogFormatter = SyslogFormatter()

    // Sockets using CocoaAsyncSocket
    private var transport : LogWireTrasnport

    public init(wireLayer transport : LogWireTrasnport){
        self.transport = transport
    }

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
    
    func disconnect() {
        transport.disconnect()
    }

    public func log(formattedMessage: String) {
        logMessage(message: formattedMessage, date: Date(), callBack: nil)
    }

    func logMessage(message: String, date:Date = Date(), callBack:(() -> Void)?=nil) {
        if !validatesSyslogFormat(message: message) {
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

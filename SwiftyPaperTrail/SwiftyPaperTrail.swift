//
//  SwiftyPaperTrail.swift
//  SwiftyPaperTrail
//
//  Created by Majd Murad on 11/30/16.
//  Copyright © 2016 Rhumbix, Inc. All rights reserved.
//

import SwiftyLogger

public class SwiftyPaperTrail : LoggerTarget {

    //TODO: Figure out better paradigm
    private var _minimumLogLevel : SwiftyLogger.LogLevel?
    public var minimumLogLevel: SwiftyLogger.LogLevel? {
        get { return _minimumLogLevel }
        set { _minimumLogLevel = newValue }
    }

    private var _messageFormatter : SwiftyLogger.LogMessageFormatter? = SyslogFormatter()
    public var messageFormatter : SwiftyLogger.LogMessageFormatter? {
        get { return _messageFormatter }
        set { _messageFormatter = newValue }
    }

    private var _isAsync : Bool = false
    public var isAsync : Bool {
        get { return _isAsync }
        //TODO: Find more graceful method of dealing with this.
        set {
            if !newValue {
                print("SwityPaperTrail doesn't allow synchronous output")
                abort()
            }
        }
    }

    public var queue: DispatchQueue {
        get { return transport.queue }
        set {
            print("SwityPaperTrail doesn't allow changing queues")
            abort()
        }
    }
    
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
    
    public func disconnect() {
        transport.disconnect()
    }

    public func log(formattedMessage: String) -> Void {
        logMessage(message: formattedMessage, date: Date(), callBack: nil)
    }

    func logMessage(message: String, date:Date = Date(), callBack:(() -> Void)?=nil) {
        guard let data = message.data(using: String.Encoding.utf8, allowLossyConversion: true) else {
            fatalError("Failed to encode as UTF8")
        }

        transport.sendData(data: data, callback: callBack)
    }
}

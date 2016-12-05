//
//  SwiftyPaperTrail.swift
//  SwiftyPaperTrail
//
//  Created by Majd Murad on 11/30/16.
//  Copyright © 2016 Rhumbix, Inc. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

class SwiftyPaperTrail:NSObject, GCDAsyncSocketDelegate, GCDAsyncUdpSocketDelegate {
    static let sharedInstance = SwiftyPaperTrail()

    // Papertrail Destination
    var host:String!
    var port:Int!
    
    // TCP vs UDP
    var useTCP:Bool = true
    
    // Encryption for TCP
    var useTLS:Bool = true
    
    // Should logger emit informational logs
    var debug:Bool = true
    
    // Defaults to vendor identifier UUID
    var machineName:String?
    
    // Defaults to "AppName-AppVersion"
    var programName:String?
    
    // Sockets using CocoaAsyncSocket
    var tcpSocket:GCDAsyncSocket?
    var udpSocket:GCDAsyncUdpSocket?
    
    private func validatesSyslogFormat(message:String) throws {
        let pattern = "<\\d{2}>.+ .+ .+:.{0,}"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let matches = regex.matches(in: message, options: [], range: NSRange(location: 0, length: message.characters.count))
        
        if matches.isEmpty {
            throw SwiftyPaperTrailError.syslogFormatInvalid
        }
    }
    
    enum SwiftyPaperTrailError: Error {
        case syslogFormatInvalid
    }
    
    func disconnect() {
        //        if self.tcpSocket != nil {
        //            self.tcpSocket.disconnect()
        //            self.tcpSocket = nil
        //        } else if self.udpSocket != nil {
        //            udpSocket.disconnect()
        //            self.tcpSocket = nil
        //        }
    }
    
    func logMessage(message: String) {
        let formattedMessage = SyslogFormatter.sharedInstance.formatLogMessage(message: message)
        
//        guard validatesSyslogFormat(message: formattedMessage) else {
//            throw SwiftyPaperTrailError.syslogFormatInvalid
//        }
        
    }
    
    func sendLogOverUDP(message:String) {
        let syslogMessage = SyslogFormatter.sharedInstance.formatLogMessage(message: message)
        host = "logs2.papertrailapp.com"
        port = 29065
        let data = syslogMessage.data(using: String.Encoding.utf8)!
        
        udpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        udpSocket?.send(data, toHost: host, port: UInt16(port), withTimeout: -1, tag: 1)
        
    }

}

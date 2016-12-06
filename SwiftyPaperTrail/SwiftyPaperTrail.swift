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
    var host:String?
    var port:Int?
    
    // TCP vs UDP
    var useTCP:Bool = true
    
    // Encryption for TCP
    var useTLS:Bool = true
    
    // Can customize the formatter
    var syslogFormatter = SyslogFormatter()
    
    // Sockets using CocoaAsyncSocket
    private var tcpSocket:GCDAsyncSocket?
    private var udpSocket:GCDAsyncUdpSocket?
    
    private func validatesSyslogFormat(message:String) -> Bool {
        let pattern = "<22>\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2} .+ .+:.*"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let matches = regex.matches(in: message, options: [], range: NSRange(location: 0, length: message.characters.count))
        
        if matches.isEmpty {
            return true
        } else {
            print("Format does not comply with Syslog Formatting")
            return false
        }
    }
    
    private func validatesConfiguration() -> Bool {
        if host == nil {
            print("Papertrail Host not configured")
            return false
        }
        if port == nil {
            print("Papertrail Port not configured")
            return false
        }
        return true
    }
    
    func disconnect() {
        let queue = DispatchQueue(label: "com.test.LockQueue")
        queue.sync {
            if tcpSocket != nil {
                tcpSocket!.disconnect()
                tcpSocket = nil
            } else if udpSocket != nil {
                udpSocket!.close()
                udpSocket = nil
            }
        }
    }
    
    func logMessage(message: String, date:Date = Date()) {
        if !validatesConfiguration() || !validatesSyslogFormat(message: message) {
            return
        }
        let syslogMessage = syslogFormatter.formatLogMessage(message: message, date: date)
        guard let data = syslogMessage.data(using: String.Encoding.utf8) else {
            print("Something went wrong")
            return
        }
        
        if useTCP {
            print("Using TCP")
            sendLogOverTCP(data: data)
        } else {
            print("Using UDP")
            sendLogOverUDP(data: data)
        }
        
    }
    
    private func sendLogOverTCP(data:Data) {
        if tcpSocket == nil {
            tcpSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
            print(tcpSocket?.delegate)
            connectTCPSocket()

        }

        print("Sending via TCP")
        tcpSocket!.write(data, withTimeout: -1, tag: 1)
    }
    
    private func connectTCPSocket() {
        
        do {
            print("Connecting TCP")
            try tcpSocket!.connect(toHost: host!, onPort: UInt16(port!))
        } catch let error {
            print("Error connecting to host: \(host!). Error: \(error.localizedDescription)")
            return
        }
        
        if useTLS {
            print("Using TLS")
            tcpSocket!.startTLS(nil)
        }
        
    }
    
    private func sendLogOverUDP(data:Data) {
        if udpSocket == nil {
            udpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        }
        print("Sending via UDP")
        udpSocket!.send(data, toHost: host!, port: UInt16(port!), withTimeout: -1, tag: 1)
    }
    
    /*
        GCDAsyncDelegate Methods
    */
    
    func socketDidSecure(_ sock: GCDAsyncSocket) {
        print("Socket Secured")
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print("Connected to \(host):\(port)")
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print("Socket Disconnected. Error: \(err)")
    }
    
    
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        print("Socket wrote data")
    }

}

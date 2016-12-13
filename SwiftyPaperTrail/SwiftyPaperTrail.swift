//
//  SwiftyPaperTrail.swift
//  SwiftyPaperTrail
//
//  Created by Majd Murad on 11/30/16.
//  Copyright © 2016 Rhumbix, Inc. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

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

protocol LogWireTrasnport {
    func sendData( data : Data, callback : (() -> Void)?)
    func disconnect()
}

class TCPTransport : NSObject, GCDAsyncSocketDelegate, LogWireTrasnport {
    private var tcpSocket:GCDAsyncSocket?
    var host : String
    var port : UInt16
    var callbacks = TaggedCallbacks()
    var disconnectionListener : ( (TCPTransport) -> Void )?

    init( to aHost : String, at aPort : UInt16 ){
        host = aHost
        port = aPort
    }

    // Encryption for TCP
    var useTLS:Bool = false

    func sendData( data : Data, callback : (() -> Void)? ) {
        if tcpSocket == nil {
            let queue = DispatchQueue(label: "com.rhumbix.swiftpapertrail")
            tcpSocket = GCDAsyncSocket(delegate: self, delegateQueue: queue, socketQueue: queue)
            connectTCPSocket()
        }
        let tag = callbacks.registerCallback(optionalCallback: callback)
        tcpSocket!.write(data, withTimeout: -1, tag: tag)
    }

    private func connectTCPSocket() {
        do {
            print("Connecting TCP")
            try tcpSocket!.connect(toHost: host, onPort: UInt16(port))
        } catch let error {
            print("Error connecting to host: \(host). Error: \(error.localizedDescription)")
            return
        }

        if useTLS {
            print("Using TLS")
            tcpSocket!.startTLS(nil)
        }

    }

    func disconnect() {
            tcpSocket!.disconnectAfterReadingAndWriting()
            tcpSocket = nil
    }

    //Delegate methods
    @objc func socketDidSecure(_ sock: GCDAsyncSocket) {
        print("Socket Secured")
    }

    @objc func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print("Connected to \(host):\(port)")
    }

    @objc func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print("Socket Disconnected. Error: \(err)")
        disconnectionListener?(self)
    }

    func socket(_ sock: GCDAsyncSocket, didWritePartialDataOfLength partialLength: UInt, tag: Int) {
        print("Partial write")
    }

    @objc func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        callbacks.completed(tag: tag)
    }
}

class UDPTransport : NSObject, GCDAsyncUdpSocketDelegate, LogWireTrasnport  {
    private var udpSocket:GCDAsyncUdpSocket?
    var host:String?
    var port:Int?
    var callbacks = TaggedCallbacks()


    func disconnect() {
        udpSocket!.close()
        udpSocket = nil
    }

    func sendData( data : Data, callback : (() -> Void)? ) {
        if udpSocket == nil {
            udpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        }
        let tag = callbacks.registerCallback(optionalCallback: callback)
        udpSocket!.send(data, toHost: host!, port: UInt16(port!), withTimeout: -1, tag: tag)
    }

    /*
     GCDAsyncUdpSocketDelegate Methods
     */
    func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        callbacks.completed(tag: tag)
    }
}

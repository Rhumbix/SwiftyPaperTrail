//
//  LogWireTrasnport.swift
//  SwiftyPaperTrail
//
//  Created by Mark Eschbach on 12/13/16.
//  Copyright © 2016 Rhumbix, Inc. All rights reserved.
//

import CocoaAsyncSocket

fileprivate let defaultDispatchQueue = DispatchQueue(label: "com.rhumbix.swifty-papertrail")

public protocol LogWireTrasnport {
    var queue : DispatchQueue { get }
    func sendData( data : Data, callback : (() -> Void)?)
    func disconnect()
}

public class BufferingTransport : LogWireTrasnport {
    public var writes = [Data]()
    public var queue : DispatchQueue { get { return defaultDispatchQueue  } }

    public init(){}

    public func sendData( data : Data, callback : (() -> Void)?) {
        defaultDispatchQueue.async {
            self.writes.append(data)
        }
    }

    public func disconnect() {

    }
}

public class TCPTransport : NSObject, GCDAsyncSocketDelegate, LogWireTrasnport {
    private var tcpSocket:GCDAsyncSocket?
    var host : String
    var port : UInt16
    var callbacks = TaggedCallbacks()
    var disconnectionListener : ( (TCPTransport) -> Void )?

    public var queue : DispatchQueue { get { return defaultDispatchQueue } }

    init( to aHost : String, at aPort : UInt16 ){
        host = aHost
        port = aPort
    }

    // Encryption for TCP
    var useTLS:Bool = false

    public func sendData( data : Data, callback : (() -> Void)? ) {
        if tcpSocket == nil {
            tcpSocket = GCDAsyncSocket(delegate: self, delegateQueue: defaultDispatchQueue, socketQueue: defaultDispatchQueue)
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

    public func disconnect() {
        tcpSocket!.disconnectAfterReadingAndWriting()
        tcpSocket = nil
    }

    //Delegate methods
    @objc public func socketDidSecure(_ sock: GCDAsyncSocket) {
        print("Socket Secured")
    }

    @objc public func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print("Connected to \(host):\(port)")
    }

    @objc public func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print("Socket Disconnected. Error: \(err)")
        disconnectionListener?(self)
    }

    @objc public func socket(_ sock: GCDAsyncSocket, didWritePartialDataOfLength partialLength: UInt, tag: Int) {
        print("Partial write")
    }

    @objc public func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        callbacks.completed(tag: tag)
    }
}

extension SwiftyPaperTrail {
    public class func withTCP( to aHost : String, at aPort : UInt16 ) -> SwiftyPaperTrail {
        let tcpLayer = TCPTransport(to: aHost, at: aPort )
        let logger = SwiftyPaperTrail.init(wireLayer: tcpLayer)
        return logger
    }

    public class func withTLSoverTCP( to aHost : String, at aPort : UInt16 ) -> SwiftyPaperTrail {
        let tcpLayer = TCPTransport(to: aHost, at: aPort )
        tcpLayer.useTLS = true
        let logger = SwiftyPaperTrail.init(wireLayer: tcpLayer)
        return logger
    }
}

public class UDPTransport : NSObject, GCDAsyncUdpSocketDelegate, LogWireTrasnport  {
    public var queue: DispatchQueue { get{ return defaultDispatchQueue } }

    private var udpSocket:GCDAsyncUdpSocket?
    internal var host:String?
    internal var port:Int?
    private var callbacks = TaggedCallbacks()

    public func disconnect() {
        udpSocket!.close()
        udpSocket = nil
    }

    public func sendData( data : Data, callback : (() -> Void)? ) {
        if udpSocket == nil {
            udpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: defaultDispatchQueue)
        }
        let tag = callbacks.registerCallback(optionalCallback: callback)
        udpSocket!.send(data, toHost: host!, port: UInt16(port!), withTimeout: -1, tag: tag)
    }

    /*
     GCDAsyncUdpSocketDelegate Methods
     */
    @objc public func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        callbacks.completed(tag: tag)
    }
}

extension SwiftyPaperTrail {
    public class func withUDP( to aHost : String, at aPort : UInt16 ) -> SwiftyPaperTrail {
        let udpLayer = UDPTransport()
        udpLayer.host = aHost
        udpLayer.port = Int(aPort)
        let logger = SwiftyPaperTrail.init(wireLayer: udpLayer)
        return logger
    }
}

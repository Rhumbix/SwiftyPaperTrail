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
    private var host : String
    private var port : UInt16
    private var callbacks = TaggedCallbacks()
    public var disconnectionListener : ( (TCPTransport) -> Void )?

    public var queue : DispatchQueue { get { return defaultDispatchQueue } }

    init( to aHost : String, at aPort : UInt16 ){
        host = aHost
        port = aPort
    }

    // Encryption for TCP
    var useTLS:Bool = false

    public func sendData( data : Data, callback : (() -> Void)? ) {
        if tcpSocket == nil {
            tcpSocket = GCDAsyncSocket(delegate: self, delegateQueue: defaultDispatchQueue, socketQueue: queue)
            connectTCPSocket()
        }
        let tag = callbacks.registerCallback(optionalCallback: callback)
        tcpSocket!.write(data, withTimeout: -1, tag: tag)
    }

    private func connectTCPSocket() {
        do {
            try tcpSocket!.connect(toHost: host, onPort: UInt16(port))
        } catch let error {
            //TODO: Add handler mechanism for this
            print("Error connecting to host: \(host). Error: \(error.localizedDescription)")
            return
        }

        if useTLS {
            tcpSocket!.startTLS(nil)
        }

    }

    public func disconnect() {
        tcpSocket!.disconnectAfterReadingAndWriting()
        tcpSocket = nil
    }

    //Delegate methods
    @objc public func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        disconnectionListener?(self)
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
    private var host : String
    private var port : UInt16
    private var callbacks = TaggedCallbacks()

    init( to aHost : String, at aPort : UInt16 ){
        host = aHost
        port = aPort
    }

    public func disconnect() {
        udpSocket!.close()
        udpSocket = nil
    }

    public func sendData( data : Data, callback : (() -> Void)? ) {
        if udpSocket == nil {
            udpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: queue)
        }
        let tag = callbacks.registerCallback(optionalCallback: callback)
        udpSocket!.send(data, toHost: host, port: port, withTimeout: -1, tag: tag)
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
        let udpLayer = UDPTransport(to: aHost, at: aPort)
        let logger = SwiftyPaperTrail.init(wireLayer: udpLayer)
        return logger
    }
}

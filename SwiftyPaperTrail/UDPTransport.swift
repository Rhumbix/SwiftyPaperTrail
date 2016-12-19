//
//  UDPTransport.swift
//  SwiftyPaperTrail
//
//  Created by Mark Eschbach on 12/19/16.
//  Copyright © 2016 Rhumbix, Inc. All rights reserved.
//

import CocoaAsyncSocket

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

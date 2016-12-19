//
//  LogWireTrasnport.swift
//  SwiftyPaperTrail
//
//  Created by Mark Eschbach on 12/13/16.
//  Copyright © 2016 Rhumbix, Inc. All rights reserved.
//

import CocoaAsyncSocket

public let defaultDispatchQueue = DispatchQueue(label: "com.rhumbix.swifty.papertrail")

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

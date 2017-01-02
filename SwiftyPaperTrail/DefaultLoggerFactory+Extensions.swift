//
//  DefaultLoggerFactory+Extensions.swift
//  SwiftyPaperTrail
//
//  Created by Mark Eschbach on 1/2/17.
//  Copyright © 2017 Rhumbix, Inc. All rights reserved.
//

import SwiftyLogger

public extension LoggerFactory {
    public func addSyslog( to host : String, tcp port : Int ) -> LoggerFactory {
        guard let realPort = UInt16(exactly: port) else {
            fatalError("Port given \(port) is outside of TCP port range")
        }
        let target = SwiftyPaperTrail.withTCP(to: host, at: realPort)
        self.addTarget(target)
        return self
    }

    public func addSyslog( to host : String, tls port : Int ) -> LoggerFactory {
        guard let realPort = UInt16(exactly: port) else {
            fatalError("Port given \(port) is outside of TCP port range")
        }
        let target = SwiftyPaperTrail.withTLSoverTCP(to: host, at: realPort)
        self.addTarget(target)
        return self
    }

    public func addSyslog( to host : String, udp port : Int ) -> LoggerFactory {
        guard let realPort = UInt16(exactly: port) else {
            fatalError("Port given \(port) is outside of UDP port range")
        }
        let target = SwiftyPaperTrail.withUDP(to: host, at: realPort)
        self.addTarget(target)
        return self
    }
}

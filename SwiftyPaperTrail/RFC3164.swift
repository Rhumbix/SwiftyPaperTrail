//
//  RFC3164.swift
//  SwiftyPaperTrail
//
//  Created by Mark Eschbach on 12/27/16.
//  Copyright © 2016 Rhumbix, Inc. All rights reserved.
//

import Foundation

public extension Scanner {
    func verifyConstant(character what : String ) -> Bool {
        let set = CharacterSet(charactersIn: what)
        var string : NSString?
        self.scanCharacters(from: set, into: &string)
        return string != nil && string as! String == what
    }

    func scanUp(to what : String ) -> String? {
        var value : NSString?
        guard self.scanUpTo(what, into: &value), !self.isAtEnd else { return nil }
        guard verifyConstant(character: what) else { return nil }
        return value as? String
    }

    func scanInt() -> Int? {
        var value : Int = 0
        guard self.scanInt(&value) else {
            return nil
        }
        return value
    }

    func remainder() -> String? {
        var value : NSString?
        guard scanUpToCharacters(from: CharacterSet.newlines, into: &value) else { return nil }
        guard isAtEnd else { return nil }

        return value as? String
    }
}

public struct RFC3164Packet {
    public var priority : UInt8 {
        get { return (facility << 3) + severity }
        set {
            facility = newValue >> 3
            severity = newValue & 7
        }
    }

    public var facility : UInt8 = 1 {
        didSet {
            if facility > 23 {
                fatalError("Facility may not be than 23")
            }
        }
    }

    public var severity : UInt8 = 5 {
        didSet {
            if severity > 7 {
                fatalError("Severity may not exced 7")
            }
        }
    }

    public var sender : String?
    public var message : String?
    public var when : Date?

    public init() {}

    public static func parse(packet frame : String ) -> RFC3164Packet {
        func defaultPacket() -> RFC3164Packet {
            var packet = RFC3164Packet()
            packet.priority = 13
            packet.message = frame
            return packet
        }

        let scanner = Scanner(string: frame)

        guard scanner.verifyConstant(character: "<") else { return defaultPacket() }
        guard let priority = scanner.scanInt() else { return defaultPacket() }
        guard scanner.verifyConstant(character: ">") else { return defaultPacket() }

        guard let senderName = scanner.scanUp(to: ":") else  { return defaultPacket() }
        guard let statement = scanner.remainder() else  { return defaultPacket() }

        var message = RFC3164Packet()
        message.priority = UInt8(priority)
        message.sender = senderName
        message.message = statement
        return message
    }
}

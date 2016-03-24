//
//  WahooTrainerSerializer.swift
//  SwiftySensors
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2016 Kinetic. All rights reserved.
//

import Foundation

public class WahooTrainerSerializer {
    
    public class Response {
        private(set) var operationCode: OperationCode!
    }
    
    public enum OperationCode: UInt8 {
        case Unlock         = 32
        case SetLevelMode   = 65
        case SetErgMode     = 66
        case SetSimMode     = 67
    }
    
    public static func unlockCommand() -> [UInt8] {
        return [
            WahooTrainerSerializer.OperationCode.Unlock.rawValue,
            0xee,   // unlock code
            0xfc    // unlock code
        ]
    }
    
    public static func setResistanceModeLevel(level: UInt8) -> [UInt8] {
        return [
            WahooTrainerSerializer.OperationCode.SetLevelMode.rawValue,
            level
        ]
    }
    
    public static func setResistanceModeErg(watts: UInt16) -> [UInt8] {
        return [
            WahooTrainerSerializer.OperationCode.SetErgMode.rawValue,
            UInt8(watts & 0xFF),
            UInt8(watts >> 8)
        ]
        // response: 0x01 0x42 0x01 0x00 watts1 watts2
    }
    
    public static func readReponse(data: NSData) -> Response? {
        let bytes = UnsafePointer<UInt8>(data.bytes)
        let result = bytes[0]   // 01 = success
        let opCodeRaw = bytes[1]
        if let opCode = WahooTrainerSerializer.OperationCode(rawValue: opCodeRaw) {
            
            let response: Response
            
            switch opCode {
            case .SetLevelMode:
                response = Response()
            case .SetErgMode:
                response = Response()
            default:
                response = Response()
            }
            
            response.operationCode = opCode
            return response
        } else {
            print("Unrecognized Operation Code: \(opCodeRaw)")
        }
        if result == 1 {
            print("Success for operation: \(opCodeRaw)")
        }
        
        return nil
    }
    
}

//
//  HeartRateSerializer.swift
//  SwiftySensors
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2016 Kinetic. All rights reserved.
//

import Foundation

public class HeartRateSerializer {
    
    public struct MeasurementData {
        enum ContactStatus {
            case NotSupported
            case NotDetected
            case Detected
        }
        var heartRate: UInt16 = 0
        var contactStatus: ContactStatus = .NotSupported
        var energyExpended: UInt16?
        var rrInterval: UInt16?
    }
    
    public enum BodySensorLocation: UInt8 {
        case Other      = 0
        case Chest      = 1
        case Wrist      = 2
        case Finger     = 3
        case Hand       = 4
        case EarLobe    = 5
        case Foot       = 6
    }
    
    public static func readMeasurement(data: NSData) -> MeasurementData {
        var measurement = MeasurementData()
        
        let bytes = UnsafePointer<UInt8>(data.bytes)
        var index: Int = 0
        let flags = bytes[index];
        index += 1
        
        if flags & 0x01 == 0 {
            measurement.heartRate = UInt16(bytes[index])
        } else {
            measurement.heartRate = ((UInt16)(bytes[index++=])) | ((UInt16)(bytes[index++=])) << 8
        }
        
        let contactStatusBits = (flags | 0x06) >> 1
        if contactStatusBits == 2 {
            measurement.contactStatus = .NotDetected
        } else if contactStatusBits == 3 {
            measurement.contactStatus = .Detected
        }
        if flags & 0x08 == 0x08 {
            measurement.energyExpended = ((UInt16)(bytes[index++=])) | ((UInt16)(bytes[index++=])) << 8
        }
        if flags & 0x10 == 0x10 {
            measurement.rrInterval = ((UInt16)(bytes[index++=])) | ((UInt16)(bytes[index++=])) << 8
        }
        return measurement
    }
    
    
    public static func readSensorLocation(data: NSData) -> BodySensorLocation? {
        let bytes = UnsafePointer<UInt8>(data.bytes)
        return BodySensorLocation(rawValue: bytes[0])
    }
    
    public static func writeResetEnergyExpended() -> [UInt8] {
        return [
            0x01
        ]
    }
    
}

//
//  CyclingSpeedCadenceSerializer.swift
//  SwiftySensors
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2016 Kinetic. All rights reserved.
//

import Foundation

public class CyclingSpeedCadenceSerializer {
    
    struct MeasurementFlags: OptionSetType {
        let rawValue: UInt16
        
        static let WheelRevolutionDataPresent   = MeasurementFlags(rawValue: 1 << 0)
        static let CrankRevolutionDataPresent   = MeasurementFlags(rawValue: 1 << 1)
    }
    
    public struct Features: OptionSetType {
        public let rawValue: UInt16
        
        public static let WheelRevolutionDataSupported         = Features(rawValue: 1 << 0)
        public static let CrankRevolutionDataSupported         = Features(rawValue: 1 << 1)
        public static let MultipleSensorLocationsSupported     = Features(rawValue: 1 << 2)
        
        public init(rawValue: UInt16) {
            self.rawValue = rawValue
        }
    }
    
    public struct MeasurementData: CyclingMeasurementData {
        public var cumulativeWheelRevolutions: UInt32?
        public var lastWheelEventTime: UInt16?
        public var cumulativeCrankRevolutions: UInt16?
        public var lastCrankEventTime: UInt16?
    }
    
    
    public static func readFeatures(data: NSData) -> Features {
        let bytes = UnsafePointer<UInt8>(data.bytes)
        let rawFeatures: UInt16 = ((UInt16)(bytes[0])) | ((UInt16)(bytes[1])) << 8
        return Features(rawValue: rawFeatures)
    }
    
    public static func readMeasurement(data: NSData) -> MeasurementData {
        var measurement = MeasurementData()
        
        let bytes = UnsafePointer<UInt8>(data.bytes)
        var index: Int = 0
        
        let rawFlags: UInt16 = ((UInt16)(bytes[index++=])) | ((UInt16)(bytes[index++=])) << 8
        let flags = MeasurementFlags(rawValue: rawFlags)
        
        if flags.contains(.WheelRevolutionDataPresent) {
            measurement.cumulativeWheelRevolutions = ((UInt32)(bytes[index++=])) | ((UInt32)(bytes[index++=])) << 8 | ((UInt32)(bytes[index++=])) << 16 | ((UInt32)(bytes[index++=])) << 24
            measurement.lastWheelEventTime = ((UInt16)(bytes[index++=])) | ((UInt16)(bytes[index++=])) << 8
        }
        
        if flags.contains(.CrankRevolutionDataPresent) {
            measurement.cumulativeCrankRevolutions = ((UInt16)(bytes[index++=])) | ((UInt16)(bytes[index++=])) << 8
            measurement.lastCrankEventTime = ((UInt16)(bytes[index++=])) | ((UInt16)(bytes[index++=])) << 8
        }
        
        return measurement
    }
    
}
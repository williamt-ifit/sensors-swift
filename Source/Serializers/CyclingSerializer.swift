//
//  CyclingSerializer.swift
//  SwiftySensors
//
//  Copyright © 2016 Kinetic. All rights reserved.
//

import Foundation

public protocol CyclingMeasurementData {
    var timestamp: Double { get }
    var cumulativeWheelRevolutions: UInt32? { get }
    var lastWheelEventTime: UInt16? { get }
    var cumulativeCrankRevolutions: UInt16? { get }
    var lastCrankEventTime: UInt16? { get }
}

public class CyclingSerializer {
    
    public enum SensorLocation: UInt8 {
        case Other          = 0
        case TopOfShoe      = 1
        case InShoe         = 2
        case Hip            = 3
        case FrontWheel     = 4
        case LeftCrank      = 5
        case RightCrank     = 6
        case LeftPedal      = 7
        case RightPedal     = 8
        case FrontHub       = 9
        case RearDropout    = 10
        case Chainstay      = 11
        case RearWheel      = 12
        case RearHub        = 13
        case Chest          = 14
        case Spider         = 15
        case ChainRing      = 16
    }
    
    public static func readSensorLocation(data: NSData) -> SensorLocation? {
        let bytes = UnsafePointer<UInt8>(data.bytes)
        return SensorLocation(rawValue: bytes[0])
    }
    
    
    public static func calculateWheelKPH(current: CyclingMeasurementData, previous: CyclingMeasurementData, wheelCircumferenceCM: Double, wheelTimeResolution: Int) -> Double? {
        guard let cwr1 = current.cumulativeWheelRevolutions else { return nil }
        guard let cwr2 = previous.cumulativeWheelRevolutions else { return nil }
        guard let lwet1 = current.lastWheelEventTime else { return nil }
        guard let lwet2 = previous.lastWheelEventTime else { return nil }
        
        let wheelRevsDelta: UInt32 = deltaWithRollover(cwr1, old: cwr2, max: UInt32.max)
        let wheelTimeDelta: UInt16 = deltaWithRollover(lwet1, old: lwet2, max: UInt16.max)
        
        let wheelTimeSeconds = Double(wheelTimeDelta) / Double(wheelTimeResolution)
        if wheelTimeSeconds > 0 {
            let wheelRPM = Double(wheelRevsDelta) / (wheelTimeSeconds / 60)
            let cmPerKm = 0.00001
            let minsPerHour = 60.0
            return wheelRPM * wheelCircumferenceCM * cmPerKm * minsPerHour
        }
        return 0
    }
    
    
    public static func calculateCrankRPM(current: CyclingMeasurementData, previous: CyclingMeasurementData) -> Double? {
        guard let ccr1 = current.cumulativeCrankRevolutions else { return nil }
        guard let ccr2 = previous.cumulativeCrankRevolutions else { return nil }
        guard let lcet1 = current.lastCrankEventTime else { return nil }
        guard let lcet2 = previous.lastCrankEventTime else { return nil }
        
        let crankRevsDelta: UInt16 = deltaWithRollover(ccr1, old: ccr2, max: UInt16.max)
        let crankTimeDelta: UInt16 = deltaWithRollover(lcet1, old: lcet2, max: UInt16.max)
        
        let crankTimeSeconds = Double(crankTimeDelta) / 1024
        if crankTimeSeconds > 0 {
            return Double(crankRevsDelta) / (crankTimeSeconds / 60)
        }
        return 0
    }
    
    private static func deltaWithRollover<T: IntegerType>(new: T, old: T, max: T) -> T {
        return old > new ? max - old + new : new - old
    }
}

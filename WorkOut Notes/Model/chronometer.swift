//
//  chronometer.swift
//  WorkOut Notes
//
//  Created by Vicente Enguidanos on 16/06/2022.
//

import Foundation


class chronometer {
    
    var count:Int = 0
    
    func secondsToHoursMinutesSeconds(time: Int) -> (Int, Int, Int)
    {
        
        let seconds = time / 100
        let milisecString = String(time)
        let miliseconds = Int(milisecString.suffix(2))

        return (((seconds % 3600) / 60),((seconds % 3600) % 60),miliseconds ?? 0)
    }
    
    func makeTimeString(hours: Int, minutes: Int, seconds : Int) -> String
    {
        var timeString = ""
        timeString += String(format: "%02d", hours)
        timeString += ":"
        timeString += String(format: "%02d", minutes)
        timeString += ":"
        timeString += String(format: "%02d", seconds)
        return timeString
    }

    
}




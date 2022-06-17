//
//  chronometer.swift
//  WorkOut Notes
//
//  Created by Vicente Enguidanos on 16/06/2022.
//

import Foundation


class chronometer {
    
    var count:Int = 0
    
    func secondsToHoursMinutesSeconds(seconds: Int) -> (Int, Int)
    {
        return (((seconds % 3600) / 60),((seconds % 3600) % 60))
    }
    
    func makeTimeString(minutes: Int, seconds : Int) -> String
    {
        var timeString = ""
        timeString += String(format: "%02d", minutes)
        timeString += " : "
        timeString += String(format: "%02d", seconds)
        return timeString
    }

    
}




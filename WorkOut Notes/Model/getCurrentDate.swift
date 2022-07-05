//
//  getCurrentDate.swift
//  WorkOut Notes
//
//  Created by Vicente Enguidanos on 22/06/2022.
//

import Foundation


func getCurrentDate() -> String{
    
    let mytime = Date()
    let format = DateFormatter()
    format.dateFormat = "yyyy-MM-dd"
    return (format.string(from: mytime))
    
}

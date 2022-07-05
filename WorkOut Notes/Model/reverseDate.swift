//
//  reverseDate.swift
//  WorkOut Notes
//
//  Created by Vicente Enguidanos on 20/06/2022.
//

import Foundation

func reverseDate(date: String) -> String{
    
    var aaaa: String
    var dd: String
    var mm: String

    dd = String(date.suffix(2))
    aaaa = String(date.prefix(4))

    mm = String(date.suffix(5))
    mm = String(mm.prefix(2))
    
    return (dd + "-" + mm + "-" + aaaa)
    
}

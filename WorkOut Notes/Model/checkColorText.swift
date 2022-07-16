//
//  checkColorText.swift
//  WorkOut Notes
//
//  Created by Vicente Enguidanos on 16/07/2022.
//

import UIKit

func checkColorText(prev: Float, curr: Float) -> UIColor{

    if curr == 0{
        return UIColor(red: 0.875, green: 0.965, blue: 1.000, alpha: 1)
    }else if prev > curr{
        return .red
    }else if prev < curr{
        return .green
    }else{
        return UIColor(red: 0.875, green: 0.965, blue: 1.000, alpha: 1)
    }
}

func checkColorText(prev: Int16, curr: Int16) -> UIColor{
    
    if curr == 0{
        return UIColor(red: 0.875, green: 0.965, blue: 1.000, alpha: 1)
    }else if prev > curr{
        return .red
    }else if prev < curr{
        return .green
    }else{
        return UIColor(red: 0.875, green: 0.965, blue: 1.000, alpha: 1)
    }
}

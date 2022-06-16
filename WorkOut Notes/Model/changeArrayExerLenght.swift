//
//  changeArrayExerLenght.swift
//  WorkOut Notes
//
//  Created by Vicente Enguidanos on 16/06/2022.
//

import UIKit

func changeArrayExerLenght(of array: [Exercises], to newLength: Int) -> [Exercises] {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var array2 = array
    
    if newLength < array.count {
        return Array(array.prefix(newLength))
    } else if newLength == array.count {
        return array
    } else {
        for _ in 1...(newLength - array.count){
            let exercise = Exercises(context: context)
            
            array2.append(exercise)
            
        }
       // return array + Array(repeating: Exercises(context: context), count: newLength - array.count)
        return array2
    }
}

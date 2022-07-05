//
//  AddModifyViewController.swift
//  WorkOut Notes
//
//  Created by Vicente Enguidanos on 08/06/2022.
//

import UIKit
import CoreData

class AddModifyViewController: UIViewController, UITableViewDelegate {
    
    //  var currentRow: Int = 0
    var numberOfSets: Int = 0
    var initialCount: Int = 0
    var exerciseName: String = ""
    var exercise = [Exercises]()
    var emptyArray = false
    
    //se crea "el view de la base de datos"
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var setsTableView: UITableView!
    @IBOutlet weak var exerciseTextField: UITextField!
    @IBOutlet weak var setsTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emptyArray = false
        
        setsTableView.dataSource = self
        setsTableView.delegate = self
        // numberOfSets = Int(exerciseHeader.sets)
        
        exerciseTextField.text = exerciseName
        
        loadExercise()
        
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        
        for i in 0..<numberOfSets{
            exercise[i].exerciseName = exerciseName
            exercise[i].sets = Int16(numberOfSets)
            if emptyArray{
                exercise[i].date = "0000-00-00"
            }else{
                exercise[i].date = exercise[0].date
            }
            exercise[i].comment = ""
            exercise[i].numberOfSet = Int16(i + 1)
            
        }
        
        if initialCount > numberOfSets{
            for i in numberOfSets..<initialCount{
                context.delete(exercise[i])
            }
        }
        
        saveData()
        print (exercise)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func setsFieldChanged(_ sender: UITextField) {
        
        if isStringAnInt(string: sender.text!){
            numberOfSets = Int(sender.text!)!
            
            self.setsTableView.reloadData()
        }
    }
}

// MARK: extension 1

extension AddModifyViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if initialCount < numberOfSets{
        //change the lenght of array
        exercise = changeArrayExerLenght(of: exercise, to: numberOfSets)
        }
        
        return Int(numberOfSets)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = setsTableView.dequeueReusableCell(withIdentifier: "setsCell", for: indexPath) as! setsCellPrototype
        

        cell.repsOnTableTextField.text = String(exercise[indexPath.row].reps)
        cell.weightOnTableTextField.text = String(exercise[indexPath.row].weight)
        cell.setOnTableTextField.text = String(indexPath.row + 1)
        
        cell.repsOnTableTextField.tag = indexPath.row
        cell.repsOnTableTextField.delegate = self
        
        cell.weightOnTableTextField.tag = indexPath.row
        cell.weightOnTableTextField.delegate = self
        
        return cell
    }
    
    
    func loadExercise(){
        
        //Find all the exercises thanks to header
        let predicateName = NSPredicate(format: "exerciseName == %@", exerciseName)
        let predicateSets = NSPredicate(format: "numberOfSet > %i", 0)
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [predicateName,predicateSets])
        let request: NSFetchRequest<Exercises> = Exercises.fetchRequest()
        
        request.predicate = predicate
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do{
            exercise = try context.fetch(request)
        }catch{
            print("Error fetch\(error)")
        }
        
        if exercise.count != 0{
            let predicateName2 = NSPredicate(format: "exerciseName == %@", exerciseName)
            let predicateDate = NSPredicate(format: "date == %@", exercise[0].date! as CVarArg)
            let predicateNset = NSPredicate(format: "numberOfSet > %i", 0)
            let predicate2 = NSCompoundPredicate(type: .and, subpredicates: [predicateName2,predicateDate,predicateNset])
            let request2: NSFetchRequest<Exercises> = Exercises.fetchRequest()
            request2.predicate = predicate2
            request2.sortDescriptors = [NSSortDescriptor(key: "numberOfSet", ascending: true)]
            
            do{
                exercise = try context.fetch(request2)
            }catch{
                print("Error fetch\(error)")
            }
        }
        
        numberOfSets = exercise.count
        initialCount = exercise.count
        
        if numberOfSets != 0 {
            setsTextField.text = String(numberOfSets)
        }else{
            emptyArray = true
        }
        
        self.setsTableView.reloadData()
        
    }
    func saveData(){
        do {
            try context.save()
        } catch {
            
            print("Error saving workout\(error)")
            
        }
    }
    
}


// MARK: extension 2

extension AddModifyViewController: UITextFieldDelegate{
    
    //delegate method texfield, trigger when finish typing

    func textFieldDidEndEditing(_ textField: UITextField) {
        
        let row = textField.tag
        
        //check which textfield is selected
        if ((setsTableView.cellForRow(at: IndexPath(row: row, section: 0)) as! setsCellPrototype).repsOnTableTextField.self == textField.self){
            if isStringAnInt(string: textField.text ?? " "){
                exercise[row].reps = Int16(textField.text!)!
            }
        }else{
            if isStringAnInt(string: textField.text ?? " "){
                exercise[row].weight = Float(textField.text!)!
            }
        }
        print (row)
        print (exercise)
    }
    
    
}

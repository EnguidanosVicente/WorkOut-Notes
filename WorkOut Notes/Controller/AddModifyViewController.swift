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
    var exerciseName: String = ""
    var exercise = [Exercises]()
    
    
    //se crea "el view de la base de datos"
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet weak var setsTableView: UITableView!
    @IBOutlet weak var exerciseTextField: UITextField!
    @IBOutlet weak var setsTextField: UITextField!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        setsTableView.dataSource = self
        setsTableView.delegate = self
       // numberOfSets = Int(exerciseHeader.sets)
        
        exerciseTextField.text = exerciseName
        
        loadWorkOut()
        
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let now = Date()
        
        for i in 0..<numberOfSets{
            
            if i < exercise.count{
            
                exercise[i].exerciseName = exerciseName
                exercise[i].sets = Int16(numberOfSets)
                exercise[i].numberOfSet = Int16((setsTableView.cellForRow(at: IndexPath(row: i, section: 0)) as! setsCellPrototype).setOnTableTextField.text!)!
                exercise[i].reps = Int16((setsTableView.cellForRow(at: IndexPath(row: i, section: 0)) as! setsCellPrototype).repsOnTableTextField.text ?? "0") ?? 0
                exercise[i].weight = Float((setsTableView.cellForRow(at: IndexPath(row: i, section: 0)) as! setsCellPrototype).weightOnTableTextField.text ?? "0") ?? 0
              //  exercise[i].date = exercise[i].date
              //  exercise[i].comment = ""
                
            }else{
                
                let addExercise = Exercises(context: self.context)
                
                addExercise.exerciseName = exerciseName
                addExercise.sets = Int16(numberOfSets)
                addExercise.numberOfSet = Int16((setsTableView.cellForRow(at: IndexPath(row: i, section: 0)) as! setsCellPrototype).setOnTableTextField.text!)!
                addExercise.reps = Int16((setsTableView.cellForRow(at: IndexPath(row: i, section: 0)) as! setsCellPrototype).repsOnTableTextField.text ?? "0") ?? 0
                addExercise.weight = Float((setsTableView.cellForRow(at: IndexPath(row: i, section: 0)) as! setsCellPrototype).weightOnTableTextField.text ?? "0") ?? 0
                addExercise.date = dateFormatter.string(from: now)
                addExercise.comment = ""
                
                exercise.append(addExercise)
            }
        }

        saveData()
        print (exercise)
        
    }
    
    @IBAction func setsFieldChanged(_ sender: UITextField) {
    
        if isStringAnInt(string: sender.text!){
            numberOfSets = Int(sender.text!)!
            
            self.setsTableView.reloadData()
        }
    }
}

// MARK: extension

extension AddModifyViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Int(numberOfSets)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = setsTableView.dequeueReusableCell(withIdentifier: "setsCell", for: indexPath) as! setsCellPrototype
        
        if  indexPath.row < exercise.count{
            cell.setOnTableTextField.text = String(exercise[indexPath.row].numberOfSet)
            cell.repsOnTableTextField.text = String(exercise[indexPath.row].reps)
            cell.weightOnTableTextField.text = String(exercise[indexPath.row].weight)
        }else{
            cell.setOnTableTextField.text = String(indexPath.row + 1)
            cell.repsOnTableTextField.text = ""
            cell.weightOnTableTextField.text = ""
        }
        
        return cell
    }

    
    func loadWorkOut(){
        
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
        
        if exercise.count != 0 {
            setsTextField.text = String(exercise.count)
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

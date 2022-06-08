//
//  ManageViewController.swift
//  WorkOut Notes
//
//  Created by Vicente Enguidanos on 08/06/2022.
//

import UIKit
import CoreData

class ManageViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var workoutTableView: UITableView!
    @IBOutlet weak var exerciseTableView: UITableView!
    @IBOutlet weak var workoutButton: UIButton!
    @IBOutlet weak var exerciseButton: UIButton!
    
    var numRow: Int = 0
    var lastRow: Int = 0
    
    let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    var workout = [WorkOut]()
    var exercise = [Exercises]()
    
    //se crea "el view de la base de datos"
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print (path)
        
        workoutTableView.dataSource = self
        workoutTableView.delegate = self
        
        exerciseTableView.dataSource = self
        exerciseTableView.delegate = self
        
        loadWorkout()
        
    }
    
    @IBAction func AddWorkoutPress(_ sender: UIButton) {
        
        var newText = UITextField()
        
        let alert = UIAlertController(title: "Add woukout", message: "", preferredStyle: .alert)
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "example: Monday"
            newText = alertTextField
        }
        
        let actionAdd = UIAlertAction(title: "Add", style: .default) { action in
            print("success")
//            self.titleWorkout.append(Workout(workoutName: newText.text!, exerciseList: nil))
        //    workout.workOutName = newText.text!
          
            let newWorkout = WorkOut(context: self.context)
            
            newWorkout.workOutName = newText.text!
            
            self.workout.append(newWorkout)
            
            self.saveData()
            
          //  self.exerciseTableView.reloadData()
            self.workoutTableView.reloadData()
            
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .destructive) { action in
            print("CANCEL")
        }
        
        alert.addAction(actionAdd)
        alert.addAction(actionCancel)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func AddExercisePress(_ sender: UIButton) {
        
        var newText = UITextField()
     
        let alert = UIAlertController(title: "Add exercise", message: "", preferredStyle: .alert)
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "example: bench press"
            newText = alertTextField
        }
        let actionAdd = UIAlertAction(title: "Add", style: .default) { action in
          
            let newExercise = Exercises(context: self.context)
            
            newExercise.exerciseName = newText.text!
            newExercise.sets = 4
           // newExercise.ecercisesToWorkout = self.workout[self.numRow].workoutToExercises
            newExercise.addToEcercisesToWorkout(self.workout[self.numRow])
            
            self.exercise.append(newExercise)
            
            self.saveData()
            
            self.exerciseTableView.reloadData()
            
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .destructive) { action in
            print("CANCEL")
        }
        
        alert.addAction(actionAdd)
        alert.addAction(actionCancel)
        present(alert, animated: true, completion: nil)
    }

}



// MARK: extension

extension ManageViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
    //    var count: Int = 0
        
        if tableView == self.workoutTableView {
            
            return workout.count
            
            //count = workout.count + 1
            //lastRow = count - 1
        }
        
        if tableView == self.exerciseTableView {
            
            return exercise.count
            
//            if numRow == nil{
//                count =  workout.count
//            }else{
//                count = titleWorkout[numRow!].exerciseList?.count ?? 0
//            }
        }
        
  //      return count
     return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        var cell: UITableViewCell = UITableViewCell.init()

        
        if tableView == self.workoutTableView {
            cell = workoutTableView.dequeueReusableCell(withIdentifier: "WorkoutCell", for: indexPath)
          //  let addCell = workoutTableView.dequeueReusableCell(withIdentifier: "addCell", for: indexPath)
            
      //      if indexPath.row == lastRow{
     //           addCell.textLabel?.text = "add"
       //         return addCell
      //      }else{
                cell.textLabel?.text = workout[indexPath.row].workOutName
       //     }
        }
        if tableView == self.exerciseTableView {
            
            cell = exerciseTableView.dequeueReusableCell(withIdentifier: "ExerciseCell", for: indexPath)
            cell.textLabel?.text = exercise[indexPath.row].exerciseName
//
//            if numRow == nil{
//                cell.textLabel?.text = exercise[indexPath.row].exerciseName
//            }else{
//
//                if self.exercise.contains(where: { $0.exerciseName == titleWorkout[numRow!].exerciseList?[indexPath.row]}){
//
//                    cell.textLabel?.text = titleWorkout[numRow!].exerciseList?[indexPath.row]
//
//                    }
//                }
            }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     //   if tableView == self.workoutTableView && indexPath.row != lastRow
        if tableView == self.workoutTableView{
            //guarda la posicion de la celda seleccionada
            numRow = indexPath.row
            
            let categoryPredicate = NSPredicate(format: "ecercisesToWorkout.workOutName CONTAINS[cd] %@", workout[numRow].workOutName!)
            
            loadExercise(categoryPredicate: categoryPredicate)
            
         //   self.exerciseTableView.reloadData()
        }
    }
    
    func saveData(){
        do {
            try context.save()
        } catch {
          
            print("Error saving workout\(error)")
           
    }
    }
    
    func loadWorkout(){
        
        let request: NSFetchRequest<WorkOut> = WorkOut.fetchRequest()
        
        do{
        workout = try context.fetch(request)
        }catch{
            print("Error fetch\(error)")
        }
        self.workoutTableView.reloadData()
    }
        
    func loadExercise(categoryPredicate: NSPredicate){
        
        let request2: NSFetchRequest<Exercises> = Exercises.fetchRequest()

        request2.predicate = categoryPredicate
        
        do{
        exercise = try context.fetch(request2)
        }catch{
            print("Error fetch\(error)")
        }
        self.exerciseTableView.reloadData()
    }
    
}
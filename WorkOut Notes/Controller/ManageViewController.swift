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
    var segueName: String = ""
    var lastRow: Int = 0
    
    let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    var workout = [WorkOut]()
    var exercise = [Exercises]()
    
    //se crea "el view de la base de datos"
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print (path)
        
        workoutTableView.backgroundColor = UIColor.clear
        exerciseTableView.backgroundColor = UIColor.clear
        
        workoutTableView.dataSource = self
        workoutTableView.delegate = self
        
        exerciseTableView.dataSource = self
        exerciseTableView.delegate = self
        
        exerciseButton.isEnabled = false
        
        loadWorkout()
        
    }
    
    @IBAction func AddWorkoutPress(_ sender: UIButton) {
        
        var newText = UITextField()
        
        let alert = UIAlertController(title: NSLocalizedString("Add woukout", comment: "Add woukout"), message: "", preferredStyle: .alert)
        alert.addTextField { alertTextField in
            alertTextField.placeholder = NSLocalizedString("Example: Monday", comment: "Example: Monday")
            newText = alertTextField
        }
        
        let actionAdd = UIAlertAction(title: NSLocalizedString("Add", comment: "Add"), style: .default) { action in
            print("success")
            //            self.titleWorkout.append(Workout(workoutName: newText.text!, exerciseList: nil))
            //    workout.workOutName = newText.text!
            
            let newWorkout = WorkOut(context: self.context)
            
            newWorkout.workOutName = newText.text!
            newWorkout.order = Int16(self.workout.count + 1)
            
            self.workout.append(newWorkout)
            
            self.saveData()
            
            //  self.exerciseTableView.reloadData()
            self.workoutTableView.reloadData()
            
        }
        let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive) { action in
            print("CANCEL")
        }
        
        alert.addAction(actionAdd)
        alert.addAction(actionCancel)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func AddExercisePress(_ sender: UIButton) {
        
        var newText = UITextField()
        
        let alert = UIAlertController(title: NSLocalizedString("Add exercise", comment: "Add exercise"), message: "", preferredStyle: .alert)
        alert.addTextField { alertTextField in
            alertTextField.placeholder = NSLocalizedString("Example: bench press", comment: "Example: bench press")
            newText = alertTextField
        }
        let actionAdd = UIAlertAction(title: NSLocalizedString("Add", comment: "Add"), style: .default) { action in
            
            //Fill exercises with all to check if already exists
            self.loadExerciseBackgorund()
            
            let (repeatedYes, rowUpdate) = self.checkRepeatedWorkout(exerciseName: newText.text!)
            
            if repeatedYes{
                self.exercise[rowUpdate].addToEcercisesToWorkout(self.workout[self.numRow])
            }else{
                
                let newExercise = Exercises(context: self.context)
                
                newExercise.exerciseName = newText.text!
                newExercise.sets = 0
                newExercise.numberOfSet = 0
                newExercise.addToEcercisesToWorkout(self.workout[self.numRow])
                
                self.exercise.append(newExercise)
                self.segueName = newExercise.exerciseName ?? ""
                self.performSegue(withIdentifier: "toAddEdit", sender: self)
            }
            self.saveData()
            self.loadExercise()
        }
        let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive) { action in
            print("CANCEL")
        }
        
        alert.addAction(actionAdd)
        alert.addAction(actionCancel)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        
        workoutTableView.isEditing.toggle()
        exerciseTableView.isEditing.toggle()
        
        if sender.title == "Edit"{
            sender.title = "Done"
        }else if sender.title == "Done"{
            sender.title = "Edit"
        }
        if sender.title == "Editar"{
            sender.title = "Listo"
        }else if sender.title == "Listo"{
            sender.title = "Editar"
        }
        
        //sender.title = sender.title == "Edit" ? "Done" : "Edit"
        
    }
}



// MARK: extension

extension ManageViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.workoutTableView {
            
            return workout.count
        }
        
        if tableView == self.exerciseTableView {
            
            return exercise.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell = UITableViewCell.init()
            
        if tableView == self.workoutTableView {
            cell = workoutTableView.dequeueReusableCell(withIdentifier: "WorkoutCell", for: indexPath)
            cell.textLabel?.text = workout[indexPath.row].workOutName
        }
        if tableView == self.exerciseTableView {
            cell = exerciseTableView.dequeueReusableCell(withIdentifier: "ExerciseCell", for: indexPath)
            cell.textLabel?.text = exercise[indexPath.row].exerciseName
        }
        
        cell.textLabel?.textColor = UIColor(named: "Color7")
        cell.backgroundView = UIView()
        cell.backgroundView?.backgroundColor = .clear
        cell.backgroundView?.layer.borderWidth = 0
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.layer.borderColor = CGColor(red: 0.875, green: 0.965, blue: 1.000, alpha: 1)
        cell.selectedBackgroundView?.layer.borderWidth = 2
        cell.selectedBackgroundView?.layer.cornerRadius = 5
        cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.textLabel?.numberOfLines = 1
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        exerciseButton.isEnabled = true
        
        if tableView == self.workoutTableView{
            //save position
            numRow = indexPath.row
            
            loadExercise()
            
        }
        
        if tableView == self.exerciseTableView{
            segueName = exercise[indexPath.row].exerciseName ?? ""
            performSegue(withIdentifier: "toAddEdit", sender: self)
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! AddModifyViewController
        
        if segue.identifier == "toAddEdit"{
            destinationVC.exerciseName = segueName
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        if tableView == self.workoutTableView{
            
            workout.rearrange(from: sourceIndexPath.row, to: destinationIndexPath.row)
            for i in 0..<workout.count{
                workout[i].order = Int16(i)
            }

            saveData()
         
        }else{

            exercise.rearrange(from: sourceIndexPath.row, to: destinationIndexPath.row)
            for i in 0..<exercise.count{
                exercise[i].order = Int16(i)
            }

            saveData()
            
        }
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if tableView == self.workoutTableView {
            if editingStyle == .delete {
                context.delete(workout[indexPath.row])
                workout.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                saveData()
            }
        }
        
        if tableView == self.exerciseTableView {
            if editingStyle == .delete {
                exercise[indexPath.row].removeFromEcercisesToWorkout(self.workout[self.numRow])
                exercise.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
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
        request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        
        do{
            workout = try context.fetch(request)
            
        }catch{
            print("Error fetch\(error)")
        }
        self.workoutTableView.reloadData()
    }
    
    func loadExercise(){
        
        let relationshipPredicate = NSPredicate(format: "ecercisesToWorkout.workOutName CONTAINS[cd] %@", workout[numRow].workOutName!)
        //*number of set 0 defines the header of the sets*
        let set0Predicate = NSPredicate(format: "numberOfSet == %i", 0)
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [relationshipPredicate,set0Predicate])
        
        let request2: NSFetchRequest<Exercises> = Exercises.fetchRequest()
        request2.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        request2.predicate = predicate
        
        do{
            exercise = try context.fetch(request2)
        }catch{
            print("Error fetch\(error)")
        }
        self.exerciseTableView.reloadData()
    }
    func loadExerciseBackgorund(){
        
        let request: NSFetchRequest<Exercises> = Exercises.fetchRequest()
        
        do{
            exercise = try context.fetch(request)
        }catch{
            print("Error fetch\(error)")
        }
    }
    
    func checkRepeatedWorkout(exerciseName: String) -> (Bool,row: Int){
        
        if exercise.count != 0{
            for i in 0...(exercise.count - 1){
                if exercise[i].exerciseName == exerciseName{
                    return (true,i)
                }
            }
        }
        return (false,0)
        
    }
    
}

extension Array {
    mutating func rearrange(from: Int, to: Int) {
        insert(remove(at: from), at: to)
    }
}

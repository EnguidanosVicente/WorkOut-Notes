//
//  selectExerciseViewController.swift
//  WorkOut Notes
//
//  Created by Vicente Enguidanos on 17/06/2022.
//

import UIKit
import CoreData

class SelectExerciseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var exercisesTableView: UITableView!
    var exerciseName: String = ""
    var workoutName: String = ""
    var exercises = [Exercises]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var segueName:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        exercisesTableView.backgroundColor = UIColor.clear
        exercisesTableView.dataSource = self
        exercisesTableView.delegate = self
        loadExercises()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        var cell: UITableViewCell = UITableViewCell.init()
        
        cell = exercisesTableView.dequeueReusableCell(withIdentifier: "cellExercise", for: indexPath)
        cell.textLabel?.text = exercises[indexPath.row].exerciseName
        cell.textLabel?.font = UIFont.systemFont(ofSize: 25)
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.textLabel?.numberOfLines = 1
        cell.textLabel?.textColor = UIColor(named: "Color7")
        cell.backgroundView?.backgroundColor = .clear
        cell.backgroundView?.layer.borderWidth = 0
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.layer.borderColor = CGColor(red: 0.875, green: 0.965, blue: 1.000, alpha: 1)
        cell.selectedBackgroundView?.layer.borderWidth = 2
        cell.selectedBackgroundView?.layer.cornerRadius = 5
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        exerciseName = exercises[indexPath.row].exerciseName ?? ""
        performSegue(withIdentifier: "toRecord", sender: self)
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! RecordViewController
        
        if segue.identifier == "toRecord"{
            destinationVC.exerciseName = exerciseName
        }
    }
    
    func loadExercises(){
        
        let relationshipPredicate = NSPredicate(format: "ecercisesToWorkout.workOutName CONTAINS[cd] %@", workoutName)
        //*number of set 0 defines the header of the sets*
        let set0Predicate = NSPredicate(format: "numberOfSet == %i", 0)
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [relationshipPredicate,set0Predicate])
        
        let request: NSFetchRequest<Exercises> = Exercises.fetchRequest()
        
        request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        request.predicate = predicate
        
        do{
            exercises = try context.fetch(request)
        }catch{
            print("Error fetch\(error)")
        }
        self.exercisesTableView.reloadData()
    }
}

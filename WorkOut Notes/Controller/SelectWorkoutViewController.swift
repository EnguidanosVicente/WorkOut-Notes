//
//  SelectWorkoutViewController.swift
//  WorkOut Notes
//
//  Created by Vicente Enguidanos on 15/06/2022.
//

import UIKit
import CoreData

class SelectWorkoutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var workoutTableView: UITableView!
    
    var workout = [WorkOut]()
    var segueName:String = ""
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        workoutTableView.dataSource = self
        workoutTableView.delegate = self
        
        loadWorkout()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workout.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell = UITableViewCell.init()
        
        cell = workoutTableView.dequeueReusableCell(withIdentifier: "workoutCell", for: indexPath)
        cell.textLabel?.text = workout[indexPath.row].workOutName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        segueName = workout[indexPath.row].workOutName ?? ""
        performSegue(withIdentifier: "toExercise", sender: self)
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! SelectExerciseViewController
        
        if segue.identifier == "toExercise"{
            destinationVC.workoutName = segueName
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
}

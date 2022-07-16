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

        workoutTableView.backgroundColor = UIColor.clear
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
        request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        
        do{
            workout = try context.fetch(request)
        }catch{
            print("Error fetch\(error)")
        }
        self.workoutTableView.reloadData()
    }
}

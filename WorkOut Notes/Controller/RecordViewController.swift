//
//  RecordViewController.swift
//  WorkOut Notes
//
//  Created by Vicente Enguidanos on 15/06/2022.
//

import UIKit
import CoreData

class RecordViewController: UIViewController {
    
    
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var typeTimerControl: UISegmentedControl!
    @IBOutlet weak var Minus10sButton: UIButton!
    @IBOutlet weak var minus1mButton: UIButton!
    @IBOutlet weak var plus10sButton: UIButton!
    @IBOutlet weak var plus1mButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var recordTableView: UITableView!
    
    
    
    
    
    
    
    
    var exerciseName: String = ""
    let chrono = chronometer()
    var timer:Timer = Timer()
    var stopCount = true
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var exercise = [Exercises]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordTableView.dataSource = self
        recordTableView.delegate = self
        loadPreviousExercise()
        loadCurrentExercise()
        
    }
    
    @IBAction func clearButtonPressed(_ sender: Any)
    {
        timer.invalidate()
        chrono.count = 0
        displayLabel.text = chrono.makeTimeString(minutes: 0, seconds: 0)
        playButton.isEnabled = true
    }
    
    @IBAction func pauseButtonPressed(_ sender: Any)
    {
        timer.invalidate()
        playButton.isEnabled = true
    }
    @IBAction func platButtonPressed(_ sender: Any)
    {
        if stopCount{
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [self] t in
                chrono.count += 1
                let time = self.chrono.secondsToHoursMinutesSeconds(seconds: chrono.count)
                displayLabel.text = self.chrono.makeTimeString(minutes: time.0, seconds: time.1)
            })
        }else{
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [self] t in
                chrono.count -= 1
                let time = self.chrono.secondsToHoursMinutesSeconds(seconds: chrono.count)
                displayLabel.text = self.chrono.makeTimeString(minutes: time.0, seconds: time.1)
                if chrono.count < 1{
                    timer.invalidate()
                    playButton.isEnabled = true
                }
            })
        }
        playButton.isEnabled = false
    }
    
    @IBAction func cangeCountPressed(_ sender: UISegmentedControl) {
        
        timer.invalidate()
        chrono.count = 0
        displayLabel.text = chrono.makeTimeString(minutes: 0, seconds: 0)
        playButton.isEnabled = true
        
        if typeTimerControl.titleForSegment(at: typeTimerControl.selectedSegmentIndex)! == "Stop Count"{
            stopCount = true
        }else{
            stopCount = false
        }
        
    }
    @IBAction func plus10sPressed(_ sender: UIButton) {
        chrono.count = chrono.count + 10
        let time = chrono.secondsToHoursMinutesSeconds(seconds: chrono.count)
        displayLabel.text = chrono.makeTimeString(minutes: time.0, seconds: time.1)
    }
    @IBAction func minus10sPressed(_ sender: UIButton) {
        if chrono.count >= 10{
            chrono.count = chrono.count - 10
            let time = chrono.secondsToHoursMinutesSeconds(seconds: chrono.count)
            displayLabel.text = chrono.makeTimeString(minutes: time.0, seconds: time.1)
        }
    }
    @IBAction func plus1mPressed(_ sender: UIButton) {
        chrono.count = chrono.count + 60
        let time = chrono.secondsToHoursMinutesSeconds(seconds: chrono.count)
        displayLabel.text = chrono.makeTimeString(minutes: time.0, seconds: time.1)
    }
    @IBAction func minus1mPressed(_ sender: UIButton) {
        if chrono.count >= 60{
            chrono.count = chrono.count - 60
            let time = chrono.secondsToHoursMinutesSeconds(seconds: chrono.count)
            displayLabel.text = chrono.makeTimeString(minutes: time.0, seconds: time.1)
        }
    }
}

//MARK: delegate table view

extension RecordViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercise.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = recordTableView.dequeueReusableCell(withIdentifier: "cellRecord", for: indexPath) as! recordCellPrototype
        
        cell.numberOfsetTextField.text = String(exercise[indexPath.row].numberOfSet)
        
        return cell
    }
    
    func loadPreviousExercise(){
        
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
        //get only the last date.
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
        
        self.recordTableView.reloadData()
        
    }
    
    func loadCurrentExercise(){
        
    }
    
}

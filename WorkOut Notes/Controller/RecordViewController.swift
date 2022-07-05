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
    var prevExercise = [Exercises]()
    var currentExercise = [Exercises]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = exerciseName
        checkExercises()
        if prevExercise.count != 0{
            loadExercises()
            recordTableView.dataSource = self
            recordTableView.delegate = self
        }else{
            promptBack()
        }
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
        //add 2 header rows
    
        return prevExercise.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        if indexPath.row == 0{
            let cellHeadDate = recordTableView.dequeueReusableCell(withIdentifier: "headerDateCell", for: indexPath) as! dateCellPrototype
            cellHeadDate.dateCell.text = reverseDate(date: prevExercise[0].date ?? "")
            cellHeadDate.currentDate.text = reverseDate(date: getCurrentDate())
            return cellHeadDate
        }else if indexPath.row == 1{
            let cellHeader = recordTableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath)
            return cellHeader
        }else{
            let cell = recordTableView.dequeueReusableCell(withIdentifier: "cellRecord", for: indexPath) as! recordCellPrototype
            
            cell.numberOfsetTextField.text = String(prevExercise[indexPath.row - 2].numberOfSet)
            cell.previousRepsTextField.text = String(prevExercise[indexPath.row - 2].reps)
            cell.previousWeightTextField.text = String(prevExercise[indexPath.row - 2].weight)
            cell.currentRepsTextField.text = String(currentExercise[indexPath.row - 2].reps)
            cell.currentWeightTextField.text = String(currentExercise[indexPath.row - 2].weight)
            
            cell.currentRepsTextField.tag = indexPath.row
            cell.currentRepsTextField.delegate = self
            
            cell.currentWeightTextField.tag = indexPath.row
            cell.currentWeightTextField.delegate = self
            
            return cell
        }
    }
    
    func checkExercises(){
        
        //Find all the exercises thanks to header
        let predicateName = NSPredicate(format: "exerciseName == %@", exerciseName)
        let predicateSets = NSPredicate(format: "numberOfSet > %i", 0)
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [predicateName,predicateSets])
        let request: NSFetchRequest<Exercises> = Exercises.fetchRequest()
        
        request.predicate = predicate
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do{
            prevExercise = try context.fetch(request)
        }catch{
            print("Error fetch\(error)")
        }
    }
    func loadExercises(){
        
        let firstDate = getCurrentDate()
        var secondDate = "0000-00-00"

        for i in 0..<prevExercise.count{
            if prevExercise[i].date != firstDate
            {
                secondDate = prevExercise[i].date ?? "0000-00-00"
                break
            }
        }
        
        //get previous
        let predicateName = NSPredicate(format: "exerciseName == %@", exerciseName)
        let predicateDate = NSPredicate(format: "date == %@", secondDate as CVarArg)
        let predicateNset = NSPredicate(format: "numberOfSet > %i", 0)
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [predicateName,predicateDate,predicateNset])
        let request: NSFetchRequest<Exercises> = Exercises.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = [NSSortDescriptor(key: "numberOfSet", ascending: true)]
        
        do{
            prevExercise = try context.fetch(request)
        }catch{
            print("Error fetch\(error)")
        }
        
        //get current
        let predicateName2 = NSPredicate(format: "exerciseName == %@", exerciseName)
        let predicateDate2 = NSPredicate(format: "date == %@", firstDate as CVarArg)
        let predicateNset2 = NSPredicate(format: "numberOfSet > %i", 0)
        let predicate2 = NSCompoundPredicate(type: .and, subpredicates: [predicateName2,predicateDate2,predicateNset2])
        let request2: NSFetchRequest<Exercises> = Exercises.fetchRequest()
        request2.predicate = predicate2
        request2.sortDescriptors = [NSSortDescriptor(key: "numberOfSet", ascending: true)]
        
        do{
            currentExercise = try context.fetch(request2)
        }catch{
            print("Error fetch\(error)")
        }
        
        // if new record, set new array
        if prevExercise.count > currentExercise.count{
            currentExercise = changeArrayExerLenght(of: currentExercise, to: prevExercise.count)
            //initialize new one
            for i in 0..<currentExercise.count{
                currentExercise[i].date = getCurrentDate()
                currentExercise[i].numberOfSet = Int16(i + 1)
                currentExercise[i].sets = prevExercise[0].sets
                currentExercise[i].exerciseName = exerciseName
            }
        }
        if prevExercise.count < currentExercise.count{
            prevExercise = changeArrayExerLenght(of: prevExercise, to: currentExercise.count)
            
            for i in 0..<prevExercise.count{
                prevExercise[i].date = prevExercise[0].date
                prevExercise[i].numberOfSet = Int16(i + 1)
                prevExercise[i].sets = prevExercise[0].sets
                prevExercise[i].exerciseName = exerciseName
            }
        }
        //initialize new one

        
    }
    
    func saveData(){
        
        do {
            try context.save()
        } catch {
            
            print("Error saving records\(error)")
            
        }
    }
    func promptBack(){
       if prevExercise.count == 0{
            let alert = UIAlertController(title: "Hey!", message: "Please, configure workout first.", preferredStyle: .alert)

            
            let actionOk = UIAlertAction(title: "Ok", style: .default) { action in
                print("success")
                
                self.navigationController?.popViewController(animated: true)
            }
            alert.addAction(actionOk)
            present(alert, animated: true, completion: nil)
           
       }
    }

}

// MARK: extension 2

extension RecordViewController: UITextFieldDelegate{
    
    //delegate method texfield, trigger when finish typing

    func textFieldDidEndEditing(_ textField: UITextField) {
        
        let row = textField.tag
   
        //check which textfield is selected
        if ((recordTableView.cellForRow(at: IndexPath(row: row, section: 0)) as! recordCellPrototype).currentRepsTextField.self == textField.self){
            if isStringAnInt(string: textField.text ?? " "){
                currentExercise[row - 2].reps = Int16(textField.text!)!
                saveData()
            }
        }else{
            if isStringAnInt(string: textField.text ?? " "){
                currentExercise[row - 2].weight = Float(textField.text!)!
                saveData()
            }
        }
    }
    
    
}


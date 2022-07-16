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
    @IBOutlet weak var previousDate: UILabel!
    @IBOutlet weak var currentDate: UILabel!
    
    var exerciseName: String = ""
    let chrono = chronometer()
    var timer:Timer = Timer()
    var stopCount = true
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var prevExercise = [Exercises]()
    var currentExercise = [Exercises]()
    var startTime: Double = 0
    var stopTime: Double = 0
    var lastCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = exerciseName
        checkExercises()
        if prevExercise.count != 0{
            loadExercises()
            setDates()
            recordTableView.dataSource = self
            recordTableView.delegate = self
        }else{
            promptBack()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        var isempty: Bool = true
        
        if self.isMovingFromParent {
            for i in 0..<currentExercise.count{
                if currentExercise[i].reps != 0 || currentExercise[i].weight != 0{
                    isempty = false
                }
            }
            if isempty{
                for i in 0..<currentExercise.count{
                    context.delete(currentExercise[i])
                }
            }
        }
    }
    
    @IBAction func clearButtonPressed(_ sender: Any)
    {
        timer.invalidate()
        stopTime = 0
        lastCount = 0
        chrono.count = 0
        displayLabel.text = chrono.makeTimeString(hours: 0, minutes: 0, seconds: 0)
        playButton.isEnabled = true
    }
    
    @IBAction func pauseButtonPressed(_ sender: Any)
    {
        lastCount = chrono.count
        timer.invalidate()
        playButton.isEnabled = true
    }
    @IBAction func platButtonPressed(_ sender: Any)
    {
        startTime = NSDate.timeIntervalSinceReferenceDate
        
        print (lastCount)
        if stopCount{
            timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { [self] t in
                stopTime = (NSDate.timeIntervalSinceReferenceDate - startTime)  * 100
                chrono.count = Int(stopTime) + lastCount

                let time = self.chrono.secondsToHoursMinutesSeconds(time: chrono.count)
                displayLabel.text = self.chrono.makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
            })
        }else{
            timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { [self] t in
                stopTime = (NSDate.timeIntervalSinceReferenceDate - startTime) * 100
                chrono.count = lastCount - Int(stopTime)
                
                let time = self.chrono.secondsToHoursMinutesSeconds(time: chrono.count)
                displayLabel.text = self.chrono.makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
                if chrono.count < 1{
                    timer.invalidate()
                    stopTime = 0
                    lastCount = 0
                    chrono.count = 0
                    playButton.isEnabled = true
                }
            })
        }
        playButton.isEnabled = false
    }
    
    @IBAction func cangeCountPressed(_ sender: UISegmentedControl) {
        
        timer.invalidate()
        stopTime = 0
        lastCount = 0
        chrono.count = 0
        displayLabel.text = chrono.makeTimeString(hours: 0, minutes: 0, seconds: 0)
        playButton.isEnabled = true
        
        if typeTimerControl.titleForSegment(at: typeTimerControl.selectedSegmentIndex)! == "Stop Count"{
            stopCount = true
        }else{
            stopCount = false
        }
        
    }
    @IBAction func plus10sPressed(_ sender: UIButton) {
        lastCount = lastCount + 1000
        let time = chrono.secondsToHoursMinutesSeconds(time: lastCount)
        displayLabel.text = chrono.makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
    }
    @IBAction func minus10sPressed(_ sender: UIButton) {
        if lastCount >= 1000{
            lastCount = lastCount - 1000
            let time = chrono.secondsToHoursMinutesSeconds(time: lastCount)
            displayLabel.text = chrono.makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
        }
    }
    @IBAction func plus1mPressed(_ sender: UIButton) {
        lastCount = lastCount + 6000
        let time = chrono.secondsToHoursMinutesSeconds(time: lastCount)
        displayLabel.text = chrono.makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
    }
    @IBAction func minus1mPressed(_ sender: UIButton) {
        if lastCount >= 6000{
            lastCount = lastCount - 6000
            let time = chrono.secondsToHoursMinutesSeconds(time: lastCount)
            displayLabel.text = chrono.makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
        }
    }
}



//MARK: delegate table view

extension RecordViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //add 2 header rows
        
        return prevExercise.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = recordTableView.dequeueReusableCell(withIdentifier: "cellRecord", for: indexPath) as! recordCellPrototype
        
        cell.numberOfsetTextField.text = String(prevExercise[indexPath.row].numberOfSet)
        cell.previousRepsTextField.text = String(prevExercise[indexPath.row].reps)
        cell.previousWeightTextField.text = String(prevExercise[indexPath.row].weight)
        cell.currentRepsTextField.text = String(currentExercise[indexPath.row].reps)
        cell.currentWeightTextField.text = String(currentExercise[indexPath.row].weight)
        
        cell.currentRepsTextField.textColor = checkColorText(prev: prevExercise[indexPath.row].reps, curr: currentExercise[indexPath.row].reps)
        cell.currentWeightTextField.textColor = checkColorText(prev: prevExercise[indexPath.row].weight, curr: currentExercise[indexPath.row].weight)
        
        if let prevMessage = prevExercise[indexPath.row].comment{
            if prevMessage > ""{
                cell.previousCommentButton.isEnabled = true
                cell.previousCommentButton.tag = indexPath.row
                cell.previousCommentButton.addTarget(self, action: #selector(prevButtonWasTapped(sender:)), for: .touchUpInside)
            }else{
                cell.previousCommentButton.isEnabled = false
            }
        }else{
            cell.previousCommentButton.isEnabled = false
        }
        
        cell.currentCommentButton.tag = indexPath.row
        cell.currentCommentButton.addTarget(self, action: #selector(currentButtonWasTapped(sender:)), for: .touchUpInside)
        
        cell.currentRepsTextField.tag = indexPath.row
        cell.currentRepsTextField.delegate = self
        
        cell.currentWeightTextField.tag = indexPath.row
        cell.currentWeightTextField.delegate = self
        
        return cell
        
    }
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {

            return nil
        }
    
    @objc func prevButtonWasTapped(sender: UIButton){
        
        let alert = UIAlertController(title: prevExercise[sender.tag].comment, message: "", preferredStyle: .alert)
        
        let actionOk = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(actionOk)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func currentButtonWasTapped(sender: UIButton){
        
        var newText = UITextField()
        
        let alert = UIAlertController(title: "Add comment", message: "", preferredStyle: .alert)
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "example: Add more weight"
            alertTextField.text = self.currentExercise[sender.tag].comment ?? ""
            newText = alertTextField
        }
        
        
        let actionSave = UIAlertAction(title: "Save", style: .default) { action in
            self.currentExercise[sender.tag].comment = newText.text
            self.saveData()
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(actionSave)
        alert.addAction(actionCancel)
        present(alert, animated: true, completion: nil)
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
    func setDates(){
        previousDate.text = reverseDate(date: prevExercise[0].date ?? "")
        currentDate.text = reverseDate(date: getCurrentDate())
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
                currentExercise[row].reps = Int16(textField.text!)!
                textField.textColor = checkColorText(prev: prevExercise[row].reps, curr: currentExercise[row].reps)
                saveData()
            }
        }else{
            if isStringAnFloat(string: textField.text ?? " "){
                currentExercise[row].weight = Float(textField.text!)!
                textField.textColor = checkColorText(prev: prevExercise[row].weight, curr: currentExercise[row].weight)
                saveData()
            }
        }
        
    }
}

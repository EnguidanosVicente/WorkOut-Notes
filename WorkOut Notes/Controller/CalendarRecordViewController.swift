//
//  CalendarRecordViewController.swift
//  WorkOut Notes
//
//  Created by Vicente Enguidanos on 05/07/2022.
//

import UIKit
import CoreData

class CalendarRecordViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var dayRecordTableView: UITableView!
    @IBOutlet weak var dateRecordLabel: UILabel!
    var dateRecord: String = ""
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var exercises = [Exercises]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dayRecordTableView.dataSource = self
        dayRecordTableView.delegate = self
        
        dateRecordLabel.text = reverseDate(date: dateRecord)
        
        loadRecords()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return getSections().count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getSections()[section].datasection.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dayRecordTableView.dequeueReusableCell(withIdentifier: "cellCalendarRecord", for: indexPath)
        
        let set = String(getSections()[indexPath.section].datasection[indexPath.row].set)
        let reps = String(getSections()[indexPath.section].datasection[indexPath.row].reps)
        let weight = String(getSections()[indexPath.section].datasection[indexPath.row].weight)
        cell.textLabel?.text = "Set: \(set)    Reps: \(reps)    Weight: \(weight)"
        
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return getSections()[section].sectionName
    }

    func loadRecords(){
        
        let predicateDate = NSPredicate(format: "date == %@", dateRecord as CVarArg)
        let predicateNset = NSPredicate(format: "numberOfSet > %i", 0)
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [predicateDate,predicateNset])
        let request: NSFetchRequest<Exercises> = Exercises.fetchRequest()
        request.predicate = predicate
        let nameSortDescriptor = NSSortDescriptor(key: "exerciseName", ascending: true)
        let setSortDescriptor = NSSortDescriptor(key: "numberOfSet", ascending: true)
        request.sortDescriptors = [nameSortDescriptor, setSortDescriptor]
        
        do{
            exercises = try context.fetch(request)
        }catch{
            print("Error fetch\(error)")
        }
    }
    
    struct SectionInfo{
        var sectionName: String
        var datasection: [DataSection]
    }
    struct DataSection{
        var set: Int16
        var reps: Int16
        var weight: Float
    }
    
    func getSections() -> [SectionInfo]{
        var sections: Int = 1
        var i = 1

        
        var sectionInfo = [SectionInfo]()
        var datasection = [DataSection]()
        
        datasection.append(DataSection(set: exercises[0].numberOfSet, reps: exercises[0].reps, weight: exercises[0].weight))

        
        repeat{
            if exercises[i - 1].exerciseName != exercises[i].exerciseName{
                sectionInfo.append(SectionInfo(sectionName: exercises[i - 1].exerciseName ?? "", datasection: datasection))
                datasection.removeAll()
                sections += 1
            }
            datasection.append(DataSection(set: exercises[i].numberOfSet, reps: exercises[i].reps, weight: exercises[i].weight))
            i += 1
            
        }while exercises.count > 0 && i < exercises.count
        
        print (sections)
        print (sectionInfo)
        return sectionInfo
    }
}

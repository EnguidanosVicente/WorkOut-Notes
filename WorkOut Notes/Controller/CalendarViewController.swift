//
//  CalendarViewController.swift
//  WorkOut Notes
//
//  Created by Vicente Enguidanos on 30/06/2022.
//

import UIKit
import CoreData

class CalendarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{

    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var selectedDate = Date()
    var totalSquares = [String]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var exercises = [Exercises]()
    var distinctValues: [String] = []
    var dateCompare: String = ""
    var datePass: String = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        setMonthView()
        distinctValues = loadDates()
    }
    
    
    func setMonthView()
    {
        totalSquares.removeAll()
        
        let daysInMonth = CalendarHelper().daysInMonth(date: selectedDate)
        let firstDayOfMonth = CalendarHelper().firstOfMonth(date: selectedDate)
        let startingSpaces = CalendarHelper().weekDay(date: firstDayOfMonth)
        
        var count: Int = 1
        
        while(count <= 42)
        {
            if(count <= startingSpaces || count - startingSpaces > daysInMonth)
            {
                totalSquares.append("")
            }
            else
            {
                totalSquares.append(String(count - startingSpaces))
            }
            count += 1
        }
        
        monthLabel.text = CalendarHelper().monthString(date: selectedDate)
            + " " + CalendarHelper().yearString(date: selectedDate)
        dateCompare = CalendarHelper().dateToCompare(date: selectedDate)
        collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalSquares.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calCell", for: indexPath) as! CalendarCell
        
        cell.dayOfMonth.text = totalSquares[indexPath.row]
        
        let dayInt = Int(totalSquares[indexPath.row])
        let dayString = String(format: "%02d", dayInt ?? 0)
        
        for i in 0..<distinctValues.count{
                if (dateCompare + "-" + dayString) == distinctValues[i]{
                    print("encontrado en \(totalSquares[indexPath.row])")
                    cell.backgroundColor = UIColor(red: 0.573, green: 0.729, blue: 0.573, alpha: 1)
                    cell.layer.cornerRadius = 12.0
                    cell.layer.borderWidth = 0.5
                    cell.calendarImage.isHidden = false
                    return cell
                }else{
                    cell.backgroundColor = .none
                    cell.layer.cornerRadius = 0
                    cell.layer.borderWidth = 0
                    cell.calendarImage.isHidden = true
                   
                }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let dayInt = Int(totalSquares[indexPath.row])
        let dayString = String(format: "%02d", dayInt ?? 0)
        
        for i in 0..<distinctValues.count{
            if (dateCompare + "-" + dayString) == distinctValues[i]{
                datePass = distinctValues[i]
                performSegue(withIdentifier: "toExerResume", sender: self)
            }
        }
        
        
    }

override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let destinationVC = segue.destination as! CalendarRecordViewController
    
    if segue.identifier == "toExerResume"{
        destinationVC.dateRecord = datePass
    }
}
    
    // set 7 columns
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(7 - 1))
        let size1 = Int((collectionView.bounds.width - totalSpace) / CGFloat(7))
        let size = (collectionView.bounds.width - totalSpace) / CGFloat(7)
        return CGSize(width: CGFloat(size1), height: size * 1.2)
    }
    
    @IBAction func previousMonth(_ sender: Any)
    {
        selectedDate = CalendarHelper().minusMonth(date: selectedDate)
        setMonthView()
    }
    

    @IBAction func nextMonth(_ sender: Any)
    {
        selectedDate = CalendarHelper().plusMonth(date: selectedDate)
        setMonthView()
    }
    
    override open var shouldAutorotate: Bool
    {
        return false
    }
    
    func loadDates() -> [String]{
        
        let column = "date"

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Exercises")
        request.resultType = .dictionaryResultType
        request.returnsDistinctResults = true
        request.propertiesToFetch = [column]
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]

        if let res = try? context.fetch(request) as? [[String: String]] {
          //  print("res: \(res)")

            //Extract the distinct values
            let distinctValues = res.compactMap { $0[column] }
            print (distinctValues)
            return distinctValues
        }
        return [""]
    }

}

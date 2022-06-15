//
//  MainScreedViewController.swift
//  WorkOut Notes
//
//  Created by Vicente Enguidanos on 15/06/2022.
//

import UIKit

class MainScreenViewController: UIViewController {

    @IBOutlet weak var buildPlanButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func buildPlanPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: "toWorkoutPlan", sender: self)
        
    }
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "toWorkoutList", sender: self)
    
    }

    
}

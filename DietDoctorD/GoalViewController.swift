//
//  GoalViewController.swift
//  DietDoctorC
//
//  Created by MURRO, JOHN REXES  on 05/12/2018.
//  Copyright © 2018 MURRO, JOHN REXES . All rights reserved.
//

import UIKit
import CoreData

class GoalViewController: UIViewController {
    
    @IBOutlet weak var myWeightGoal: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "User", in: context)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        var currentWeight: String!
        var startDatetime: String!
        
        do{
            let result = try context.fetch(request)
            let firstItem: User = result.first as! User
            currentWeight = firstItem.currentWeight!
            startDatetime = firstItem.startDatetime!
            
            try context.delete(firstItem)
            let newGoal = NSManagedObject(entity: entity!, insertInto: context)
            newGoal.setValue(myWeightGoal.text, forKey: "weightGoal")
            newGoal.setValue(currentWeight, forKey: "currentWeight")
            newGoal.setValue(startDatetime, forKey: "startDatetime")
            if(Double(currentWeight)!>=Double(myWeightGoal.text!)!){
                newGoal.setValue("loss", forKey: "gainOrLoss")
            }else{
                newGoal.setValue("gain", forKey: "gainOrLoss")
            }
            request.returnsObjectsAsFaults = false
            try context.save()
        }catch{
            print("Failed")
        }
    }
    
}


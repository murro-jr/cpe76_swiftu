//
//  SleepViewController.swift
//  DietDoctorC
//
//  Created by June Hermoso on 07/12/2018.
//  Copyright © 2018 MURRO, JOHN REXES . All rights reserved.
//

import UIKit
import CoreData

class SleepViewController: UIViewController {
    
    @IBOutlet weak var sleepHours: UITextField!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var context: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        context = appDelegate.persistentContainer.viewContext
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getSizeOfActivities() -> NSInteger{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName:"Activity")
        var size: NSInteger!
        do{
            let result = try context?.fetch(request)
            size = result?.count
        }catch{
            size = 0
        }
        return size
    }
    
    func getSizeOfSleepActivities() -> NSInteger{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Rest")
        var size: NSInteger!
        do{
            let result = try context?.fetch(request)
            size = result?.count
        }catch{
            size = 0
        }
        return size
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let activity = NSEntityDescription.entity(forEntityName: "Activity", in: context)
        let sleep =  NSEntityDescription.entity(forEntityName: "Rest", in: context)
        let newActivity = NSManagedObject(entity: activity!,insertInto: context)
        let newSleep = NSManagedObject(entity: sleep!, insertInto: context)
        newSleep.setValue(NSString.localizedStringWithFormat("%d", self.getSizeOfActivities()), forKey: "activityID")
        newSleep.setValue(sleepHours.text, forKey: "sleepHours")
        
        newActivity.setValue(NSString.localizedStringWithFormat("%d", self.getSizeOfActivities()), forKey: "activityID")
        newActivity.setValue("Rest", forKey: "activityType")
        
        do{
            try context.save()
        }catch{
            print("Failed")
        }
        
    }
    
}


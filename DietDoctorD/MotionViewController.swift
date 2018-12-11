//
//  MotionViewController.swift
//  DietDoctorC
//
//  Created by June Hermoso on 08/12/2018.
//  Copyright © 2018 MURRO, JOHN REXES . All rights reserved.
//

import UIKit
import CoreData

class MotionViewController: UIViewController {
    
    @IBOutlet weak var motionType: UISegmentedControl!
    @IBOutlet weak var kilometer: UITextField!
    @IBOutlet weak var minute: UITextField!
    
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
    
    @IBAction func kilometerSelected(_ sender: Any) {
        var minutesResult: Double
        if(kilometer.text!.count > 0){
            switch motionType.selectedSegmentIndex{
            case 0:
                minutesResult = Double(kilometer.text!)!/0.060
                minute.text = NSString.localizedStringWithFormat("%.2f",minutesResult) as! String
                break
            case 1:
                minutesResult = Double(kilometer.text!)!*60/9
                minute.text = NSString.localizedStringWithFormat("%.2f",minutesResult) as! String
            default: break
            }
        }else{
            minute.text = "0"
            kilometer.text = "0"
        }
    }
    
    @IBAction func minuteSelected(_ sender: Any) {
        var kmResult: Double
        
        if(minute.text!.count > 0){
            switch motionType.selectedSegmentIndex{
            case 0:
                kmResult = Double(minute.text!)!*0.060
                kilometer.text = NSString.localizedStringWithFormat("%.2f",kmResult) as! String
                break
            case 1:
                kmResult = Double(minute.text!)!*9/60
                kilometer.text = NSString.localizedStringWithFormat("%.2f",kmResult) as! String
            default: break
            }
        }else{
            minute.text = "0"
            kilometer.text = "0"
        }
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let activity = NSEntityDescription.entity(forEntityName: "Activity", in: context)
        let motion = NSEntityDescription.entity(forEntityName: "Locomotion", in: context)
        
        let newActivity = NSManagedObject(entity: activity!,insertInto: context)
        let newMotion = NSManagedObject(entity: motion!, insertInto: context)
        
        var motionText: String!
        var minutesResult: Double!
        var kmResult: Double!
        
        switch motionType.selectedSegmentIndex {
        case 0:
            motionText = "Walk"
            break
        case 1:
            motionText = "Run"
        default:
            break
        }
        
        if(minute.text!.count <= 0 && kilometer.text!.count > 0){
            minutesResult = Double(kilometer.text!)!*60/9
            minute.text = NSString.localizedStringWithFormat("%.2f",minutesResult) as! String
        }else if(kilometer.text!.count <= 0 && minute.text!.count > 0){
            kmResult = Double(minute.text!)!*9/60
            kilometer.text = NSString.localizedStringWithFormat("%.2f",kmResult) as! String
        }else if(kilometer.text!.count <= 0 && minute.text!.count <= 0){
            kilometer.text = ""
            minute.text = ""
        }
        
        newMotion.setValue(motionText, forKey: "motionType")
        newMotion.setValue(NSString.localizedStringWithFormat("%d", self.getSizeOfActivities()), forKey: "activityID")
        newMotion.setValue(kilometer.text, forKey: "kilometer")
        newMotion.setValue(minute.text, forKey: "minute")
        
        newActivity.setValue(NSString.localizedStringWithFormat("%d", self.getSizeOfActivities()), forKey: "activityID")
        newActivity.setValue("Locomotion", forKey: "activityType")
        
        do{
            try context.save()
        }catch{
            print("Failed")
        }
    }
    
}


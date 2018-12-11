//
//  MealViewController.swift
//  DietDoctorC
//
//  Created by June Hermoso on 08/12/2018.
//  Copyright © 2018 MURRO, JOHN REXES . All rights reserved.
//

import UIKit
import CoreData

class MealViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var foodName: UITextField!
    @IBOutlet weak var calories: UITextField!
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var context: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        context = appDelegate.persistentContainer.viewContext
        // Do any additional setup after loading the view.
        var currentMealType: NSInteger = self.checkCurrentMealType()
        switch currentMealType {
        case 0:
            segmentedControl.selectedSegmentIndex = 1
            segmentedControl.setEnabled(false, forSegmentAt: 0)
            segmentedControl.setEnabled(false, forSegmentAt: 2)
            break
        case 1:
            segmentedControl.selectedSegmentIndex = 2
            segmentedControl.setEnabled(false, forSegmentAt: 0)
            segmentedControl.setEnabled(false, forSegmentAt: 1)
            break
        case 2:
            segmentedControl.selectedSegmentIndex = 0
            segmentedControl.setEnabled(false, forSegmentAt: 1)
            segmentedControl.setEnabled(false, forSegmentAt: 2)
            break
        default:
            segmentedControl.selectedSegmentIndex = 0
            segmentedControl.setEnabled(false, forSegmentAt: 1)
            segmentedControl.setEnabled(false, forSegmentAt: 2)
            break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkCurrentMealType() -> NSInteger{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName:"Meal")
        var mealType: NSInteger
        
        do{
            var result = try context.fetch(request)
            if(result.count > 0){
                let meal: Meal = result.popLast() as! Meal
                mealType = NSInteger(meal.mealTypeIndex!)!
            }else{ mealType = -1 }
            
        }catch{
            mealType = -1
        }
        return mealType
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
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let activity = NSEntityDescription.entity(forEntityName: "Activity", in: context)
        let meal = NSEntityDescription.entity(forEntityName: "Meal", in: context)
        
        let newActivity = NSManagedObject(entity: activity!,insertInto: context)
        let newMeal = NSManagedObject(entity: meal!, insertInto: context)
        
        newMeal.setValue(NSString.localizedStringWithFormat("%d", self.getSizeOfActivities()), forKey: "activityID")
        newMeal.setValue(foodName.text, forKey: "nameOfMeal")
        newMeal.setValue(calories.text, forKey: "calories")
        
        newActivity.setValue(NSString.localizedStringWithFormat("%d", self.getSizeOfActivities()), forKey: "activityID")
        newActivity.setValue("Meal", forKey: "activityType")
        
        var mealType: String!
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            mealType = "Breakfast"
            break
        case 1:
            mealType = "Lunch"
            break
        case 2:
            mealType = "Dinner"
            break
        default: break
        }
        
        newMeal.setValue(NSString.localizedStringWithFormat("%d", segmentedControl.selectedSegmentIndex), forKey: "mealTypeIndex")
        newMeal.setValue(mealType, forKey: "mealType")
        
        do{
            try context.save()
        }catch{
            print("Failed")
        }
        
    }
    
}


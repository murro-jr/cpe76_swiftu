//
//  ViewController.swift
//  DietDoctorD
//
//  Created by June Hermoso on 09/12/2018.
//  Copyright © 2018 JH Company. All rights reserved.
//

import UIKit
import CoreData


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var myWeightGoal: UILabel!
    @IBOutlet weak var myCurrentWeight: UILabel!
    @IBOutlet weak var distanceTravelled: UILabel!
    @IBOutlet weak var myCalories: UILabel!
    @IBOutlet weak var predictLabel: UILabel!
    
    let cellReuseIdentifier = "cell"
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var context: NSManagedObjectContext!
    var myNewView: UIView = UIView(frame: CGRect(x:0,y:40,width:UIScreen.main.bounds.width,height:UIScreen.main.bounds.height))
    var weightGoalField: UITextField = UITextField(frame: CGRect(x:UIScreen.main.bounds.width/2-40,y:220,width:200,height:40))
    var currentWeightField: UITextField = UITextField(frame: CGRect(x:UIScreen.main.bounds.width/2-40,y:140,width:200,height:40))
    var gainOrLossValue: String!
    var currentWeight: Double!
    var weightGoalValue: Double!
    var dateToday: Date!
    var dateFormatter: DateFormatter!
    var currentDatetime: String!
    var dailyDietUpdate: UIAlertController = UIAlertController()
    var countForDismiss: Int = 0
    var dailyUpdateIsPresented: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var firstItem: User!
        var request: NSFetchRequest<NSFetchRequestResult>
        context = appDelegate.persistentContainer.viewContext
//        self.resetCoreData()
        
        myNewView.backgroundColor = UIColor.white
        
        let headerView = UIView(frame: CGRect(x:0,y:20,width:UIScreen.main.bounds.width,height:60))
        
        let headerText = UILabel(frame: CGRect(x:0,y:0,width:UIScreen.main.bounds.width,height:60))
        headerText.text = "DECIDE YOUR NEW GOAL"
        headerText.textAlignment = NSTextAlignment.center
        headerText.backgroundColor = UIColor.cyan
        
        headerView.addSubview(headerText)
        
        let currentWeightLabel = UILabel(frame: CGRect(x:30,y:140,width:120,height:40))
        currentWeightLabel.text = "Current Weight: "
        currentWeightLabel.font = UIFont.systemFont(ofSize: 15)
        
        let weightGoalLabel = UILabel(frame: CGRect(x:30,y:220,width:120,height:40))
        weightGoalLabel.text = "Weight Goal: "
        weightGoalLabel.font = UIFont.systemFont(ofSize: 15)
        
        currentWeightField.placeholder = "in kilograms"
        currentWeightField.font = UIFont.systemFont(ofSize: 15)
        currentWeightField.borderStyle = UITextBorderStyle.roundedRect
        
        weightGoalField.placeholder = "in kilograms"
        weightGoalField.font = UIFont.systemFont(ofSize: 15)
        weightGoalField.borderStyle = UITextBorderStyle.roundedRect
        
        let formSubmitButton = UIButton(frame: CGRect(x:UIScreen.main.bounds.width/2-40,y:300,width:100,height:40))
        formSubmitButton.layer.cornerRadius = 5
        formSubmitButton.backgroundColor = UIColor.lightGray
        formSubmitButton.setTitle("Submit", for: .normal)
        formSubmitButton.addTarget(self, action: #selector(submitForm), for: .touchUpInside)
        
        myNewView.addSubview(headerView)
        myNewView.addSubview(currentWeightField)
        myNewView.addSubview(weightGoalField)
        myNewView.addSubview(currentWeightLabel)
        myNewView.addSubview(weightGoalLabel)
        myNewView.addSubview(formSubmitButton)
        myNewView.tag = 100
        
        request = NSFetchRequest<NSFetchRequestResult>(entityName:"User")
        request.returnsObjectsAsFaults = false
        
        do{
            var result = try context.fetch(request)
            if(result.count<=0){
                let alert = UIAlertController(title: "WELCOME", message: "This is Diet Doctor. Your personal health watch and diet planner.",preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: {_ in
                    self.view.addSubview(self.myNewView)
                }))
                self.present(alert,animated:true,completion:nil)
            }else{
                dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .short
                dateToday = Date()
                
                firstItem = result.popLast() as! User
                
                self.currentWeight = Double(firstItem.currentWeight!)!
                self.weightGoalValue = Double(firstItem.weightGoal!)!
                self.gainOrLossValue = firstItem.gainOrLoss!
                
                myWeightGoal.text = NSString.localizedStringWithFormat("%.2f", self.weightGoalValue) as! String + " kg"
                myCurrentWeight.text = NSString.localizedStringWithFormat("%.2f", self.currentWeight) as! String + " kg"
                distanceTravelled.text = NSString.localizedStringWithFormat("%.2f", self.getTotalDistanceTravelled()) as! String + " km"
                
                let calories: Double = self.caloriesFromMeal() - self.caloriesFromSleep() - self.caloriesFromLocomotion()
                
                myCalories.text = NSString.localizedStringWithFormat("%.2f", calories) as! String + " cal"
                
                if(calories >= 0){
                    predictLabel.text = "You will gain " + String.localizedStringWithFormat("%.2f", calories/1100) + " kg."
                }else{
                    predictLabel.text = "You will lose " + String.localizedStringWithFormat("%.2f", -calories/1100) + " kg."
                }
                
                currentDatetime = firstItem.startDatetime as! String
                
//                if(dateToday.timeIntervalSince(dateFormatter.date(from: currentDatetime)!)>86400){
//                    self.updateUserData()
//                }
                let timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(updateDailyTime), userInfo: nil, repeats: true)
                
            }
        }catch{
            print("Failed")
        }
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc
    func updateDailyTime(){
        let currentDate: Date = dateFormatter.date(from: currentDatetime)!
        
        let now = currentDate.timeIntervalSinceNow
        if(abs(now) > 86400){
            self.updateUserData()
            currentDatetime = dateFormatter.string(from: dateToday)
            dailyUpdateIsPresented = false
        }
        print(now)
    }
    
    func updateUserData(){
        //Initializing entity and request
        let entity = NSEntityDescription.entity(forEntityName: "User", in: context)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        
        //Initializing message and newWeightGoal
        var message: String!
        var newWeightGoal: String!
        var choice: String!
        
        do{
            let result = try context.fetch(request)
            let firstItem: User = result.first as! User
            
            //DateFormatting
            dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            dateToday = Date()
            
            let calories: Double = self.caloriesFromMeal() - self.caloriesFromSleep() - self.caloriesFromLocomotion()
            let weightGain: Double = calories/1100
            
            let myCurrentWeight: Double = self.currentWeight + weightGain

            newWeightGoal = String(self.weightGoalValue)
            choice = self.gainOrLossValue
            
            context.delete(firstItem)
            
            let newUser = NSManagedObject(entity: entity!, insertInto: context)
            
            newUser.setValue(NSString.localizedStringWithFormat("%.2f", myCurrentWeight) as! String, forKey: "currentWeight")
            newUser.setValue(newWeightGoal, forKey: "weightGoal")
            newUser.setValue(dateFormatter.string(from: dateToday), forKey: "startDatetime")
            newUser.setValue(choice, forKey: "gainOrLoss")
            try context.save()
            
            if(choice.compare("gain").rawValue == 0 && myCurrentWeight >= Double(newWeightGoal)!){
                message = "You've achieved your goal of " + newWeightGoal + " kg and gain " + String.localizedStringWithFormat("%.3f", weightGain) + " kg"
            }else if(choice.compare("loss").rawValue == 0 && myCurrentWeight <= Double(newWeightGoal)!){
                message = "You've achieved your goal of " + newWeightGoal + " kg and lost " + String.localizedStringWithFormat("%.3f", weightGain) + " kg"
            }else if(weightGain >= 0){
                message = "You've gained " + String.localizedStringWithFormat("%.3f", weightGain) + " kg"
            }else{
                message = "You've lost " + String.localizedStringWithFormat("%.3f", abs(weightGain)) + " kg"
            }
            
            self.resetActivities()
            dailyDietUpdate = UIAlertController(title: "Daily Diet Update", message: message,preferredStyle: UIAlertControllerStyle.alert)
            if(myCurrentWeight >= Double(newWeightGoal)! && choice.compare("gain").rawValue == 0 || myCurrentWeight <= Double(newWeightGoal)! && choice.compare("loss").rawValue == 0){
                dailyDietUpdate.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler:{_ in
                    self.currentWeightField.text = String(myCurrentWeight)
                    self.currentWeightField.isEnabled = false
                    self.view.addSubview(self.myNewView)
                }))
            }else{
                dailyDietUpdate.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler:{_ in
                    self.tableView.reloadData()
                    self.viewDidLoad()
                }))
            }
            self.present(dailyDietUpdate,animated:true,completion:nil)
            dailyUpdateIsPresented = true
            
        }catch{
            print("Failed")
        }
    }
    
    func caloriesFromMeal() -> Double{
        var sum: Double = 0
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Meal")
        request.returnsObjectsAsFaults = false
        do{
            let result = try context.fetch(request)
            for item: NSManagedObject in result as! [NSManagedObject] {
                sum += Double(item.value(forKey: "calories") as! String)!
            }
        }catch{
            sum = 0
        }
        return sum
    }
    
    func caloriesFromSleep() -> Double{
        var sum: Double = 0
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Rest")
        request.returnsObjectsAsFaults = false
        do{
            let result = try context.fetch(request)
            for item: NSManagedObject in result as! [NSManagedObject] {
                sum += Double(item.value(forKey: "sleepHours") as! String)!
            }
        }catch{
            sum = 0
        }
        sum = sum*currentWeight*2.2*0.42
        return sum
    }
    
    func caloriesFromLocomotion() -> Double{
        var sum: Double = 0
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Locomotion")
        request.returnsObjectsAsFaults = false
        do{
            let result = try context.fetch(request)
            for item: NSManagedObject in result as! [NSManagedObject] {
                if("Walk".compare(item.value(forKey: "motionType") as! String).rawValue == 0){
                    sum += currentWeight*2.2*5/3*Double(item.value(forKey: "minute") as! String)!/60
                }else{
                    sum += currentWeight*2.2*700*Double(item.value(forKey: "minute") as! String)!/(60*150)
                }
            }
        }catch{
            sum = 0
        }
        return sum
    }
    
    func getTotalDistanceTravelled() -> Double{
        var sum: Double = 0
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Locomotion")
        request.returnsObjectsAsFaults = false
        do{
            let result = try context.fetch(request)
            for item: NSManagedObject in result as! [NSManagedObject] {
                sum += Double(item.value(forKey: "kilometer") as! String)!
            }
        }catch{
            sum = 0
        }
        return sum
    }
    
    @objc
    func submitForm(){
        var firstItem:User?
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        let dateToday = Date()
        
        let user = NSEntityDescription.entity(forEntityName: "User", in: context)
        let newUser = NSManagedObject(entity: user!,insertInto:context)
        newUser.setValue(currentWeightField.text!, forKey: "currentWeight")
        newUser.setValue(weightGoalField.text!, forKey: "weightGoal")
        newUser.setValue(dateFormatter.string(from: dateToday), forKey: "startDatetime")
        
        if(Double(currentWeightField.text!)!>=Double(weightGoalField.text!)!){
            newUser.setValue("loss", forKey: "gainOrLoss")
            print("loss")
        }else{
            newUser.setValue("gain", forKey: "gainOrLoss")
            print("gain")
        }
        
        do{
            try context.save()
        }catch{
            print("Failed")
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName:"User")
        request.returnsObjectsAsFaults = false
        do{
            myWeightGoal.text = NSString.localizedStringWithFormat("%.2f", Double(weightGoalField.text!)!) as! String + " kg"
            myCurrentWeight.text = NSString.localizedStringWithFormat("%.2f", Double(currentWeightField.text!)!) as! String + " kg"
            distanceTravelled.text = "0.00 km"
            myCalories.text = "0.00 cal"
        }catch{
            print("Failed")
        }
        myNewView.removeFromSuperview()
    }
    
    func resetActivities(){
        var fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Activity")
        var requestf = NSBatchDeleteRequest(fetchRequest: fetch)
        do{
            try context.execute(requestf)
        }catch{
            print("Failed")
        }
        
        fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Meal")
        requestf = NSBatchDeleteRequest(fetchRequest: fetch)
        do{
            try context.execute(requestf)
        }catch{
            print("Failed")
        }
        
        fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Rest")
        requestf = NSBatchDeleteRequest(fetchRequest: fetch)
        do{
            try context.execute(requestf)
        }catch{
            print("Failed")
        }
        
        fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Locomotion")
        requestf = NSBatchDeleteRequest(fetchRequest: fetch)
        do{
            try context.execute(requestf)
        }catch{
            print("Failed")
        }
        
    }
    
    func resetCoreData(){
        var fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        var requestf = NSBatchDeleteRequest(fetchRequest: fetch)
        do{
            try context.execute(requestf)
        }catch{
            print("Failed")
        }
        
        fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Activity")
        requestf = NSBatchDeleteRequest(fetchRequest: fetch)
        do{
            try context.execute(requestf)
        }catch{
            print("Failed")
        }
        
        fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Meal")
        requestf = NSBatchDeleteRequest(fetchRequest: fetch)
        do{
            try context.execute(requestf)
        }catch{
            print("Failed")
        }
        
        fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Rest")
        requestf = NSBatchDeleteRequest(fetchRequest: fetch)
        do{
            try context.execute(requestf)
        }catch{
            print("Failed")
        }
        
        fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Locomotion")
        requestf = NSBatchDeleteRequest(fetchRequest: fetch)
        do{
            try context.execute(requestf)
        }catch{
            print("Failed")
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName:"Activity")
        var size: NSInteger
        
        request.returnsObjectsAsFaults = false
        do{
            let result = try context.fetch(request)
            size = result.count
        }catch{
            size = 0
        }
        return size
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        var request = NSFetchRequest<NSFetchRequestResult>(entityName:"Activity")
        var myString: String!
        
        request.returnsObjectsAsFaults = false
        do{
            var result = try context.fetch(request)
            let item: Activity = result[indexPath.row] as! Activity
            request = NSFetchRequest<NSFetchRequestResult>(entityName:item.activityType!)
            let predicate = NSPredicate(format: "activityID = %@",item.activityID!)
            request.predicate = predicate
            result = try context.fetch(request)
            let testItem: NSManagedObject = result[0] as! NSManagedObject
            switch (item.activityType!) {
            case "Rest":
                myString = testItem.value(forKey: "sleepHours") as! String + " hour/s of sleep"
                break
            case "Meal":
                myString = testItem.value(forKey: "nameOfMeal") as! String
                myString.append(": ")
                myString.append(testItem.value(forKey: "calories") as! String)
                myString.append(" calories, ")
                myString.append(testItem.value(forKey: "mealType") as! String)
                break
            case "Locomotion":
                myString = testItem.value(forKey: "motionType") as! String
                myString.append(": ")
                myString.append(testItem.value(forKey: "kilometer") as! String)
                myString.append(" kilometers in ")
                myString.append(testItem.value(forKey: "minute") as! String)
                myString.append(" minutes")
                break
            default:
                myString = ""
            }
        }catch{
            myString = ""
        }
        cell.textLabel?.text = myString
        cell.detailTextLabel?.text = "Test"
        return cell
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}


//
//  LaunchController.swift
//  DietDoctorD
//
//  Created by June Hermoso on 11/12/2018.
//  Copyright © 2018 JH Company. All rights reserved.
//

import UIKit

class LaunchController: UIViewController {

    @IBOutlet weak var launchImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageName = "cardiogram_heart_working_300_clr.gif"
        let image = UIImage(named: imageName)
        launchImage.image = image
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

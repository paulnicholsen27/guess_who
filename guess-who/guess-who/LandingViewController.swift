//
//  LandingViewController.swift
//  guess-who
//
//  Created by Paul Nichols on 4/7/15.
//  Copyright (c) 2015 Paul Nichols. All rights reserved.
//

import UIKit

class LandingViewController: UIViewController {

    @IBOutlet weak var highScoreLabel: UILabel!
    
    @IBAction func cancelToLandingViewController(segue:UIStoryboardSegue){
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("you are here")
        let defaults = NSUserDefaults.standardUserDefaults()
        if let highScore = defaults.stringForKey("highScore") {
            highScoreLabel.text = "\(highScore)"
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

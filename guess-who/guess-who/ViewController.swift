//
//  ViewController.swift
//  guess-who
//
//  Created by Paul Nichols on 3/10/15.
//  Copyright (c) 2015 Paul Nichols. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var memberPic: UIImageView!
    
    @IBOutlet weak var score: UILabel!
    
    @IBOutlet weak var firstChoice: UIButton!
    @IBOutlet weak var secondChoice: UIButton!
    @IBOutlet weak var thirdChoice: UIButton!
    @IBOutlet weak var fourthChoice: UIButton!
    

    @IBAction func firstButtonPressed(sender: AnyObject) {
    }
    
    
    @IBAction func secondButtonPressed(sender: AnyObject) {
    }
    
    
    @IBAction func thirdButtonPressed(sender: AnyObject) {
    }
    
    @IBAction func fourthButtonPressed(sender: AnyObject) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


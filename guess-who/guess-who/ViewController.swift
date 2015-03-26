//
//  ViewController.swift
//  guess-who
//
//  Created by Paul Nichols on 3/10/15.
//  Copyright (c) 2015 Paul Nichols. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {


    @IBOutlet weak var memberPic: UIImageView!
    
    @IBOutlet weak var score: UILabel!
    
    @IBOutlet weak var firstChoice: UIButton!
    @IBOutlet weak var secondChoice: UIButton!
    @IBOutlet weak var thirdChoice: UIButton!
    @IBOutlet weak var fourthChoice: UIButton!
    
    
    @IBAction func guessChosen(sender: AnyObject) {
        checkAnswer(sender)
    }

    var rightAnswer:FMResultSet?
    var databasePath:String?
    var correctName:String?
    var memberDatabase:FMDatabase?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let path = NSBundle.mainBundle().pathForResource("members", ofType:"sqlite3")
        memberDatabase = FMDatabase(path: path)
        if memberDatabase == nil {
            println("error finding database")
        } else {
            if memberDatabase!.open(){
                println("database is ready")
            }
        }

        displayRandomMember()
        //close database?
        
    }
    
    func displayRandomMember(){
        println(databasePath)
        if memberDatabase!.open(){
            println("database is really ready")
        }
        let querySQL = "SELECT name, picture_name from member_data where picture_name is not 'None' ORDER BY RANDOM() LIMIT 1";
        rightAnswer = memberDatabase!.executeQuery(querySQL, withArgumentsInArray: nil)
        rightAnswer!.next()
        var correctName = rightAnswer!.stringForColumn("name")!
        let correctPicture = rightAnswer!.stringForColumn("picture_name")
        println("Correct answer is \(correctName)")
        let wrongAnswerSQLQuery = "SELECT name from member_data where picture_name is not 'None' and name is not '\(correctName)' ORDER BY RANDOM() LIMIT 3"
        let wrongAnswersResultSet:FMResultSet = memberDatabase!.executeQuery(wrongAnswerSQLQuery, withArgumentsInArray: nil)
        var wrongAnswersArray:[String] = []
        while wrongAnswersResultSet.next() == true {
            wrongAnswersArray.append(wrongAnswersResultSet.stringForColumn("name"))
        }
        var wrongButtons = [firstChoice, secondChoice, thirdChoice, fourthChoice]
        var correctButton = wrongButtons.removeAtIndex(Int(arc4random_uniform(4)))
        correctButton.setTitle(correctName, forState: .Normal)
        for i in 0..<wrongButtons.count{
            wrongButtons[i].setTitle(wrongAnswersArray[i], forState: .Normal)
        }

        memberPic.image = UIImage(named: correctPicture)
        return
    }
    
    func checkAnswer(sender:AnyObject) -> Bool{
        let selectedAnswer = sender.currentTitle!

        if selectedAnswer! == correctName! {
            println("Correct!")
            return true}
        else{
            println("Incorrect!")
            return false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


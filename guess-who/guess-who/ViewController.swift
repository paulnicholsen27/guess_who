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
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var firstChoice: UIButton!
    @IBOutlet weak var secondChoice: UIButton!
    @IBOutlet weak var thirdChoice: UIButton!
    @IBOutlet weak var fourthChoice: UIButton!
    @IBOutlet var choiceButtons: Array<UIButton>?
    
    @IBAction func guessChosen(sender: AnyObject) {
        checkAnswer(sender)
    }

    var rightAnswer:FMResultSet?
    var databasePath:String?
    var correctName:String?
    var correctButton:UIButton?
    var memberDatabase:FMDatabase?
    let redButton = UIImage(named: "red_button") as UIImage?
    let greenButton = UIImage(named: "green_button") as UIImage?
    let yellowButton = UIImage(named: "yellow_button") as UIImage?
    var score = 0
    var correctRun = 0
    var turnCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background.jpeg")!)
        let path = NSBundle.mainBundle().pathForResource("members", ofType:"sqlite3")
        memberDatabase = FMDatabase(path: path)
        if memberDatabase == nil {
            println("error finding database")
        } else {
            if memberDatabase!.open(){
                println("database is ready")
            }
        }
        scoreLabel.text = "\(score)"
        displayRandomMember()
        //close database?
        
    }
    
    func displayRandomMember(){
        for button in choiceButtons! {
            button.setBackgroundImage(yellowButton, forState: .Normal)
            button.userInteractionEnabled = true
        }
        let querySQL = "SELECT name, picture_name from member_data where picture_name is not 'None' ORDER BY RANDOM() LIMIT 1";
        rightAnswer = memberDatabase!.executeQuery(querySQL, withArgumentsInArray: nil)
        rightAnswer!.next()
        correctName = rightAnswer!.stringForColumn("name")!
        let correctPicture = rightAnswer!.stringForColumn("picture_name")
        println("Correct answer is \(correctName)")
        let wrongAnswerSQLQuery = "SELECT name from member_data where picture_name is not 'None' and name is not '\(correctName)' ORDER BY RANDOM() LIMIT 3"
        let wrongAnswersResultSet:FMResultSet = memberDatabase!.executeQuery(wrongAnswerSQLQuery, withArgumentsInArray: nil)
        var wrongAnswersArray:[String] = []
        while wrongAnswersResultSet.next() == true {
            wrongAnswersArray.append(wrongAnswersResultSet.stringForColumn("name"))
        }
        var wrongButtons = [firstChoice, secondChoice, thirdChoice, fourthChoice]
        correctButton = wrongButtons.removeAtIndex(Int(arc4random_uniform(4)))
        correctButton!.setTitle(correctName, forState: .Normal)
        for i in 0..<wrongButtons.count{
            wrongButtons[i].setTitle(wrongAnswersArray[i], forState: .Normal)
        }

        memberPic.image = UIImage(named: correctPicture)
        return
    }
    
    func checkAnswer(sender:AnyObject){
        let selectedAnswer = sender.currentTitle!
        for button in choiceButtons! {
            button.userInteractionEnabled = false
        }
        correctButton!.setBackgroundImage(greenButton, forState: .Normal)
        if selectedAnswer! == correctName! {
            correctRun += 1
            score += (100 * correctRun)
            scoreLabel.text = "\(score)"
            println(scoreLabel)
        } else {
            sender.setBackgroundImage(redButton, forState: .Normal)
            correctRun = 0
        }
        turnCount += 1
        if turnCount < 10 {
            displayRandomMember()
        } else {
            checkHighScore()
            println("game over")
        }
        
    }

    func checkHighScore(){
        let defaults = NSUserDefaults.standardUserDefaults()
        var oldHighScore = defaults.integerForKey("highScore")
        if (score > oldHighScore) {
            println("Your old High Score was \(oldHighScore)")
            println("your new high score is \(score)")
            defaults.setInteger(score, forKey: "highScore")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


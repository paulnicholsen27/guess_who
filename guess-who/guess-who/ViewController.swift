//
//  ViewController.swift
//  guess-who
//
//  Created by Paul Nichols on 3/10/15.
//  Copyright (c) 2015 Paul Nichols. All rights reserved.
//

//TODO
//RickBennett appeared twice
//people with nicknames
//James Roth - no picture

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
    
    @IBOutlet weak var playAgainButton: UIButton!
    
    @IBAction func guessChosen(sender: AnyObject) {
        checkAnswer(sender)
    }
    let redButton = UIImage(named: "red_button") as UIImage?
    let greenButton = UIImage(named: "green_button") as UIImage?
    let yellowButton = UIImage(named: "yellow_button") as UIImage?
    var rightAnswer:FMResultSet?
    var databasePath:String?
    var correctName:String?
    var correctButton:UIButton?
    var memberDatabase:FMDatabase?

    var score = 0
    var correctRun = 0
    var turnCount = 0
    var queryParameters = ["None"] //"None" to exclude empty pics, names to be added
    var queryHoles = "?"
    
    @IBAction func playAgainPressed(sender: AnyObject) {
        resetGame()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background.jpeg")!)
        let path = NSBundle.mainBundle().pathForResource("members", ofType:"sqlite3")
        playAgainButton.hidden = true
        memberDatabase = FMDatabase(path: path)
        if memberDatabase!.open(){
            println("database is ready")
        } else {
            println("error finding database")
        }
        scoreLabel.text = "\(score)"
        resetGame()
        //close database?
        
    }
    

    func resetGame(){
        score = 0
        turnCount = 0
        correctRun = 0
        playAgainButton.hidden = true
        queryParameters = ["None"]
        queryHoles = "?"
        displayRandomMember()
    }
    
    func displayRandomMember(){
        for button in choiceButtons! {
            button.setBackgroundImage(yellowButton, forState: .Normal)
            button.userInteractionEnabled = true
        }
        
        println(queryHoles)
        let querySQL = "SELECT name, picture_name from member_data where picture_name is not ? and name not in (\(queryHoles)) ORDER BY RANDOM() LIMIT 1";
        rightAnswer = memberDatabase!.executeQuery(querySQL, withArgumentsInArray: queryParameters)
        rightAnswer!.next()
        correctName = rightAnswer!.stringForColumn("name")!

        let correctPicture = rightAnswer!.stringForColumn("picture_name")
        println("Correct answer is \(correctName)")
        let wrongAnswerSQLQuery = "SELECT name from member_data where picture_name is not ? and name is not ? ORDER BY RANDOM() LIMIT 3"
        let wrongAnswersResultSet:FMResultSet = memberDatabase!.executeQuery(wrongAnswerSQLQuery, withArgumentsInArray: ["None", correctName!])
        var wrongAnswersArray:[String] = []
        while wrongAnswersResultSet.next() == true {
            wrongAnswersArray.append(wrongAnswersResultSet.stringForColumn("name"))
        }
        var wrongButtons = [firstChoice, secondChoice, thirdChoice, fourthChoice]
        correctButton = wrongButtons.removeAtIndex(Int(arc4random_uniform(4)))
        rotateButton(correctButton!, newname: correctName!)
        for i in 0..<wrongButtons.count{
            rotateButton(wrongButtons[i], newname:wrongAnswersArray[i])
        }

        memberPic.image = UIImage(named: correctPicture)
        queryParameters.append(correctName!)
        println(queryParameters)
        if (count(queryHoles) > 0) {
            queryHoles += (",?") //already has one ?
        } else {
            queryHoles += ("?")
        }
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
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 1))
        dispatch_after(delayTime, dispatch_get_main_queue()){
        
            self.turnCount += 1
            if self.turnCount < 10 {
                self.displayRandomMember()
            } else {
                self.checkHighScore()
                self.playAgainButton.hidden = false
                println("game over")
            }
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
    
    func rotateButton(button:UIButton, newname:String) {
        
        UIView.transitionWithView(
            button,
            duration: 0.5,
            options: UIViewAnimationOptions.TransitionFlipFromLeft | .AllowAnimatedContent,
            animations: {button.setTitle(newname, forState:.Normal)},
            completion: nil )
        }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}



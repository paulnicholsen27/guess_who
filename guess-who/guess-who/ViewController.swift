//
//  ViewController.swift
//  guess-who
//
//  Created by Paul Nichols on 3/10/15.
//  Copyright (c) 2015 Paul Nichols. All rights reserved.
//

//TODO
//RickBennett appeared twice
//display high score and/or game score
//fix display on small screens

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
    let redButton = UIImage(named: "red_button")
    let greenButton = UIImage(named: "green_button")
    let yellowButton = UIImage(named: "yellow_button")
    var memberSet:FMResultSet?
    var databasePath:String?
    var correctName:String?
    var correctButton:UIButton?
    var memberDatabase:FMDatabase?

    var score = 0
    var correctRun = 0
    var turnCount = 0
    var queryParameters = ["None"] //"None" to exclude empty pics, names to be added
    var queryHoles = "" //append "?" for each already-seen name
    
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
        queryHoles = ""
        setUpGameBoard()
    }
    
    func setUpGameBoard(){
        for button in choiceButtons! {
            button.setBackgroundImage(yellowButton, forState: .Normal)
            button.userInteractionEnabled = true
        }
        
        var memberInfo = getMembers()
        var wrongButtons = [firstChoice, secondChoice, thirdChoice, fourthChoice]
        correctButton = wrongButtons.removeAtIndex(Int(arc4random_uniform(4)))
        rotateButton(correctButton!, newname: correctName!)
        for i in 0..<wrongButtons.count{
            rotateButton(wrongButtons[i], newname:memberInfo.wrongAnswers[i])
        }

        memberPic.image = UIImage(named: memberInfo.correctPicture)
        queryParameters.append(memberInfo.correctName) //keep track of names already seen this game
        if (count(queryHoles) > 0) {
            queryHoles += (",?") //if already has one '?'
        } else {
            queryHoles += ("?")
        }
        return
    }
    
    func getMembers() -> (correctName: String, correctPicture:String, wrongAnswers:[String]) {
        let querySQL = "SELECT name, picture_name from member_data where picture_name is not ? and name not in (\(queryHoles)) ORDER BY RANDOM() LIMIT 4";
        memberSet = memberDatabase!.executeQuery(querySQL, withArgumentsInArray: queryParameters)
        memberSet!.next()
        correctName = memberSet!.stringForColumn("name")!
        
        let correctPicture = memberSet!.stringForColumn("picture_name")
        
        var wrongAnswers:[String] = []
        while memberSet!.next() == true {
            wrongAnswers.append(memberSet!.stringForColumn("name"))
        }

        return (correctName!, correctPicture!, wrongAnswers)
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
        } else {
            sender.setBackgroundImage(redButton, forState: .Normal)
            correctRun = 0
        }
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 1))
        dispatch_after(delayTime, dispatch_get_main_queue()){
        
            self.turnCount += 1
            if self.turnCount < 10 {
                self.setUpGameBoard()
            } else {
                self.checkHighScore()
                self.playAgainButton.hidden = false
            }
        }
        
    }

    func checkHighScore(){
        let defaults = NSUserDefaults.standardUserDefaults()
        var oldHighScore = defaults.integerForKey("highScore")
        if (score > oldHighScore) {
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


}



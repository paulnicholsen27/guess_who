//
//  ViewController.swift
//  guess-who
//
//  Created by Paul Nichols on 3/10/15.
//  Copyright (c) 2015 Paul Nichols. All rights reserved.
//

//TODO
//display high score and/or game score
//assign favicons
//include ad support
//opening screen

import UIKit
import Foundation
import AVFoundation
import iAd

class ViewController: UIViewController {

    @IBOutlet weak var memberPic: UIImageView!
    @IBOutlet weak var pictureFrame: UIImageView!
    @IBOutlet weak var firstChoice: UIButton!
    @IBOutlet weak var firstChoiceHeight: NSLayoutConstraint!
    @IBOutlet weak var secondChoice: UIButton!
    @IBOutlet weak var secondChoiceHeight: NSLayoutConstraint!
    @IBOutlet weak var thirdChoice: UIButton!
    @IBOutlet weak var thirdChoiceHeight: NSLayoutConstraint!
    @IBOutlet weak var fourthChoice: UIButton!
    @IBOutlet weak var fourthChoiceHeight: NSLayoutConstraint!
    @IBOutlet var choiceButtons: Array<UIButton>?
    
    @IBOutlet weak var scoreLabel: UIBarButtonItem!
    @IBOutlet weak var playAgainButton: UIButton!
    
    @IBOutlet weak var newMemberBadge: UIImageView!
    @IBAction func guessChosen(sender: AnyObject) {
        checkAnswer(sender)
    }
    
    @IBOutlet weak var soundDisplay: UIButton!

    @IBOutlet var buttonHeights: [NSLayoutConstraint]!
    
    let wrongButton = UIImage(named: "wrong_button")
    let rightButton = UIImage(named: "right_button")
    let generalButton = UIImage(named: "general_button")
    let soundOn = UIImage(named: "unmute")!.imageWithRenderingMode(.AlwaysTemplate)
    let soundOff = UIImage(named: "mute")!.imageWithRenderingMode(.AlwaysTemplate)
    var memberSet:FMResultSet?
    var databasePath:String?
    var correctName:String?
    var correctButton:UIButton?
    var newMember:Bool?
    var memberDatabase:FMDatabase?

    var score = 0
    var correctRun = 0
    var turnCount = 0
    var queryParameters = ["None"] //"None" to exclude empty pics, names to be added
    var queryHoles = "" //append "?" for each already-seen name

    @IBOutlet weak var navbar: UIToolbar!
    
    var correctSound = AVAudioPlayer()
    var wrongSound = AVAudioPlayer()
    var finishedSound = AVAudioPlayer()
    var playSound:String?
    
    var smallScreen = false
    
    
    
    
    @IBAction func playAgainPressed(sender: AnyObject) {
        resetGame()
    }
    
    func setupAudioPlayerWithFile(file:NSString, type:NSString) -> AVAudioPlayer {
        let path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        let url = NSURL.fileURLWithPath(path!)
        var audioPlayer:AVAudioPlayer?
        do {
            audioPlayer = try AVAudioPlayer(contentsOfURL: url)
        } catch let error1 as NSError {
            audioPlayer = nil
            print(error1)
        }
        return audioPlayer!
    }
    
    @IBAction func toggleSound(sender: AnyObject) {
        if playSound! == "on" {
            NSUserDefaults().setObject("off", forKey: "playSound")
            playSound = NSUserDefaults().stringForKey("playSound")!
            soundDisplay.setImage(soundOff, forState: UIControlState.Normal)
        } else {
            NSUserDefaults().setObject("on", forKey: "playSound")
            playSound = NSUserDefaults().stringForKey("playSound")!
            soundDisplay.setImage(soundOn, forState: UIControlState.Normal)
        }
        soundDisplay.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.canDisplayBannerAds = true
        
        let height = UIScreen.mainScreen().bounds.size.height
        if (height < 500) { //shrink for iphone4
            smallScreen = true
        }
        playAgainButton.setTitle("", forState: .Normal)
        
        //sound Setup
        playSound = NSUserDefaults().stringForKey("playSound")
        if (playSound == nil) {
            playSound = "on"
        }
        if playSound == "on" {
            soundDisplay.setImage(soundOn, forState: UIControlState.Normal)
        } else {
            soundDisplay.setImage(soundOff, forState: UIControlState.Normal)
        }
        soundDisplay.tintColor = UIColor.whiteColor()
        correctSound = self.setupAudioPlayerWithFile("correct", type: "wav")
        wrongSound = self.setupAudioPlayerWithFile("wrong", type: "wav")
        finishedSound = self.setupAudioPlayerWithFile("finished", type: "wav")
        correctSound.prepareToPlay()
        
        self.originalContentView.backgroundColor = UIColor(patternImage: UIImage(named: "background_music.jpg")!)
        self.originalContentView.translatesAutoresizingMaskIntoConstraints = true
        let path = NSBundle.mainBundle().pathForResource("members", ofType:"sqlite3")
        playAgainButton.hidden = true
        newMemberBadge.hidden = true
        newMemberBadge.layer.zPosition = 54
        memberDatabase = FMDatabase(path: path)
        if memberDatabase!.open(){
            print("database is ready")
        } else {
            print("error finding database")
        }
        scoreLabel.title = "\(score)"
        resetGame()
    }

    func resetGame(){
        score = 0
        scoreLabel.title = "\(score)"
        turnCount = 0
        correctRun = 0
        playAgainButton.hidden = true
        pictureFrame.hidden = false
        memberPic.hidden = false
        queryParameters = ["None"]
        queryHoles = ""
        setUpGameBoard()
    }
    
    func setUpGameBoard(){
        for button in choiceButtons! {
            button.setBackgroundImage(generalButton, forState: .Normal)
            button.userInteractionEnabled = true
            button.frame.size.width = 50
        }
        
        var memberInfo = getMembers()
        var wrongButtons = [firstChoice, secondChoice, thirdChoice, fourthChoice]
        correctButton = wrongButtons.removeAtIndex(Int(arc4random_uniform(4)))
        rotateButton(correctButton!, newname: correctName!)
        for i in 0..<wrongButtons.count{
            rotateButton(wrongButtons[i], newname:memberInfo.wrongAnswers[i])
        }
        let correctPicture = UIImage(named: memberInfo.correctPictureName)
        let scaledSize = createScaleSize(correctPicture!)
        if (newMember == true) {
            newMemberBadge.hidden = false
        } else {
            newMemberBadge.hidden = true
        }
        memberPic.translatesAutoresizingMaskIntoConstraints = true
        memberPic.image = correctPicture
        memberPic.frame = CGRect(x: self.view.center.x - scaledSize.width / 2, y: self.view.center.y - scaledSize.height / 2 - 80, width: scaledSize.width, height: scaledSize.height)
        let frameSize = createFrameSize(scaledSize)
        pictureFrame.frame = CGRect(x: memberPic.frame.origin.x - 25, y: memberPic.frame.origin.y - 30, width: frameSize.width, height: frameSize.height)
        pictureFrame.translatesAutoresizingMaskIntoConstraints = true
        pictureFrame.layer.zPosition = 27
        queryParameters.append(memberInfo.correctName) //keep track of names already seen this game
        if (queryHoles.characters.count > 0) {
            queryHoles += (",?") //if already has one '?'
        } else {
            queryHoles += ("?")
        }
        return
    }
    
    func getMembers() -> (correctName:String, correctPictureName:String, newMember:Bool, wrongAnswers:[String]) {
        let querySQL = "SELECT name, picture_name, roles from member_data where picture_name is not ? and name not in (\(queryHoles)) ORDER BY RANDOM() LIMIT 4";
        memberSet = memberDatabase!.executeQuery(querySQL, withArgumentsInArray: queryParameters)
        memberSet!.next()
        correctName = memberSet!.stringForColumn("name")!
        print(correctName)
        
        let correctPictureName = memberSet!.stringForColumn("picture_name")
        let roles = memberSet!.stringForColumn("roles")
        newMember = false
        if roles.lowercaseString.rangeOfString("new member") != nil {
            newMember = true
        }
        var wrongAnswers:[String] = []
        while memberSet!.next() == true {
            wrongAnswers.append(memberSet!.stringForColumn("name"))
        }

        return (correctName!, correctPictureName!, newMember!, wrongAnswers)
    }
    
    func checkAnswer(sender:AnyObject){
        let selectedAnswer = sender.currentTitle!
        for button in choiceButtons! {
            button.userInteractionEnabled = false
        }
        correctButton!.setBackgroundImage(rightButton, forState: .Normal)
        if selectedAnswer! == correctName! {
            correctRun += 1
            score += (100 * correctRun)
            scoreLabel.title = "\(score)"
            if playSound == "on" {
                correctSound.play()
            }
        } else {
            sender.setBackgroundImage(wrongButton, forState: .Normal)
            if playSound == "on" {
                wrongSound.play()
            }
            correctRun = 0
        }
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 1))
        dispatch_after(delayTime, dispatch_get_main_queue()){
        
            self.turnCount += 1
            if self.turnCount < 10 {
                self.setUpGameBoard()
            } else {
                self.checkHighScore()
                if self.playSound == "on" {
                    self.finishedSound.play()
                }
                self.newMemberBadge.hidden = true
                self.playAgainButton.hidden = false
                self.pictureFrame.hidden = true
                self.memberPic.hidden = true
            }
        }
        
    }

    func createScaleSize(unscaled:UIImage) -> (CGSize) {
        var height:CGFloat
        if (smallScreen) {
            height = 110
        } else {
            height = 160
        }
        let scaleFactor = height / unscaled.size.height
        let newWidth = unscaled.size.width * scaleFactor
        return CGSizeMake(newWidth, height)
    }
    
    func createFrameSize(size:CGSize) -> (CGSize) {
        //returns frame 15 px bigger than image
        return CGSizeMake(size.width + 50, size.height + 60)
    }
    
    func checkHighScore(){
        let defaults = NSUserDefaults.standardUserDefaults()
        let oldHighScore = defaults.integerForKey("highScore")
        if (score > oldHighScore) {
            defaults.setInteger(score, forKey: "highScore")
        }
    }
    
    func rotateButton(button:UIButton, newname:String) {
        
        UIView.transitionWithView(
            button,
            duration: 0.5,
            options: [UIViewAnimationOptions.TransitionFlipFromLeft, .AllowAnimatedContent],
            animations: {button.setTitle(newname, forState:.Normal)},
            completion: nil )
        }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        for height in buttonHeights! {
            if smallScreen {
                height.constant = 35
            } else {
                height.constant = 45
            }
        }
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        
    }

}



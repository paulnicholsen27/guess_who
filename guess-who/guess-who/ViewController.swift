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
    
    let memberDatabase = FMDatabase(path: "/Users/paulnichols/Documents/code/gmcw/guess_who/members.sqlite3")
    let rightAnswer:FMResultSet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if memberDatabase == nil {
            println("error finding database")
        } else {
            if memberDatabase.open(){
                println("database is ready")
            }
        }
//        let results:FMResultSet? = memberDatabase.executeQuery("select count(*) as numrows from member_data where picture is not 'None'", withArgumentsInArray: [])
//        results?.next()
//        let numMembers = results?.intForColumn("numrows")
//        println(numMembers!)
        
//        let querySQL = "SELECT name, picture from member_data where picture is not 'None'";
//        let membersWithPhotos:FMResultSet = memberDatabase.executeQuery(querySQL, withArgumentsInArray: nil)
//        membersWithPhotos.next()
        
        
        displayRandomMember()
        //close database?
        
    }
    
    func displayRandomMember(){
        let querySQL = "SELECT name, picture from member_data where picture is not 'None' ORDER BY RANDOM() LIMIT 1";
        let rightAnswer:FMResultSet = memberDatabase.executeQuery(querySQL, withArgumentsInArray: nil)
        rightAnswer.next()
        let correctName = rightAnswer.stringForColumn("name")
        let correctPicture = rightAnswer.stringForColumn("picture")
        println(correctName)
        let wrongAnswerSQLQuery = "SELECT name from member_data where picture is not 'None' and name is not '\(correctName)' ORDER BY RANDOM() LIMIT 3"
        println(wrongAnswerSQLQuery)
        let wrongAnswers:FMResultSet = memberDatabase.executeQuery(wrongAnswerSQLQuery, withArgumentsInArray: nil)
        while wrongAnswers.next() == true {
            println(wrongAnswers.stringForColumn("name"))
        }
        return
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


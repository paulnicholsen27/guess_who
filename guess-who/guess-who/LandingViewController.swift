//
//  LandingViewController.swift
//  guess-who
//
//  Created by Paul Nichols on 4/7/15.
//  Copyright (c) 2015 Paul Nichols. All rights reserved.
//

import UIKit
import MessageUI

class LandingViewController: UIViewController, MFMailComposeViewControllerDelegate {

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
    

    @IBAction func contactPressed(sender: AnyObject) {
        var emailTitle = "Feedback on Chorus Member App"
        var toRecipients = ["pnichols104@gmail.com"]
        var mc: MFMailComposeViewController = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setSubject(emailTitle)
        mc.setToRecipients(toRecipients)
        self.presentViewController(mc, animated: true, completion: nil)
        func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError) {
            switch result.value {
            case MFMailComposeResultCancelled.value:
                println("Mail cancelled")
            case MFMailComposeResultSaved.value:
                println("Mail saved")
            case MFMailComposeResultSent.value:
                println("Mail sent")
            case MFMailComposeResultFailed.value:
                println("Mail sent failure: %@", [error.localizedDescription])
            default:
                break
            }
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
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

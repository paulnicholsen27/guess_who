//
//  LandingViewController.swift
//  guess-who
//
//  Created by Paul Nichols on 4/7/15.
//  Copyright (c) 2015 Paul Nichols. All rights reserved.
//

import UIKit
import MessageUI
import iAd

class LandingViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var highScoreLabel: UILabel!
    
    @IBAction func cancelToLandingViewController(segue:UIStoryboardSegue){
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.canDisplayBannerAds = true
        let defaults = NSUserDefaults.standardUserDefaults()
        if let highScore = defaults.stringForKey("highScore") {
            highScoreLabel.text = "\(highScore)"
        }
        
    }

    @IBAction func contactPressed(sender: AnyObject) {
        let emailTitle = "Feedback on Chorus Member App"
        let toRecipients = ["pnichols104@gmail.com"]
        let mc: MFMailComposeViewController = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setSubject(emailTitle)
        mc.setToRecipients(toRecipients)
        self.presentViewController(mc, animated: true, completion: nil)
    }
    
    func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError?) {
        switch result.rawValue {
        case MFMailComposeResultCancelled.rawValue:
            print("Mail cancelled")
        case MFMailComposeResultSaved.rawValue:
            print("Mail saved")
        case MFMailComposeResultSent.rawValue:
            print("Mail sent")
        case MFMailComposeResultFailed.rawValue:
            print("Mail sent failure: %@", [error?.localizedDescription])
        default:
            break
        }
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    


}

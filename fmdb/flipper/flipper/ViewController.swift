//
//  ViewController.swift
//  flipper
//
//  Created by Paul Nichols on 4/29/15.
//  Copyright (c) 2015 Paul Nichols. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var cardView: UIView!
    var front: UIImageView!
    var back: UIImageView!
    var showingBack = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        front = UIImageView(image: UIImage(named: "front.png"))
        back = UIImageView(image: UIImage(named: "back.png"))
        
        let singleTap = UITapGestureRecognizer(target: self, action: Selector("tapped"))
        singleTap.numberOfTapsRequired = 1
        
        let rect = CGRectMake(20, 20, back.image!.size.width, back.image!.size.height)
        
        cardView = UIView(frame: rect)
        cardView.addGestureRecognizer(singleTap)
        cardView.userInteractionEnabled = true
        cardView.addSubview(back)
        view.addSubview(cardView)
        

        
    }

    func tapped() {
        if showingBack {
            UIView.transitionFromView(back, toView: front, duration: 1, options: UIViewAnimationOptions.TransitionFlipFromLeft, completion: nil)
            showingBack = false
        } else {
            UIView.transitionFromView(front, toView: back, duration: 1, options: UIViewAnimationOptions.TransitionFlipFromRight, completion: nil)
            showingBack = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


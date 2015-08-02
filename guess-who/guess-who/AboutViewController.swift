//
//  AboutViewController.swift
//  guess-who
//
//  Created by Paul Nichols on 4/8/15.
//  Copyright (c) 2015 Paul Nichols. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var firstParagraph: UILabel!
    @IBOutlet weak var secondParagraph: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        var height = UIScreen.mainScreen().bounds.size.height
        if (height < 500) { //shrink for iphone4
            firstParagraph.font = UIFont(name: firstParagraph.font.fontName, size: 13)
            secondParagraph.font = UIFont(name: secondParagraph.font.fontName, size: 13)
        }
        firstParagraph.textAlignment = NSTextAlignment.Justified        // Do any additional setup after loading the view.
    }
}

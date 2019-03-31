//
//  SecondPage.swift
//  MedSafe
//
//  Created by Melody Lui on 2019-03-30.
//  Copyright © 2019 Melody Lui. All rights reserved.
//

import Foundation
import UIKit
public class SecondPage : UIViewController {
    
    @IBOutlet weak var Summary: UITextView!
    
    @IBOutlet weak var checkList: UITextView!
    
    @IBOutlet weak var emailButton: UIButton!
    
    @IBOutlet weak var printButton: UIButton!
    
    public weak var infoDelegate: ViewController? = nil;
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        Summary.layer.cornerRadius = 5.0
        checkList.layer.cornerRadius = 5.0
        emailButton.layer.cornerRadius = 8.0
        printButton.layer.cornerRadius = 8.0
        
        // Do any additional setup after loading the view, typically from a nib.

        Summary.text = infoDelegate?.textView.text;
}
}

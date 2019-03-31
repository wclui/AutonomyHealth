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
    var myStringValue:String?
    
    public weak var infoDelegate: ViewController? = nil;
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        let main_vc = ViewController()
//        print(main_vc.finalList);
        Summary.text = myStringValue
        
}
}

//
//  SecondPage.swift
//  MedSafe
//
//  Created by Melody Lui on 2019-03-30.
//  Copyright © 2019 Melody Lui. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

public class SecondPage : UIViewController {
    
    @IBOutlet weak var Summary: UITextView!
    var myStringValue:String?
    var targetCode = "hi"
//    myStringValue = ""
    
    public weak var infoDelegate: ViewController? = nil;
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        let main_vc = ViewController()
//        print(main_vc.finalList);
//        Summary.text = myStringValue
}
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        let example_text = "Hi My name is doctor price . I am your family doctor for today . Good evening you look pale and your voice is out of tune . Yes doctor I’m running a temperature and have a sore throat . You have moderate fever . The fever is high at 99.8 . Your blood pressure is fine . You’ve few symptoms of malaria . I would suggest you undergo blood test . Nothing to worry about . In most cases the test come out to be negative . It is just precautionary as there have been spurt in malaria cases in the last month or so . I am prescribing three medicines and a syrup . The number of dots in front of each tells you how many times in the day you’ve to take them . For example the two dots here mean you have to take the medicine twice in the day, once in the morning and once after dinner ."
        
        //        myStringValue
        Summary.text = example_text
        TestML.summarize(text: example_text) { (summary, error) in
            guard error == nil else {
                print(error)
                return;
            }
            print(summary!["prescriptions"]);
        }
        
    }
    
    @IBAction func sendEmail(_ sender: Any) {
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            return
        }
        
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self as! MFMailComposeViewControllerDelegate
        
        // Configure the fields of the interface.
        composeVC.setSubject("Visit Summary and Checklist!")
        
        
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
        
        func mailComposeController(controller: MFMailComposeViewController,
                                   didFinishWithResult result: MFMailComposeResult, error: NSError?) {
            // Check the result or perform other tasks.
            
            // Dismiss the mail compose view controller.
            controller.dismiss(animated: true, completion: nil)
        }
    }
    
    func translateText(text_to_translate: String) {
        
        guard !text_to_translate.isEmpty else {
            return
        }
        
        let task = try? GoogleTranslate.sharedInstance.translateTextTask(text: text_to_translate, targetLanguage: "", completionHandler: { (translatedText: String?, error: Error?) in
            debugPrint(error?.localizedDescription)
            
            DispatchQueue.main.async {
                print("Translated Text: ");
                print(translatedText);
            }
            
        })
        
        task?.resume()
    }
    
}

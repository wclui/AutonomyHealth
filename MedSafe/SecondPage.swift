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
    
    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var Summary: UITextView!
    @IBOutlet weak var languageSegmentControl: UISegmentedControl!
    
    @IBOutlet weak var printBtn: UIButton!
    @IBOutlet weak var emailBtn: UIButton!
    
    public let languages = ["en", "ar", "es"];
    
    public var sectionKeys: [String] = ["prescriptions", "conditions", "management", "referrals", "tests"];
    public var summary_global: [String: [String]] = [:] {
        didSet {
            self.localTokenizedString = self.summary_global;
        }
    }
    
    public var myStringValue:String? {
        didSet {
            self.localizedStringValue = self.myStringValue;
        }
    }
    public var tokenizedString: [String]?
    
    public var localizedStringValue:String?
    public var localTokenizedString:[String: [String]] = [:];
    
    public weak var infoDelegate: ViewController? = nil;
    var targetCode = "es"
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        let main_vc = ViewController()
//        print(main_vc.finalList);
//        Summary.text = myStringValue
        emailBtn.backgroundColor = Colors.color2
        emailBtn.tintColor = UIColor.white
        printBtn.backgroundColor = Colors.color3
        printBtn.tintColor = UIColor.white
        emailBtn.layer.cornerRadius = 8.0
        printBtn.layer.cornerRadius = 8.0
        
//        Summary.layer.borderWidth = 1
//        Summary.layer.cornerRadius = 8
//        Summary.layer.borderColor = Colors.color1.cgColor;
        tableView.layer.borderWidth = 1
        tableView.layer.cornerRadius = 8
        tableView.layer.borderColor = Colors.color1.cgColor;
        
        tableView.dataSource = self;
        tableView.delegate = self;
        
        
        self.languageSegmentControl.addTarget(self, action: #selector(segmentPressed(segment:)), for: .allEvents)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Summary", style: .done, target: self, action: #selector(summaryBtnPressed))
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        guard let tokenizedString = self.tokenizedString else { return; }
        
//        Summary.text = myStringValue
        TestML.summarize(sen_list: tokenizedString) { (summary, error) in
            guard error == nil, let summary = summary else {
                print(error)
                return;
            }
            
            self.summary_global = summary;
            self.tableView.reloadData();
        }
        
    }
    
    @objc public func segmentPressed(segment: UISegmentedControl){
        var language  = languages[segment.selectedSegmentIndex]
        self.translateText(language: language)
        
        
    }
    
    @objc public func summaryBtnPressed (){
        guard let thirdPage = self.storyboard?.instantiateViewController(withIdentifier: "ThirdPage") as? ThirdPage else { return;
        }
        thirdPage.summary = self.localizedStringValue;
        self.navigationController?.pushViewController(thirdPage, animated: true);
        
    }
}

extension SecondPage : UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionKeys.count;
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let classifications = self.localTokenizedString[sectionKeys[section]] else { return 0; }
        return classifications.count;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "checkListCell") as? checkListCell else { return UITableViewCell(); }
        guard let classifications = self.localTokenizedString[sectionKeys[indexPath.section]] else { return UITableViewCell(); }
        
        let bulletPoint = classifications[indexPath.row]
        
        cell.setup(text: bulletPoint)
        
        
        return cell;
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionKeys[section];
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "checkListCell") as? checkListCell else { return; }
        guard let classifications = self.localTokenizedString[sectionKeys[indexPath.section]] else { return; }
        
        print(classifications[indexPath.row]);
    }
    
    func translateText(language: String) {
        
        guard let text_to_translate = self.myStringValue else {
            return
        }
        guard let stringTokens = self.tokenizedString else { return; }
        
        var prescriptions = [String]()
        var conditions = [String]()
        var management = [String]()
        var referrals = [String]()
        var tests = [String]()
        
        var totalCount = 0
        for key in sectionKeys {
            guard let conArr = self.summary_global[key] else { continue; }
            let origCount = conArr.count;
            var curCount = 0;
            for i in 0..<conArr.count {
                
                let task = try? GoogleTranslate.sharedInstance.translateTextTask(text: conArr[i], targetLanguage: language, completionHandler: { (translatedText: String?, error: Error?) in
                    debugPrint(error?.localizedDescription)
                    
                    guard let translatedText = translatedText else {
                        curCount += 1;
                        
                        if curCount == origCount {
                            totalCount += 1;
                        }
                        
                        if totalCount == self.sectionKeys.count {
                            self.localTokenizedString = ["prescriptions": prescriptions, "conditions": conditions, "management": management, "referrals": referrals, "tests":tests];
                            DispatchQueue.main.async {
                                self.tableView.reloadData();
                            }
                        }
                        return;
                    }
                    DispatchQueue.main.async {
                        print("Translated Text: ");
                        print(translatedText);
                    }
                    
                    if key == "prescriptions" { prescriptions.append(translatedText); }
                    if key == "conditions" { conditions.append(translatedText); }
                    if key == "management" { management.append(translatedText); }
                    if key == "referrals" { referrals.append(translatedText); }
                    if key == "tests" { tests.append(translatedText); }
                    
                    curCount += 1;
                    
                    if curCount == origCount {
                        totalCount += 1;
                    }
                    
                    if totalCount == self.sectionKeys.count {
                        DispatchQueue.main.async {
                            self.tableView.reloadData();
                        }
                    }
                });
                
                task?.resume()
            }
        }
        
        let task = try? GoogleTranslate.sharedInstance.translateTextTask(text: text_to_translate, targetLanguage: language, completionHandler: { (translatedText: String?, error: Error?) in
            
            self.localizedStringValue = translatedText;
        })
        
        task?.resume();
    }
    
}

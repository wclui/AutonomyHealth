//
//  ViewController.swift
//  MedSafe
//
//  Created by Melody Lui on 2019-03-30.
//  Copyright © 2019 Melody Lui. All rights reserved.
//

import UIKit
import Speech
import AVFoundation
import NaturalLanguage


public class ViewController: UIViewController {

 //viper
    //mvvm
    @IBOutlet weak var startStopBtn: UIButton!
    
    @IBOutlet weak var segmentCtrl: UISegmentedControl!
    
    @IBOutlet weak var textView: UITextView!
    
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US")) //1
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()
    var lang: String = "en-US"
    var finalList = [String]()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        startStopBtn.isEnabled = false  //2
        
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: lang))
        SFSpeechRecognizer.requestAuthorization { (authStatus) in  //4
            
            var isButtonEnabled = false
            
            switch authStatus {  //5
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.startStopBtn.isEnabled = isButtonEnabled
            }
        }
        
        self.speechRecognizer?.delegate = self as? SFSpeechRecognizerDelegate  //3
//        let recognitionTask = SFSpeechRecognitionTask();
//        self.speechRecognizer?.recognitionTask(with: recognitionTask, resultHandler: { (recognitionResult, error) in
//            guard error == nil else {
//                print(error);
//                return;
//            }
//
//            print("hello");
//        });
        
/*        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
         */
    }
         /*
    
    @objc public func doneButtonPressed() {
        guard let nextPage = self.storyboard?.instantiateViewController(withIdentifier: "SecondPage") else { return; }
        
        self.navigationController?.pushViewController(nextPage, animated: true);

    }
  */
    
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        let example_text = "Hi My name is doctor price . I am your family doctor for today . Good evening you look pale and your voice is out of tune . Yes doctor I’m running a temperature and have a sore throat . You have moderate fever . The fever is high at 99.8 . Your blood pressure is fine . You’ve few symptoms of malaria . I would suggest you undergo blood test . Nothing to worry about . In most cases the test come out to be negative . It is just precautionary as there have been spurt in malaria cases in the last month or so . I am prescribing three medicines and a syrup . The number of dots in front of each tells you how many times in the day you’ve to take them . For example the two dots here mean you have to take the medicine twice in the day, once in the morning and once after dinner ."
        TestML.summarize(text: example_text) { (summary, error) in
            guard error == nil else {
                return;
            }
            
            self.textView.text = summary;
        }
    }
    
    @IBAction func segmentAct(_ sender: Any) {
        switch segmentCtrl.selectedSegmentIndex {
        case 0:
            lang = "en-US"
            break;
        case 1:
            lang = "fr-FR"
            break;
        case 2:
            lang = "es"
            break;
        default:
            lang = "en-US"
            break;
        }
        
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: lang))
    }
    
    @IBAction func startStopAct(_ sender: Any) {
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: lang))
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            startStopBtn.isEnabled = false
            startStopBtn.setTitle("Start Recording", for: .normal)
        } else {
            startRecording()
            startStopBtn.setTitle("Stop Recording", for: .normal)
        }
    }
    
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        let nextPage = self.storyboard?.instantiateViewController(withIdentifier: "SecondPage") as! SecondPage 
//        nextPage.infoDelegate = self
        
        var text:String = ""
        
        for i in 0..<self.finalList.count-1{
            text += self.finalList[i] + ". ";
        }
        

        nextPage.myStringValue = text
        
        self.navigationController?.pushViewController(nextPage, animated: true);
        
        
        
        
        
        
        
    }
    
    
    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            //try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        var elapsedTime: Date = Date();
//        var prevCount = 0
        
        var count: Int = 0
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            var finalText: String = ""
            
            
//            print("Here again!")
            
            if let result = result {
                // Update the text view with the results.
                finalText += result.bestTranscription.formattedString
                self.textView.text = finalText
                isFinal = result.isFinal
                if(Date().timeIntervalSince(elapsedTime) > 2){
//                    finalText += ". "
                    var temp_text: String = ""
                    for i in count..<result.bestTranscription.segments.count-1{
                        temp_text += result.bestTranscription.segments[i].substring + " ";
                    }
                    count = result.bestTranscription.segments.count-1
//                    print(temp_text)
                    self.finalList.append(temp_text)
                    print(self.finalList)
                    print("Full Stop")
                    
//                    result = SFSpeechRecognitionResult(coder: )
                }
                elapsedTime = Date();
            }
            
            if error != nil || isFinal {
                // Stop recognizing speech if there is a problem.
                
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)

                self.recognitionRequest = nil
                self.recognitionTask = nil

                self.startStopBtn.isEnabled = true
                self.textView.text.append(". ");
                print(self.finalList)
            }
        }
        
//        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
//
//            var isFinal = false
//
//            if result != nil, let bestTranscription = result?.bestTranscription, bestTranscription.segments.count > 0 {
//                let currentSegment = bestTranscription.segments.count - 1;
//                guard currentSegment + 1 > prevCount else { return; }
//                prevCount = currentSegment + 1;
//
//                var finalText: String = "";
//                if currentSegment > 1, Date().timeIntervalSince(elapsedTime) > 1.5 {
//                    finalText += ". ";
//                }
//                elapsedTime = Date();
//
//                finalText += bestTranscription.segments[currentSegment].substring + " ";
//
//                self.textView.text += finalText
//                isFinal = (result?.isFinal)!
//            }
//
//            if error != nil || isFinal {
//                self.audioEngine.stop()
//                inputNode.removeTap(onBus: 0)
//
//                self.recognitionRequest = nil
//                self.recognitionTask = nil
//
//                self.startStopBtn.isEnabled = true
//                self.textView.text.append(". ");
//            }
//        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        textView.text = ""
        
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            startStopBtn.isEnabled = true
        } else {
            startStopBtn.isEnabled = false
        }
    }
}


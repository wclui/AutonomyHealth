//
//  TestMLStuff.swift
//  MedSafe
//
//  Created by Melody Lui on 2019-03-30.
//  Copyright © 2019 Melody Lui. All rights reserved.
//

import Foundation
import NaturalLanguage

public struct TestML{
    public static func summarize(text: String, completion: @escaping ([String: [String]]?, Error?) -> Void) {
        var sen_list = [String]()
//        print(text);
//         Split text into sentences
        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = text

        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
            sen_list.append(String(text[tokenRange]))
            return true
        }
        var prescriptions = [String]()
        var conditions = [String]()
        var management = [String]()
        var referrals = [String]()
        var tests = [String]()

        do {
            let textPredictor = try NLModel(mlModel: textClassifier().model)
            for i in 0..<sen_list.count{
                if(textPredictor.predictedLabel(for: sen_list[i])=="prescription"){
                    prescriptions.append(String(sen_list[i]))
                }
                else if(textPredictor.predictedLabel(for: sen_list[i])=="conditions"){
                    conditions.append(String(sen_list[i]))
                }
                else if(textPredictor.predictedLabel(for: sen_list[i])=="management"){
                    management.append(String(sen_list[i]))
                }
                else if(textPredictor.predictedLabel(for: sen_list[i])=="referrals"){
                    referrals.append(String(sen_list[i]))
                }
                else if(textPredictor.predictedLabel(for: sen_list[i])=="tests"){
                    tests.append(String(sen_list[i]))
                }

            }
            
        } catch let error as NSError {
            print(error)
            completion(nil,error)
            return;
        }
        
        let finalDict = ["prescriptions": prescriptions, "conditions": conditions, "management": management, "referrals": referrals, "tests":tests]
        
        completion(finalDict,nil)
    }
}

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
    public static func summarize(text: String, completion: @escaping (String?, Error?) -> Void) {
//        print(text);
//         Split text into sentences
        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = text

        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
//            print(text[tokenRange])
            return true
        }
        
    }
}

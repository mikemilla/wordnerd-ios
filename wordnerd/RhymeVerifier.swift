//
//  RhymeVerifier.swift
//  wordnerd
//
//  Created by Michael Miller on 5/16/15.
//  Copyright (c) 2015 Michael Miller. All rights reserved.
//

import Foundation

class Verify {
    
    class func crunchTheWord(generatedRhyme: NSString!, attemptedRhyme: NSString?) -> Bool {
        
        var rhymableWord = []
        var accepted:Bool
        
        switch generatedRhyme {
            
        case "word":
            rhymableWord = Word.acceptable.rhymes
        case "dope":
            rhymableWord = Dope.acceptable.rhymes
        default:
            println("Default")
            
        }
        
        println(attemptedRhyme)
        print(rhymableWord)
        
        if (rhymableWord.containsObject(attemptedRhyme!)) {
            accepted = true
        } else {
            accepted = false
        }
        
        return accepted
        
    }
    
}
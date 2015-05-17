//
//  RhymeVerifier.swift
//  wordnerd
//
//  Created by Michael Miller on 5/16/15.
//  Copyright (c) 2015 Michael Miller. All rights reserved.
//

import Foundation

class Verify {
    
    class func crunchTheWord(generatedRhyme: NSString!, attemptedRhyme: NSString?) -> Int {
        
        var rhymableWord = []
        var singles = []
        var doubles = []
        var syllables:Int = 0
        
        //var word = Word.self
        //var test = Dope()
    
        //println(word.dynamicType)
        //println(test)
        
        switch generatedRhyme {
            
        case "word":
            rhymableWord = Word.acceptable.rhymes
            singles = Word.acceptable.singles
            doubles = Word.acceptable.doubles
        case "dope":
            rhymableWord = Dope.acceptable.rhymes
            singles = Dope.acceptable.singles
            doubles = Dope.acceptable.doubles
        default:
            println("Default")
        }
        
        //println(attemptedRhyme)
        //print(rhymableWord)
        
        if (rhymableWord.containsObject(attemptedRhyme!)) {
            
            if (singles.containsObject(attemptedRhyme!)) {
                println("Single")
                syllables = 1
            } else if (doubles.containsObject(attemptedRhyme!)) {
                println("Double")
                syllables = 2
            }
            
        } else {
            syllables = 0
        }
        
        return syllables
        
    }
    
}
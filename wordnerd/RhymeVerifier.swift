//
//  RhymeVerifier.swift
//  wordnerd
//
//  Created by Michael Miller on 5/16/15.
//  Copyright (c) 2015 Michael Miller. All rights reserved.
//

import Foundation

class Verify {
    
    // Variable that are accessed in View Controller
    static var syllables = 0
    static var playedRhymes:NSMutableArray = []
    
    /*
    * Check everything to do with the rhyme
    * If it matches and so on...
    */
    class func crunchTheWord(generatedRhyme: NSString!, attemptedRhyme: NSString?) -> Int {
        
        // Instances / syllable lists
        var rhymableWord = []
        var singles = []
        var doubles = []
        var triples = []
        var quadruples = []
        var quintuples = []
        var sextuples = []
        
        /*
        * How "accepted" works:
        
            0 = neutral (most likey still entering text, never gets used below)
            1 = good (advance word and add score)
            2 = duplicate (clear text and shun them)
        
        */
        var accepted:Int = 0
        
        // Switch / Case of all words
        switch generatedRhyme {
            
        case "word":
            rhymableWord = Word.acceptable.rhymes
            singles = Word.acceptable.singles
            doubles = Word.acceptable.doubles
            break
        case "nerd":
            rhymableWord = Nerd.acceptable.rhymes
            singles = Nerd.acceptable.singles
            doubles = Nerd.acceptable.doubles
            break
        case "dope":
            rhymableWord = Dope.acceptable.rhymes
            singles = Dope.acceptable.singles
            doubles = Dope.acceptable.doubles
            break
        default:
            println("Default")
        }
        
        /*
        * It is a rhyme!
        * Now, check it!
        */
        if (playedRhymes.containsObject(attemptedRhyme!)) {
            
            // Rhyme was already used (aka Duplicate)
            accepted = 2
        } else if (rhymableWord.containsObject(attemptedRhyme!)) {
            
            // Rhyme is acceptable, divvy up some points :)
            accepted = 1
            
            // Add the word to the list of played rhymes
            playedRhymes.addObject(attemptedRhyme!)
            
            // Syllables = Point amount
            if (singles.containsObject(attemptedRhyme!)) {
                syllables = 1
            } else if (doubles.containsObject(attemptedRhyme!)) {
                syllables = 2
            }
        }
        
        // Return the value of the acceptance
        return accepted
    }
    
}
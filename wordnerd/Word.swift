//
//  Word.swift
//  wordnerd
//
//  Created by Michael Miller on 5/16/15.
//  Copyright (c) 2015 Michael Miller. All rights reserved.
//

import Foundation

class Word {
    
    struct acceptable {
        
        static var singles = [
            "turd",
            "heard",
            "nerd"]
        
        static var doubles = [
            "overheard"
        ]
        
        static var rhymes = singles + doubles
        
    }
    
}
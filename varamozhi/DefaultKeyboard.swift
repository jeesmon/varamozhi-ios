//
//  DefaultKeyboard.swift
//  TransliteratingKeyboard
//
//  Created by Alexei Baboulevitch on 7/10/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//
import UIKit

func defaultKeyboard() -> Keyboard {
    var defaultKeyboard = Keyboard()
    
    for key in ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"] {
        var keyModel = Key(.Character)
        keyModel.setLetter(key)
        defaultKeyboard.addKey(keyModel, row: 0, page: 0)
    }
    //+20141212 starting ipad
    let isPad = UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad
    if isPad {
        var backspace = Key(.Backspace)
        defaultKeyboard.addKey(backspace, row: 0, page: 0)
    }
    
    for key in ["A", "S", "D", "F", "G", "H", "J", "K", "L"] {
        var keyModel = Key(.Character)
        keyModel.setLetter(key)
        defaultKeyboard.addKey(keyModel, row: 1, page: 0)
    }
    
    var returnKey = Key(.Return)
    returnKey.uppercaseKeyCap = "return"
    returnKey.uppercaseOutput = "\n"
    returnKey.lowercaseOutput = "\n"
    if isPad {
        
        defaultKeyboard.addKey(returnKey, row: 1, page: 0)
    }
    
    var keyModel = Key(.Shift)
    defaultKeyboard.addKey(keyModel, row: 2, page: 0)
    
    for key in ["Z", "X", "C", "V", "B", "N", "M"] {
        var keyModel = Key(.Character)
        keyModel.setLetter(key)
        defaultKeyboard.addKey(keyModel, row: 2, page: 0)
    }
    
    
    if isPad {
        
        var m1 = Key(.SpecialCharacter)
        m1.uppercaseKeyCap = "!\n,"
        m1.uppercaseOutput = "!"
        m1.lowercaseOutput = ","
        defaultKeyboard.addKey(m1, row: 2, page: 0)
        
        var m2 = Key(.SpecialCharacter)
        m2.uppercaseKeyCap = "?\n."
        m2.uppercaseOutput = "?"
        m2.lowercaseOutput = "."
        defaultKeyboard.addKey(m2, row: 2, page: 0)
        
        var keyModel = Key(.Shift)
        defaultKeyboard.addKey(keyModel, row: 2, page: 0)
    }else{
        var backspace = Key(.Backspace)
        defaultKeyboard.addKey(backspace, row: 2, page: 0)
    }
    
    
    var keyModeChangeNumbers = Key(.ModeChange)
    keyModeChangeNumbers.uppercaseKeyCap = "123"
    keyModeChangeNumbers.toMode = 1
    defaultKeyboard.addKey(keyModeChangeNumbers, row: 3, page: 0)
    
    var keyboardChange = Key(.KeyboardChange)
    defaultKeyboard.addKey(keyboardChange, row: 3, page: 0)
    
    var settings = Key(.Settings)
    defaultKeyboard.addKey(settings, row: 3, page: 0)
    
    var space = Key(.Space)
    space.uppercaseKeyCap = "space"
    space.uppercaseOutput = " "
    space.lowercaseOutput = " "
    defaultKeyboard.addKey(space, row: 3, page: 0)
    
    if isPad {
        
       
        defaultKeyboard.addKey(Key(keyModeChangeNumbers), row: 3, page: 0)
        
        var dismiss = Key(.Dismiss)
        defaultKeyboard.addKey(dismiss, row: 3, page: 0)
    }else{
        defaultKeyboard.addKey(Key(returnKey), row: 3, page: 0)
    }
    
  
    
    
    for key in ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"] {
        var keyModel = Key(.SpecialCharacter)
        keyModel.setLetter(key)
        defaultKeyboard.addKey(keyModel, row: 0, page: 1)
    }
    if isPad {
        
        defaultKeyboard.addKey(Key(.Backspace), row: 0, page: 1)
    }
    
    let cl = NSLocale.currentLocale()
    let symbol: NSString? = cl.objectForKey(NSLocaleCurrencySymbol) as? NSString
    var c = "₹"
    if symbol != nil {
     
        c = symbol!
    }
    
    for key in ["-", "/", ":", ";", "(", ")", c, "&", "@"] {
        var keyModel = Key(.SpecialCharacter)
        keyModel.setLetter(key)
        defaultKeyboard.addKey(keyModel, row: 1, page: 1)
    }
    if isPad {
        
        defaultKeyboard.addKey(Key(returnKey), row: 1, page: 1)
    }else{
        
        var keyModel = Key(.SpecialCharacter)
        keyModel.setLetter("\"")
        defaultKeyboard.addKey(keyModel, row: 1, page: 1)

    }
    
    var keyModeChangeSpecialCharacters = Key(.ModeChange)
    keyModeChangeSpecialCharacters.uppercaseKeyCap = "#+="
    keyModeChangeSpecialCharacters.toMode = 2
    defaultKeyboard.addKey(keyModeChangeSpecialCharacters, row: 2, page: 1)
    
    for key in [".", ",", "?", "!", "'"] {
        var keyModel = Key(.SpecialCharacter)
        keyModel.setLetter(key)
        defaultKeyboard.addKey(keyModel, row: 2, page: 1)
    }
    
    if isPad {
        
        var keyModel = Key(.SpecialCharacter)
        keyModel.setLetter("\"")
        defaultKeyboard.addKey(keyModel, row: 2, page: 1)
        
        var keyModeChangeSpecialCharacters2 = Key(.ModeChange)
        keyModeChangeSpecialCharacters2.uppercaseKeyCap = "#+="
        keyModeChangeSpecialCharacters2.toMode = 2
        defaultKeyboard.addKey(keyModeChangeSpecialCharacters2, row: 2, page: 1)
        
    }else{
        
         defaultKeyboard.addKey(Key(.Backspace), row: 2, page: 1)
        
    }
    
   
    
    var keyModeChangeLetters = Key(.ModeChange)
    keyModeChangeLetters.uppercaseKeyCap = "ABC"
    keyModeChangeLetters.toMode = 0
    defaultKeyboard.addKey(keyModeChangeLetters, row: 3, page: 1)
    
    defaultKeyboard.addKey(Key(keyboardChange), row: 3, page: 1)
    
    defaultKeyboard.addKey(Key(settings), row: 3, page: 1)
    
    defaultKeyboard.addKey(Key(space), row: 3, page: 1)
    
    if isPad {
        defaultKeyboard.addKey(Key(keyModeChangeLetters), row: 3, page: 1)
        
        var dismiss = Key(.Dismiss)
        defaultKeyboard.addKey(dismiss, row: 3, page: 1)
    }else{
        defaultKeyboard.addKey(Key(returnKey), row: 3, page: 1)
    }
    
    
    
    for key in ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="] {
        var keyModel = Key(.SpecialCharacter)
        keyModel.setLetter(key)
        defaultKeyboard.addKey(keyModel, row: 0, page: 2)
    }
    if isPad {
        
        defaultKeyboard.addKey(Key(.Backspace), row: 0, page: 2)
    }
    
    var d = "£"
    if c == "₹" {
        c = "$"
    }else if c == "$" {
        c = "₹"
    }else{
        d = "$"
        c = "₹"
    }
    
    for key in ["_", "\\", "|", "~", "<", ">", c, d, "€"] {// ¥
        var keyModel = Key(.SpecialCharacter)
        keyModel.setLetter(key)
        defaultKeyboard.addKey(keyModel, row: 1, page: 2)
    }
    
    if isPad {
        
        defaultKeyboard.addKey(Key(returnKey), row: 1, page: 2)
    }else{
        
        var keyModel = Key(.SpecialCharacter)
        keyModel.setLetter("•")
        defaultKeyboard.addKey(keyModel, row: 1, page: 2)
        
    }
    
    defaultKeyboard.addKey(Key(keyModeChangeNumbers), row: 2, page: 2)
    
    for key in [".", ",", "?", "!", "'"] {
        var keyModel = Key(.SpecialCharacter)
        keyModel.setLetter(key)
        defaultKeyboard.addKey(keyModel, row: 2, page: 2)
    }
    
    if isPad {
        
        var keyModel = Key(.SpecialCharacter)
        keyModel.setLetter("\"")
        defaultKeyboard.addKey(keyModel, row: 2, page: 2)
        
        defaultKeyboard.addKey(Key(keyModeChangeNumbers), row: 2, page: 2)
        
    }else{
        
        defaultKeyboard.addKey(Key(.Backspace), row: 2, page: 2)
        
    }
    
   
    
    defaultKeyboard.addKey(Key(keyModeChangeLetters), row: 3, page: 2)
    
    defaultKeyboard.addKey(Key(keyboardChange), row: 3, page: 2)
    
    defaultKeyboard.addKey(Key(settings), row: 3, page: 2)
    
    defaultKeyboard.addKey(Key(space), row: 3, page: 2)
    
    if isPad {
        defaultKeyboard.addKey(Key(keyModeChangeLetters), row: 3, page: 2)
        
        var dismiss = Key(.Dismiss)
        defaultKeyboard.addKey(dismiss, row: 3, page: 2)
    }else{
        defaultKeyboard.addKey(Key(returnKey), row: 3, page: 2)
    }
    
    
    
    return defaultKeyboard
}

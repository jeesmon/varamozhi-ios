//
//  DefaultKeyboard.swift
//  TransliteratingKeyboard
//
//  Created by Alexei Baboulevitch on 7/10/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//
import UIKit

func defaultKeyboard() -> Keyboard {
    let defaultKeyboard = Keyboard()
    
    for key in ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"] {
        let keyModel = Key(.character)
        keyModel.setLetter(key)
        defaultKeyboard.addKey(keyModel, row: 0, page: 0)
    }
    //+20141212 starting ipad
    let isPad = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
    if isPad {
        let backspace = Key(.backspace)
        defaultKeyboard.addKey(backspace, row: 0, page: 0)
    }
    
    for key in ["A", "S", "D", "F", "G", "H", "J", "K", "L"] {
        let keyModel = Key(.character)
        keyModel.setLetter(key)
        defaultKeyboard.addKey(keyModel, row: 1, page: 0)
    }
    
    let returnKey = Key(.return)
    returnKey.uppercaseKeyCap = "return"
    returnKey.uppercaseOutput = "\n"
    returnKey.lowercaseOutput = "\n"
    if isPad {
        
        defaultKeyboard.addKey(returnKey, row: 1, page: 0)
    }
    
    let keyModel = Key(.shift)
    defaultKeyboard.addKey(keyModel, row: 2, page: 0)
    
    for key in ["Z", "X", "C", "V", "B", "N", "M"] {
        let keyModel = Key(.character)
        keyModel.setLetter(key)
        defaultKeyboard.addKey(keyModel, row: 2, page: 0)
    }
    
    
    if isPad {
        
        let m1 = Key(.specialCharacter)
        m1.uppercaseKeyCap = "!\n,"
        m1.uppercaseOutput = "!"
        m1.lowercaseOutput = ","
        defaultKeyboard.addKey(m1, row: 2, page: 0)
        
        let m2 = Key(.specialCharacter)
        m2.uppercaseKeyCap = "?\n."
        m2.uppercaseOutput = "?"
        m2.lowercaseOutput = "."
        defaultKeyboard.addKey(m2, row: 2, page: 0)
        
        let keyModel = Key(.shift)
        defaultKeyboard.addKey(keyModel, row: 2, page: 0)
    }else{
        let backspace = Key(.backspace)
        defaultKeyboard.addKey(backspace, row: 2, page: 0)
    }
    
    
    let keyModeChangeNumbers = Key(.modeChange)
    keyModeChangeNumbers.uppercaseKeyCap = "123"
    keyModeChangeNumbers.toMode = 1
    defaultKeyboard.addKey(keyModeChangeNumbers, row: 3, page: 0)
    
    let keyboardChange = Key(.keyboardChange)
    defaultKeyboard.addKey(keyboardChange, row: 3, page: 0)
    
    //let settings = Key(.Settings)
    //defaultKeyboard.addKey(settings, row: 3, page: 0)
    
    let tildeModel = Key(.specialCharacter)
    tildeModel.setLetter("~")
    defaultKeyboard.addKey(tildeModel, row: 3, page: 0)

    
    let space = Key(.space)
    space.uppercaseKeyCap = "space"
    space.uppercaseOutput = " "
    space.lowercaseOutput = " "
    defaultKeyboard.addKey(space, row: 3, page: 0)
    
    
    let usModel = Key(.specialCharacter)
    usModel.setLetter("_")
    defaultKeyboard.addKey(usModel, row: 3, page: 0)
    
    if isPad {
        
       
        defaultKeyboard.addKey(Key(keyModeChangeNumbers), row: 3, page: 0)
        
        let dismiss = Key(.dismiss)
        defaultKeyboard.addKey(dismiss, row: 3, page: 0)
    }else{
        defaultKeyboard.addKey(Key(returnKey), row: 3, page: 0)
    }
    
  
    
    
    for key in ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"] {
        let keyModel = Key(.specialCharacter)
        keyModel.setLetter(key)
        defaultKeyboard.addKey(keyModel, row: 0, page: 1)
    }
    if isPad {
        
        defaultKeyboard.addKey(Key(.backspace), row: 0, page: 1)
    }
    
    let cl = Locale.current
    let symbol: NSString? = (cl as NSLocale).object(forKey: NSLocale.Key.currencySymbol) as? NSString
    var c = "₹"
    if symbol != nil {
     
        c = symbol! as String
    }
    
    for key in ["-", "/", ":", ";", "(", ")", c, "&", "@"] {
        let keyModel = Key(.specialCharacter)
        keyModel.setLetter(key)
        defaultKeyboard.addKey(keyModel, row: 1, page: 1)
    }
    if isPad {
        
        defaultKeyboard.addKey(Key(returnKey), row: 1, page: 1)
    }else{
        
        let keyModel = Key(.specialCharacter)
        keyModel.setLetter("\"")
        defaultKeyboard.addKey(keyModel, row: 1, page: 1)

    }
    
    let keyModeChangeSpecialCharacters = Key(.modeChange)
    keyModeChangeSpecialCharacters.uppercaseKeyCap = "#+="
    keyModeChangeSpecialCharacters.toMode = 2
    defaultKeyboard.addKey(keyModeChangeSpecialCharacters, row: 2, page: 1)
    
    for key in [".", ",", "?", "!", "'"] {
        let keyModel = Key(.specialCharacter)
        keyModel.setLetter(key)
        defaultKeyboard.addKey(keyModel, row: 2, page: 1)
    }
    
    if isPad {
        
        let keyModel = Key(.specialCharacter)
        keyModel.setLetter("\"")
        defaultKeyboard.addKey(keyModel, row: 2, page: 1)
        
        let keyModeChangeSpecialCharacters2 = Key(.modeChange)
        keyModeChangeSpecialCharacters2.uppercaseKeyCap = "#+="
        keyModeChangeSpecialCharacters2.toMode = 2
        defaultKeyboard.addKey(keyModeChangeSpecialCharacters2, row: 2, page: 1)
        
    }else{
        
         defaultKeyboard.addKey(Key(.backspace), row: 2, page: 1)
        
    }
    
   
    
    let keyModeChangeLetters = Key(.modeChange)
    keyModeChangeLetters.uppercaseKeyCap = "ABC"
    keyModeChangeLetters.toMode = 0
    defaultKeyboard.addKey(keyModeChangeLetters, row: 3, page: 1)
    
    defaultKeyboard.addKey(Key(keyboardChange), row: 3, page: 1)
    
    //defaultKeyboard.addKey(Key(settings), row: 3, page: 1)
    
    defaultKeyboard.addKey(Key(space), row: 3, page: 1)
    
    if isPad {
        defaultKeyboard.addKey(Key(keyModeChangeLetters), row: 3, page: 1)
        
        let dismiss = Key(.dismiss)
        defaultKeyboard.addKey(dismiss, row: 3, page: 1)
    }else{
        defaultKeyboard.addKey(Key(returnKey), row: 3, page: 1)
    }
    
    
    
    for key in ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="] {
        let keyModel = Key(.specialCharacter)
        keyModel.setLetter(key)
        defaultKeyboard.addKey(keyModel, row: 0, page: 2)
    }
    if isPad {
        
        defaultKeyboard.addKey(Key(.backspace), row: 0, page: 2)
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
        let keyModel = Key(.specialCharacter)
        keyModel.setLetter(key)
        defaultKeyboard.addKey(keyModel, row: 1, page: 2)
    }
    
    if isPad {
        
        defaultKeyboard.addKey(Key(returnKey), row: 1, page: 2)
    }else{
        
        let keyModel = Key(.specialCharacter)
        keyModel.setLetter("•")
        defaultKeyboard.addKey(keyModel, row: 1, page: 2)
        
    }
    
    defaultKeyboard.addKey(Key(keyModeChangeNumbers), row: 2, page: 2)
    
    for key in [".", ",", "?", "!", "'"] {
        let keyModel = Key(.specialCharacter)
        keyModel.setLetter(key)
        defaultKeyboard.addKey(keyModel, row: 2, page: 2)
    }
    
    if isPad {
        
        let keyModel = Key(.specialCharacter)
        keyModel.setLetter("\"")
        defaultKeyboard.addKey(keyModel, row: 2, page: 2)
        
        defaultKeyboard.addKey(Key(keyModeChangeNumbers), row: 2, page: 2)
        
    }else{
        
        defaultKeyboard.addKey(Key(.backspace), row: 2, page: 2)
        
    }
    
   
    
    defaultKeyboard.addKey(Key(keyModeChangeLetters), row: 3, page: 2)
    
    defaultKeyboard.addKey(Key(keyboardChange), row: 3, page: 2)
    
    //defaultKeyboard.addKey(Key(settings), row: 3, page: 2)
    
    defaultKeyboard.addKey(Key(space), row: 3, page: 2)
    
    if isPad {
        defaultKeyboard.addKey(Key(keyModeChangeLetters), row: 3, page: 2)
        
        let dismiss = Key(.dismiss)
        defaultKeyboard.addKey(dismiss, row: 3, page: 2)
    }else{
        defaultKeyboard.addKey(Key(returnKey), row: 3, page: 2)
    }
    
    
    
    return defaultKeyboard
}

//
//  DefaultKeys.swift
//  RubberDucking
//
//  Created by Cameron T on 8/2/18.
//  Copyright © 2018 Cameron T. All rights reserved.
//

import Foundation
import Cocoa

//Allows access to the myDuck AppDelegate across files
    //This lets users access functions in the AppDelegate
let myDuck = NSApp.delegate as! AppDelegate

//File that contains user-set duck image
let fileName = "user_duck.png"

//UserDefault Keys
let defaults = UserDefaults.standard
let startupKey = "Load_On_Start"
let silenceKey = "Silencer"

    //Checks User Default keys to verify whether they exist
func isKeyPresentInUserDefaults(key: String) -> Bool {
    return UserDefaults.standard.object(forKey: key) != nil
}

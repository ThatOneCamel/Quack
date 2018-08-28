//
//  PreferenceViewController.swift
//  RubberDucking
//
//  Created by Cameron T on 8/2/18.
//  Copyright © 2018 Cameron T. All rights reserved.
//

import Cocoa

class PreferenceViewController: NSViewController {

    @IBOutlet weak var startupCheckbox: NSButton!
    @IBOutlet weak var silenceCheckbox: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        //If key is present, set state of checkbox accordingly to that key's boolean value
        if isKeyPresentInUserDefaults(key: startupKey){
            setButtonState(button: startupCheckbox, defaultsValue: defaults.bool(forKey: startupKey))
        }
        
        if isKeyPresentInUserDefaults(key: silenceKey) {
            setButtonState(button: silenceCheckbox, defaultsValue: defaults.bool(forKey: silenceKey))
        }
        
        print("Preferences View Loaded Successfully")
        
    }
    
    func setKeyValue(value: Bool, key: String) {
        defaults.set(value, forKey: key)
    }
    
    //Sets initial checkbox state [checked or unchecked]
    func setButtonState(button: NSButton, defaultsValue: Bool){
        button.state = defaultsValue ? .on : .off
    }
    
    //OnClick functions: Send the button's new state and the corresponding key to togglePreferences()
    @IBAction func toggleStartup(_ sender: NSButton) {
        togglePreferences(sender, senderKey: startupKey)
    }
    
    @IBAction func toggleSilence(_ sender: NSButton) {
        togglePreferences(sender, senderKey: silenceKey)
        myDuck.silenceDuck(sender)
        
    }
    
    func togglePreferences(_ sender: NSButton, senderKey: String){
        switch (sender.state){
        case .on:
            print("Turned on", senderKey)
            setKeyValue(value: true, key: senderKey)
            break
            
        case .off:
            print("Turned off", senderKey)
            setKeyValue(value: false, key: senderKey)
            break
            
        default:
            break
        }
    }
    
}//End PreferenceViewController class

extension PreferenceViewController {
    //Storyboard instantiation
    static func newController() -> PreferenceViewController {
        //1.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        //2. Scene Identifier; coincides with Storyboard ID
        let identifier = NSStoryboard.SceneIdentifier("DuckPreferences")
        
        //3. Instantiation
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? PreferenceViewController else {
            fatalError("Can't find Preference - Check Main.storyboard Identity Inspector")
        }
        return viewcontroller
    }
    
}

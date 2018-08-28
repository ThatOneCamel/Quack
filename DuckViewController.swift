//
//  DuckViewController.swift
//  RubberDucking
//
//  Created by Cameron T on 7/18/18.
//  Copyright © 2018 Cameron T. All rights reserved.
//

import Cocoa

class DuckViewController: NSViewController {
    
    @IBOutlet weak var duckImageButton: NSButton!
    @IBOutlet weak var testButton: NSButton!
    
    @IBOutlet weak var duckNameField: NSTextField!
    @IBOutlet weak var duckDescriptiveText: NSTextField!
    @IBOutlet weak var duckTimeInput: NSTextField!
    
    
    let documentsDirectory =
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        //Referencing customizable objects in AppDelegate so they can be reset if needed
        myDuck.duck.setTextField(textField: duckDescriptiveText)
        myDuck.duck.setNameField(nameField: duckNameField)
        myDuck.duck.setImageButton(imgButton: duckImageButton)
        
        //Checks to see if the user has a custom duck image
        checkIfDuckExists()
        
        //Checks to see if the user has assigned their duck a name
        if isKeyPresentInUserDefaults(key: "Input_Name"){
            duckNameField.stringValue = defaults.string(forKey: "Input_Name")!
        }
        
        myDuck.setDuckImage(newImage: duckImageButton.image!)

    }
    
    //Checks app sandbox 'Documents' folder to see if there is an existing duck image
    func checkIfDuckExists(){
        let path = NSHomeDirectoryForUser(NSUserName())! + "/Documents/" + fileName
        //Issue before: URL was returning as an optional and therefore not reading files
        let myURL = URL.init(fileURLWithPath: path)
        
        if FileManager.default.fileExists(atPath: path){
            let archiveURL = documentsDirectory.appendingPathComponent(fileName)
            print("myURL =", myURL, "\n archiveURL =", archiveURL)
            // print("Path is ", NSHomeDirectoryForUser(NSUserName())! + "/Documents/user_duck.png")
            duckImageButton.image = NSImage(contentsOf: myURL)
        }
    }
    
    //Saves user's image to sandbox Documents folder
    func saveImageToDocuments(image: NSImage){
        let archiveURL = documentsDirectory.appendingPathComponent(fileName)
        do {
            try image.tiffRepresentation?.write(to: archiveURL)
        } catch {
            print("Failed attempt to write to:", archiveURL)
        }
        
    }
    
    //Opens a file selection modal when user clicks on duck image
    @IBAction func imageChoiceDialog(_ sender: Any) {
        let dialog = NSOpenPanel()
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = false
        dialog.allowedFileTypes = ["png", "jpg", "gif"]
        
        //If a file was selected and OK was pressed
        if (dialog.runModal() == NSApplication.ModalResponse.OK){
            let result = NSImage(contentsOf: dialog.url!)
            //let resultExtension = String(dialog.url!.pathExtension)
            //print("extension is:", resultExtension)
            
            //Sets button image in the DuckViewController
            duckImageButton.image = result
            
            saveImageToDocuments(image: result!)
            
            //Sets notification secondary image
            myDuck.setDuckImage(newImage: duckImageButton.image!)
            myDuck.showPopover(sender: duckImageButton.image)

        } else {
            //If user did not select a file
            myDuck.showPopover(sender: nil)
        }
        //Assigns some random flavor text
        myDuck.duck.setFlavorText()
        
    }
    
    //Button action allows users to preview what their notifications will look like
    @IBAction func testDuck(_ sender: Any) {
        myDuck.startNotification(titleString: "This is a test", msg: "This is what your notification will look like", minutes : -1)
        myDuck.closePopover(sender: testButton)
        myDuck.duck.setFlavorText()

    }
    
    
    @IBAction func setupDuck(_ sender: Any){
        //Input has to be a valid number, has to be 'reasonable' [preventing overflow & integer conversion errors], and has to be positive
            //2880 minutes is equivalent to 48 hours
        if var min = Double(duckTimeInput.stringValue), min >= 0, min <= 2880{
            
            min *= 60
            
            let userDuckName = duckNameField.stringValue
            //Nested If-Else
            if(userDuckName.isEmpty) || (userDuckName.count > BC_STRING_MAX){
                myDuck.startNotification(titleString: "Your duck is ready to chat", msg: "Your duck wants to hear all about your project", minutes : min)
                
            } else {
                defaults.set(userDuckName, forKey: "Input_Name")
                myDuck.startNotification(titleString: userDuckName + " would like to talk", msg: "Chat with " + userDuckName + "?", minutes : min)
            }//End Nested If-Else
            
            //myDuck.closePopover(sender: testButton)
            //setFlavorText()
            if(min == 0){
                duckDescriptiveText.stringValue = "Great, in 30 minute(s) your duck will be ready to chat"
            } else {
                duckDescriptiveText.stringValue = "Great, in \(Int(min / 60)) minute(s) your duck will be ready to chat"
            }
            
        } else {
            invalidInputAlert()
        }//End If-Else
        
    }
    
    //Called if invalid input is detected in the duckMinutes field
    func invalidInputAlert(){
        let alert = NSAlert()
        alert.messageText = "Invalid Time Input"
        alert.informativeText = "There are invalid characters in your input, please enter positive numbers [0-9] only"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    //DEBUG: Currently broken stopwatch
    /*@IBAction func getTime(_ sender: Any) {
        myDuck.checkRemainingTime(timeLabel: duckTimeDisplay)
    }*/
    
    
}//End of DuckViewController class

extension DuckViewController {
    //Storyboard instantiation
    static func newController() -> DuckViewController {
        //1.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        //2. Scene Identifier; coincides with Storyboard ID
        let identifier = NSStoryboard.SceneIdentifier("DuckViewController")
        
        //3. Instantiation
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? DuckViewController else {
            fatalError("Can't find DuckViewController - Check Main.storyboard Identity Inspector")
        }
        return viewcontroller
    }
    
}

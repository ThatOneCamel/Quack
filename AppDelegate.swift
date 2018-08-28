//
//  AppDelegate.swift
//  RubberDucking
//
//  Created by Cameron T. on 7/17/18.
//  Copyright © 2018 Cameron T. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate{
    
    //Declares duckInfo class instance
    var duck: duckInfo!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        //Initializing class instance, creating menu bar and assigning delegate to handle notifications
        self.duck = duckInfo()
        duck.createMenu()
        duck.notificationCenter.delegate = self
        
        //Checking if silence key exists, then sets the sound corresponding to user's preference
        if isKeyPresentInUserDefaults(key: silenceKey){
            duck.initializeSound(silenced: defaults.bool(forKey: silenceKey))
        }
        
        print("Finished AppDelegate")

    }
    
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        duck.clear()
    }
    
    
    //Called when a notification is being set up
    func startNotification(titleString: String, msg: String, minutes: Double){
        //duck.clear()
        duck.setText(title: titleString, body: msg)
        duck.setTime(time: minutes)

    }
    
    func restartNotification(oldNotification: NSUserNotification){
        if duck.repeatIntervalValue == -1 {
            //Do Nothing, this notification should not be triggered [-1 is for test notifications]
        } else {
            duck.notificationCenter.scheduleNotification(oldNotification)
            print("Old notification scheduled")
        }
        
    }
    
    
    //DEBUG FUNCTION
    func checkRemainingTime(timeLabel: NSTextField){
        /*let schedule = duck.notificationCenter.scheduledNotifications

        if(!schedule.isEmpty){
            
            
            let format = DateFormatter()
            format.dateFormat = "hh:mm:ss"
            //format.locale = Locale(identifier: "en_US_POSIX")
            print("There are", schedule.count, "notifications in queue")
            //print("The soonest notification will occur at:", schedule[0].deliveryDate!.description(with: format.locale))
            timeLabel.stringValue = "Next notification: " + schedule[0].deliveryDate!.description(with: format.locale)
        } else {
            print("There are no notifications scheduled at the moment")
            timeLabel.stringValue = "There are no notifications scheduled at the moment"
        }*/
        //duck.checkTimer()
        
    }
    
    //Changes the image of the user's 'in-notification' duck
    func setDuckImage(newImage: NSImage){
        duck.notification.contentImage = newImage
    }
    
    //Sets notification to appear regardless whether the application window is in focus or not
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    
    //Allows user to click on the notification and its action buttons
    //Note: This means that by default, I have set all notifications to be "alerts"
    //If the user would prefer banners, they can change it using system preferences where the function is nearly the same
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification){
        
        switch (notification.activationType) {
            //When notification is clicked, all delivered notifications are removed and
                // DuckViewController is shown
            case .contentsClicked:
                showPopover(sender: 0)
                duck.clearDelivered()
                break

            case .actionButtonClicked:
                showPopover(sender: 0)
                duck.clearDelivered()
                break
            default:
                break
            }
        
    }
    
    //If Popover is currently on screen, it will be closed, otherwise it will be opened
    @objc func togglePopover(_ sender: Any?) {
        duck.menuPopover.isShown ? closePopover(sender: sender) : showPopover(sender: sender)

        /*if duck.menuPopover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }*/
    }
    
    func showPopover(sender: Any?) {
        if let button = duck.statusItem.button {
            //Every time the view controller is shown, a random flavor text will be applied
            duck.setFlavorText()
            duck.menuPopover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
        
    }
    
    func closePopover(sender: Any?) {
        duck.menuPopover.performClose(sender)
    }
    
    //Toggle: Enabled - Removes scheduled notifications; Disabled - Sets up the old notification
    //NOTE: This is the MANUAL silence toggle
    @objc func silenceDuck(_ sender: NSButton){
        
        duck.notification.soundName = (sender.state == .off) ? NSUserNotificationDefaultSoundName : nil

        /*if (sender.state == .off) {
            //Sound enabled
            duck.notification.soundName = NSUserNotificationDefaultSoundName
            
        } else {
            //Silence enabled
            duck.notification.soundName = nil
            

        }*/

        duck.clear()
        restartNotification(oldNotification: duck.notification)
        
    }
    
    @objc func stopDuckNotifications(_ sender: Any?){
        duck.clear()
    }
    
    //Deletes and resets user_duck image, wipes duck name, and clears scheduled notifications
    @objc func resetDuck(_ sender: Any?){
        let fileManager = FileManager.default

        do {
            //Setting string
            defaults.set("", forKey: "Input_Name")

            duck.duckNameField.stringValue = ""
            duck.duckImageButton.image = NSImage(named: "defaultDuck")
            setDuckImage(newImage: duck.duckImageButton.image!)
            duck.clear()
            try fileManager.removeItem(atPath: NSHomeDirectoryForUser(NSUserName())! +
                "/Documents/user_duck.png")
            
        } catch let error as NSError {
            print("File not found: \(error)")
        }
        
    }
    
    //Menu button, visits website
    @objc func visitSite(_ sender: Any?){
        if let duckURL = URL(string: "https://youtube.com"){
            //Opens URL in default web-browser
            NSWorkspace.shared.open(duckURL)
        }
        
    }
    
    //Menu button, displays information about the application
    @objc func openAppInfo(_ sender: Any?){
        let about = NSAlert()
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        about.alertStyle = .informational
        about.messageText = "Rubber Ducking v\(version)"
        about.informativeText = "An application created by EFX, 2018. This application is provided free of charge.\nVisit our website at https://www.youtube.com for more information."
        about.runModal()
    }
    
    //Function to allow user to specify what task they want to accomplish (optional)
    /*@objc func inputTaskText(_sender: Any?){
        let task = NSAlert()
        task.alertStyle = .informational
        
    }*/
    
    @objc func showPreferences(_ sender: Any?){
        duck.myWindow?.makeKeyAndOrderFront(self)
        duck.vc.isWindowLoaded ? NSApp.activate(ignoringOtherApps: true) : duck.vc.showWindow(self)

        
        /*if duck.vc.isWindowLoaded {
            //Bring preferences window to front if there is a window open
            NSApp.activate(ignoringOtherApps: true)
        } else {
            //Display preferences window
            duck.vc.showWindow(self)
        }*/
        
        
    }
    
    
}//End of AppDelegate class

//Class that contains all of the duck setup
class duckInfo{
    
    //Constructor
    init(){
        
        //Sound will be initialized using the PreferenceViewController
        //notification.soundName = NSUserNotificationDefaultSoundName
        notification.hasActionButton = true
        notification.otherButtonTitle = "Ignore"
        notification.actionButtonTitle = "Let's Talk"
        
        //Sets menu bar icon
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("StatusBarButtonImage"))
            //button.action = #selector(sendToConsole)
            //button.action = #selector(togglePopover(_:))
        }
        
        //Makes ViewController close when clicked off of
        menuPopover.behavior = NSPopover.Behavior.transient
        //Assigns the menu popover to the DuckViewController
        menuPopover.contentViewController = DuckViewController.newController()
        
        prefController = storyboard.instantiateController(withIdentifier: "DuckPreferences") as! PreferenceViewController
        
        myWindow = NSWindow(contentViewController: prefController)
        myWindow?.standardWindowButton(NSWindow.ButtonType.miniaturizeButton)?.isHidden = true
        myWindow?.standardWindowButton(NSWindow.ButtonType.zoomButton)?.isHidden = true
        myWindow?.styleMask.remove(.resizable)

        vc = NSWindowController(window: myWindow)
        
        initializeFlavors()
        print("Initialized Duck")
        
    } //End init
    
    //Reference to the informative text view
    func setTextField(textField: NSTextField){
        duckText = textField
    }
    
    //Reference to duck name field
    func setNameField(nameField: NSTextField){
        duckNameField = nameField
    }
    
    //Reference to duck image button
    func setImageButton(imgButton: NSButton){
        duckImageButton = imgButton
    }
    
    //Sets notification title and body
    func setText(title: String, body: String){
        notification.title = title
        notification.informativeText = body
    }
    
    //Picks a random flavor-text to display
    func setFlavorText(){
        duckText.stringValue = flavors.randomElement()!
    }
    
    //Sets how often notifications will repeat
    func setTime(time: Double){
        switch(time) {
        // -1 used for testing notifications; it will not repeat
        case -1:
            notification.deliveryRepeatInterval = nil
            setDeliveryDate(time: time)
            break
            
        // 0 will set repeat interval to 30 minutes
        case 0:
            notification.deliveryRepeatInterval = DateComponents.init(minute: 30)
            setDeliveryDate(time: 30)
            //remainingTime = 30
            //setupTimer()
            break
            
        // User's input time will determine repeat interval
        default:
            //Time is converted to seconds because it was converted earlier
            notification.deliveryRepeatInterval = DateComponents.init(second: Int(time))
            setDeliveryDate(time: time)
            //remainingTime = time
            //setupTimer()
        }
        repeatIntervalValue = time
    }
    
    //Schedules when the first notification will be delivered
    func setDeliveryDate(time: Double){
        if notificationCenter.scheduledNotifications.count > 0{
            clear()
        }
        notification.deliveryDate = NSDate(timeIntervalSinceNow: time) as Date
        notification.deliveryTimeZone = TimeZone.current
        notificationCenter.scheduleNotification(notification)
        
        //DEBUG
        print("There's", notificationCenter.scheduledNotifications.count, "notifications in the queue")
        
       /* print("Time until next delivery:::")
        let date = Date()
        let cal = Calendar.current
        let minutes = cal.component(.minute, from: date)
        notificationCenter.scheduledNotifications.first?.deliveryDate!.compare(date)*/
    }
    
    //Removes both delivered and in-progress/scheduled notifications
    func clear(){
        notificationCenter.removeAllDeliveredNotifications()
        notificationCenter.scheduledNotifications.removeAll()
        print("All pending notifications removed")
    }
    
    //Removes only delivered notifications, in an effort to clear up clutter
    func clearDelivered(){
        notificationCenter.removeAllDeliveredNotifications()
    }
    
    //Creates the menu items that show when clicking on the app icon in the menu bar (the top bar)
    func createMenu(){
        let duckMenu = NSMenu()
        
        duckMenu.addItem(NSMenuItem(title: "Show Duck", action: #selector(AppDelegate.togglePopover(_:)), keyEquivalent: ""))
        duckMenu.addItem(NSMenuItem(title: "Preferences...", action: #selector(AppDelegate.showPreferences(_:)), keyEquivalent: ""))
        duckMenu.addItem(NSMenuItem.separator())
        
        duckMenu.addItem(NSMenuItem(title: "Stop Notifications", action: #selector(AppDelegate.stopDuckNotifications(_:)), keyEquivalent: ""))
        //duckMenu.addItem(NSMenuItem(title: "Silence", action: #selector(AppDelegate.silenceDuck(_:)), keyEquivalent: ""))
        duckMenu.addItem(NSMenuItem(title: "Reset Duck", action: #selector(AppDelegate.resetDuck(_:)), keyEquivalent: ""))
        duckMenu.addItem(NSMenuItem.separator())
        
        duckMenu.addItem(NSMenuItem(title: "Visit Website", action: #selector(AppDelegate.visitSite(_:)), keyEquivalent: ""))
        duckMenu.addItem(NSMenuItem(title: "About", action: #selector(AppDelegate.openAppInfo(_:)), keyEquivalent: ""))
        duckMenu.addItem(NSMenuItem.separator())
        
        duckMenu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: ""))
        
        statusItem.menu = duckMenu
        
    }
    
    //Initializes sound on application start
    func initializeSound(silenced: Bool){
        notification.soundName = silenced ? nil : NSUserNotificationDefaultSoundName
    }
    
    //Initialization of flavor text
    func initializeFlavors(){
        flavors.append("We are not responsible if you come off as a crazy person talking to your computer")
        flavors.append("What kind of project are you making?")
        flavors.append("I enjoy talking to you a lot, we should do this more often!")
        flavors.append("I'd suggest using headphones when talking to me. Y'know, so that people think you're in a call")
        flavors.append("Shouldn't you be {insert task here} right now...? I won't judge")
        flavors.append("How's your day going so far?")
        flavors.append("Was there something you wanted to talk about?")
        flavors.append("Please don't leave me alone too long, I could die from loneliness you know...")
    }
    
    //Notification information, and the notification center which handles message delivery
    let notification = NSUserNotification()
    let notificationCenter = NSUserNotificationCenter.default
    var repeatIntervalValue: Double = -1
    
    //DuckViewController object references
    var duckText = NSTextField()
    var duckNameField = NSTextField()
    var duckImageButton = NSButton()
    
    //Menu bar icon and items
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    let menuPopover = NSPopover()
    
    //Preferences View
    var myWindow: NSWindow? = nil
    let storyboard = NSStoryboard(name: "Main",bundle: nil)
    var prefController = PreferenceViewController()

    var vc = NSWindowController()
    
    //Flavor text array
    var flavors = [String]()

    
}

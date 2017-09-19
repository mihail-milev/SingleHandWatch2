//
//  InterfaceController.swift
//  SingleHandWatch2 WatchKit Extension
//
//  Created by Mihail Milev on 17.09.17.
//  Copyright © 2017 Mihail Milev. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    
    @IBOutlet var timeScroller : WKInterfaceImage?
    
    var syncTimerObj : Timer?
    var fireTimerObj : Timer?

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        let extDelegate = WKExtension.shared().delegate as? ExtensionDelegate
        if let delegate = extDelegate {
            while(delegate.img == nil) { }
            guard let tScr : WKInterfaceImage = timeScroller else {
                return
            }
            tScr.setImage(delegate.img)
            syncTimerObj = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.syncTimer), userInfo: nil, repeats: true)
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        if let fTO : Timer = fireTimerObj {
            fTO.invalidate()
            fireTimerObj = nil
        }
        
        if let sTO : Timer = syncTimerObj {
            sTO.invalidate()
            syncTimerObj = nil
        }
    }
    
    func syncTimer(sender:Timer) {
        let date : Date = Date()
        let calendar : Calendar = Calendar.current
        let second : Int = calendar.component(.second, from: date)
        
        if(second == 0) {
            doStuff(sender: sender)
            fireTimerObj = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.doStuff), userInfo: nil, repeats: true)
            sender.invalidate()
        }
    }
    
    func doStuff(sender:Timer) {
        guard let tScr : WKInterfaceImage = timeScroller else {
            return
        }
        let lib : ClockLibrary = ClockLibrary.init()
        tScr.setImage(lib.getWholeImage())
    }

}

//
//  ClockLibrary.swift
//  SingleHandWatch2
//
//  Created by Mihail Milev on 17.09.17.
//  Copyright © 2017 Mihail Milev. All rights reserved.
//

import Foundation
import UIKit

class ClockLibrary {
    private let angleInLimits : Double = 10.0
    
    func getWholeImage() -> UIImage? {
        let date : Date = Date.init()
        
        let dateFormatter : DateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "mm"
        let minutes : Int = Int.init(dateFormatter.string(from: date))!
        dateFormatter.dateFormat = "HH"
        let hours : Int = Int.init(dateFormatter.string(from: date))!
        
        let angle : Double = (Double(hours) * 60.0 + Double(minutes)) * 360.0 / (24.0 * 60.0)
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width:312, height:312), false, 1.0)
        
        guard let context : CGContext = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        
        drawArrow(inContext: context, atAngle: angle)
        drawDateWeek(inContext: context, curAngle: angle)
        
        var angleCounter : Double = 0.0
        for i in 0...102 {
            context.setFillColor(UIColor.white.cgColor)
            if(checkAgainstAngleCounter(ifWeAreInLimits: angleCounter, angle)) {
                if(checkAgainstAngleCounter(ifWeShouldShift: angleCounter, angle)) {
                    context.rotate (by: CGFloat(3.0 * (angleCounter - angle) * .pi / 180.0))
                }
                drawLinesAndDots(atPos: i, forContext: context)
                if(checkAgainstAngleCounter(ifWeShouldShift: angleCounter, angle)) {
                    context.rotate (by: CGFloat(3.0 * (angle - angleCounter) * .pi / 180.0))
                }
            }
            context.rotate (by: CGFloat(3.75 * .pi / 180.0))
            angleCounter += 3.75
        }
        context.rotate (by: CGFloat(3.75 * .pi / 180.0));
        
        let finimg : UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return finimg
    }
    
    private func drawLinesAndDots(atPos i : Int, forContext context : CGContext) {
        if(i % 4 == 0) {
            if((i == 0) || (i == 24) || (i == 48) || (i == 72) || (i == 96)) {
                context.setFillColor(UIColor.init(red: 227.0/255.0, green: 162.0/255.0, blue: 56.0/255.0, alpha: 1.0).cgColor)
                context.fill(CGRect(x: -4, y: 76, width: 8, height: 80))
            } else {
                context.fill(CGRect(x: -4, y: 96, width: 8, height: 60))
            }
            drawClockNumber(inContext: context, theText: "\(i/4)")
        } else if((i % 4 == 1) || (i % 4 == 3)) {
            context.fillEllipse(in: CGRect(x: -8, y: 140, width: 16, height: 16))
        } else {
            context.fill(CGRect(x: -3, y: 116, width: 6, height: 40))
        }
    }
    
    private func checkAgainstAngleCounter(ifWeAreInLimits angleCounter : Double, _ angle : Double) -> Bool {
        if(angleCounter > angle - angleInLimits && angleCounter < angle + angleInLimits) {
            return true
        } else {
            return false
        }
    }
    
    private func checkAgainstAngleCounter(ifWeShouldShift angleCounter : Double, _ angle : Double) -> Bool {
        if((angleCounter > angle - angleInLimits && angleCounter < angle) || (angleCounter < angle + angleInLimits && angleCounter > angle)) {
            return true
        } else {
            return false
        }
    }

    private func drawArrow(inContext context : CGContext, atAngle angle : Double) {
        context.translateBy (x: 156, y: 156)
        context.rotate(by: CGFloat(.pi * angle / 180.0))
        
        context.setFillColor(UIColor.orange.cgColor)
        context.fill(CGRect(x: -1.0, y: 0.0, width: 2.0, height: 312.0))
        context.fill(CGRect(x: -1.0, y: 0.0, width: 2.0, height: -60.0))
        
        context.rotate(by: CGFloat(-1.0 * .pi * angle / 180.0))
    }
    
    private func drawDateWeek(inContext context : CGContext, curAngle angle : Double) {
        context.saveGState()
        
        context.translateBy (x: -156, y: -156)
        let affine : CGAffineTransform = CGAffineTransform.init(a: 1.0, b: 0.0, c: 0.0, d: -1.0, tx: 0.0, ty: 0.0)
        context.concatenate(affine)
        
        let dateFormatter : DateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "dd.MM. / w"
        
        
        let fnc : (CGSize) -> (CGPath) = {(_ textSize : CGSize) -> CGPath in
            return (angle < 90.0 || angle > 270.0) ? CGPath(rect: CGRect(x: 0.0, y: -1.0 * ceil(textSize.height), width: ceil(textSize.width), height: ceil(textSize.height)), transform:nil) : CGPath(rect: CGRect(x: 0.0, y: -312.0, width: ceil(textSize.width), height: ceil(textSize.height)), transform:nil)
        }
        drawText(inContext: context, theText: dateFormatter.string(from: Date.init()), withSize: 22, withWhite: 0.5, textPathFunction: fnc)
        
        context.restoreGState()
    }
    
    private func drawClockNumber(inContext context : CGContext, theText txt : String) {
        context.saveGState()
        
        let w : Double = (180.0) * .pi / 180.0
        let affine : CGAffineTransform = CGAffineTransform.init(a: CGFloat(1.0 * cos(w)), b: sin(CGFloat(w)), c: CGFloat(-1.0 * sin(w)), d: CGFloat(-1.0 * cos(w)), tx: 0.0, ty: 0.0)
        
        context.concatenate(affine)
        
        let fnc : (CGSize) -> (CGPath) = {(_ textSize : CGSize) -> CGPath in
            return CGPath(rect: CGRect(x: -0.5 * ceil(textSize.width), y: 0.5 * ceil(textSize.height), width: ceil(textSize.width), height: ceil(textSize.height)), transform:nil)
        }
        drawText(inContext: context, theText: txt, withSize: 42, withWhite: 1.0, textPathFunction: fnc)
        
        context.restoreGState()
    }
    
    private func drawText(inContext context : CGContext, theText text : String, withSize size : CGFloat, withWhite white : CGFloat, textPathFunction fnc : (CGSize) -> (CGPath)) {
        let textAttributes: [String: AnyObject] = [
            NSForegroundColorAttributeName : UIColor(white: white, alpha: 1.0).cgColor,
            NSFontAttributeName : UIFont.boldSystemFont(ofSize: size)
        ]
        let attributedString : NSAttributedString = NSAttributedString(string: text, attributes: textAttributes)
        let textSize : CGSize = text.size(attributes: textAttributes)
        let textPath : CGPath = fnc(textSize)
        let frameSetter : CTFramesetter = CTFramesetterCreateWithAttributedString(attributedString)
        let frame : CTFrame = CTFramesetterCreateFrame(frameSetter, CFRange(location: 0, length: attributedString.length), textPath, nil)
        
        CTFrameDraw(frame, context)
    }
}

//
//  ViewController.swift
//  Calculator
//
//  Created by Hung Nguyen on 7/9/15.
//  Copyright (c) 2015 Hung Nguyen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    
    var userIsTyping = false
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsTyping {
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsTyping = true
        }
        
    }
    
    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        switch operation{
        case "×": performOperation { $0 * $1 }
        case "÷": performOperation { $1 / $0 }
        case "+": performOperation { $0 + $1 }
        case "−": performOperation { $1 - $0 }
        case "√": performOperation { sqrt($0) }
        default: break
        }
    }
    
    private func performOperation(operation: (Double, Double) -> Double) {
        if operandStack.count >= 2 {
            displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
            enter()
        }
    }
    
    private func performOperation(operation: Double -> Double) {
        if operandStack.count >= 1 {
            displayValue = operation(operandStack.removeLast())
            enter()
        }
    }

    var operandStack = [Double]()
    
    @IBAction func enter() {
        userIsTyping = false
        operandStack.append(displayValue)
    }

    var displayValue: Double {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            display.text = "\(newValue)"
            userIsTyping = false
        }
    }
}


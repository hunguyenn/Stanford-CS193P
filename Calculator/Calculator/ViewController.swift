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
    @IBOutlet weak var history: UILabel!
    
    var userIsTyping = false
    var operandStack = [Double]()
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if digit == "." {
            if display.text!.rangeOfString(".") != nil {
                return
            }
        }
        if userIsTyping {
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsTyping = true
        }
        
    }
    
    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        switch operation {
        case "×": performOperation ("×", operation: { $0 * $1 })
        case "÷": performOperation ("÷", operation: { $1 / $0 })
        case "+": performOperation ("+", operation: { $0 + $1 })
        case "−": performOperation ("−", operation: { $1 - $0 })
        case "√": performOperation ("√", operation: { sqrt($0) })
        case "sin": performOperation ("sin", operation: { sin($0) })
        case "cos": performOperation ("cos", operation: { cos($0) })
        default: break
        }
    }
    
    private func performOperation(symbol: String, operation: (Double, Double) -> Double) {
        if userIsTyping { enterButton() } //
        if operandStack.count >= 2 {
            appendHistory(symbol)
            displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
            enter() //
        }
    }
    
    private func performOperation(symbol: String, operation: Double -> Double) {
        if userIsTyping { enterButton() } //
        if operandStack.count >= 1 {
            appendHistory(symbol)
            displayValue = operation(operandStack.removeLast())
            enter() //
        }
    }
    
    @IBAction func constant(sender: UIButton) {
        let constant = sender.currentTitle!
        switch constant {
        case "π": constEntered( "π", constant: M_PI )
        default: break
        }
    }
    
    private func constEntered(symbol: String, constant: Double) {
        if userIsTyping { enter() } //
        appendHistory(symbol)
        displayValue = constant
        enter() //
    }
    
    @IBAction func enterButton() {
        userIsTyping = false
        operandStack.append(displayValue)
        appendHistory(display.text!)
    }

    private func enter() {
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
    
    private func appendHistory(stringToAdd: String) {
        history.text! += " " + stringToAdd
    }
}


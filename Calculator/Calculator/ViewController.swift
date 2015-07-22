//
//  ViewController.swift
//  Calculator
//
//  Created by Hung Nguyen on 7/9/15.
//  Copyright (c) 2015 Hung Nguyen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel! // Calculator display.
    @IBOutlet weak var history: UILabel! // History display.
    
    var userIsTyping = false
    var brain = CalculatorBrain()
    
    // Clears operandStack, resets calculator display & history.
    @IBAction func clear() {
        history.text = " "
        displayValue = 0
        brain.clear()
    }
    
    // Handles input of numbers.
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
    
    // Handles operations.
    @IBAction func operate(sender: UIButton) {
        if userIsTyping {
            enterButton()
        }
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
                updateHistory()
            } else {
                displayValue = 0
            }
        }
    }
    
    // Handles constants.
    @IBAction func constant(sender: UIButton) {
        let constant = sender.currentTitle!
        switch constant {
        case "π": constEntered("π", constant: M_PI)
        case "M":
            if let value = brain.getValue("M") {
                constEntered("M", constant: brain.getValue("M")!)
            }
        default: break
        }
    }
    
    @IBAction func arrowMButton() {
        brain.setVariable("M", value: displayValue!)
        userIsTyping = false
    }
    
    // Private function allows for easily extendable constant function.
    private func constEntered(symbol: String, constant: Double) {
        if userIsTyping { enterButton() }
        updateHistory()
        displayValue = constant
        brain.pushOperand(symbol)
        // enter()
    }
    
    // Adds number to stack and calculator history.
    @IBAction func enterButton() {
        userIsTyping = false
        updateHistory()
        if let result = brain.pushOperand(displayValue) {
            displayValue = result
        } else {
            displayValue = 0
        }
    }

    // Adds number to stack.
    private func enter() {
        userIsTyping = false
        if let result = brain.pushOperand(displayValue) {
            displayValue = result
        } else {
            displayValue = 0
        }
    }
    
    // Converts display string to a double. -> Computed Value
    var displayValue: Double? {
        get {
            // should return nil when this fails
            if let num = NSNumberFormatter().numberFromString(display.text!) {
                return num.doubleValue
            } else {
                return nil
            }
        }
        set {
            if newValue != nil {
                display.text = "\(newValue!)"
                userIsTyping = false
            } else {
                clear()
            }
        }
    }
    
    // Add operands and operations to history.
    private func updateHistory() {
        history.text! = brain.description + " ="
    }
}


//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Hung Nguyen on 7/11/15.
//  Copyright (c) 2015 Hung Nguyen. All rights reserved.
//

// TO DO: 7efg, make PI automatically multiply (or any constant)

import Foundation

class CalculatorBrain
{
    private enum Op: Printable {
        case Operand(Double)
        case Variable(String)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                case .Variable(let variable):
                    return variable
                }
            }
        }
    }
    
    private var opStack = [Op]() // Operations stack
    private var knownOps = [String:Op]() // Known operations dictionary
    private var variableValues = [String:Double]() // Variable dictionary
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("÷") { $1 / $0 })
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("−") { $1 - $0 })
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        variableValues["π"] = M_PI
        
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Variable(let variable):
                return (variableValues[variable], remainingOps)
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        return result
    }
    
    func pushOperand(operand: Double?) -> Double? {
        if operand != nil {
            opStack.append(Op.Operand(operand!))
            return evaluate()
        } else {
            return nil
        }
    }
    
    // Access an already set variable
    func pushOperand(symbol: String) -> Double? {
        // access the number associated with variable
        if let num = variableValues[symbol] {
            opStack.append(Op.Variable(symbol))
            return evaluate()
        } else {
            return nil
        }
    }
    
    // Set a variable
    func setVariable(symbol: String, value: Double) -> Double? {
        variableValues[symbol] = value
        return pushOperand(symbol)
    }
    
    func getValue(symbol: String) -> Double? {
        return variableValues[symbol]
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    func clear() {
        opStack.removeAll()
    }
    
    var description: String {
        get {
            var tempString = ""
            var tempArray = [String]()
            var currDescription = description(opStack)
            tempArray.append(currDescription.parsedString)
            while !currDescription.remainingOps.isEmpty {
                currDescription = description(currDescription.remainingOps)
                tempArray.append(currDescription.parsedString)
            }
            for str in tempArray.reverse() {
                if tempString != "" {
                    tempString += ", "
                }
                tempString += str
            }
            return tempString
        }
    }
    
    private func description(ops: [Op]) -> (parsedString: String, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return ("\(Int(operand))", remainingOps)
            case .Variable(let variable):
                return (variable, remainingOps)
            case .UnaryOperation(let symbol, _):
                var recurse = description(remainingOps)
                return (symbol + "(" + recurse.parsedString + ")", recurse.remainingOps)
            case .BinaryOperation(let symbol, _):
                var r1 = description(remainingOps)
                var r2 = description(r1.remainingOps)
                var tempString = ""
                if r2.parsedString != "" { tempString += r2.parsedString }
                else { tempString += "?" }
                tempString += symbol
                if NSNumberFormatter().numberFromString(r1.parsedString) != nil || r1.parsedString.rangeOfString("(") != nil {
                    tempString += r1.parsedString
                } else {
                    tempString += "(" + r1.parsedString + ")"
                }
                return (tempString, r2.remainingOps)
                }
            }
        else {
            return ("", ops)
        }
    }
}

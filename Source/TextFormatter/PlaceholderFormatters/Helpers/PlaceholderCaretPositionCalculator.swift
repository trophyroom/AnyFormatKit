//
//  PlaceholderCaretPositionCalculator.swift
//  AnyFormatKit
//
//  Created by Oleksandr Orlov on 25.01.2021.
//  Copyright © 2021 Oleksandr Orlov. All rights reserved.
//

import Foundation

class PlaceholderCaretPositionCalculator {
    
    // MARK: - Properties
    let textPattern: String
    let patternSymbols: [Character]
//    private let defaultFormatter: DefaultTextFormatter
    
    // MARK: - Life Cycle
    init(textPattern: String, patternSymbols: [Character]) {
        self.textPattern = textPattern
        self.patternSymbols = patternSymbols
//        self.defaultFormatter = DefaultTextFormatter(textPattern: textPattern, patternSymbol: patternSymbol)
    }
    
    func calculateCaretPositionOffset(currentText: String) -> Int {
        let diff = currentText.getRemovingMatches(toMatch: textPattern)
        return diff.utf16Length
    }
    
    func calculateCaretPositionOffset(newText: String, originalRange range: Range<String.Index>, replacementText: String) -> Int {
        var offset = 0
        if replacementText.isEmpty {
            offset = offsetForRemove(newText: newText, lowerBound: range.lowerBound)
        } else {
            offset = offsetForInsert(newText: newText, lowerBound: range.lowerBound, replacementLength: replacementText.count)
        }
        return offset
    }
    
    private func offsetForRemove(newText: String, lowerBound: String.Index) -> Int {
        let textPatternLowerBound = textPattern.getSameIndex(asIn: newText, sourceIndex: lowerBound)
        
        var index = newText.startIndex
        for symbol in patternSymbols.reversed() {
            let textPatternIndex = textPattern.findIndexBefore(of: symbol, startFrom: textPatternLowerBound)
            index = newText.getSameIndex(asIn: textPattern, sourceIndex: textPatternIndex)
            if index != newText.startIndex {
                break
            }
        }
        
        let leftSlice = newText.leftSlice(end: index)
        return leftSlice.utf16Length
    }
    
    private func offsetForInsert(newText: String, lowerBound: String.Index, replacementLength: Int) -> Int {
        let textPatternLowerBound = textPattern.getSameIndex(asIn: newText, sourceIndex: lowerBound)
        
        var textPatternIndex = textPattern.endIndex
        var index = newText.endIndex
        for symbol in patternSymbols {
            textPatternIndex = textPattern.findIndex(of: symbol, skipFirst: replacementLength, startFrom: textPatternLowerBound)
            index = newText.getSameIndex(asIn: textPattern, sourceIndex: textPatternIndex)
            if index != newText.endIndex {
                break
            }
        }
        
        let leftSlice = newText.leftSlice(end: index)
        let textPatternLeftSlice = textPattern.leftSlice(end: textPatternIndex)
        let diff = leftSlice.getRemovingMatches(toMatch: textPatternLeftSlice)
        return diff.utf16Length
    }
}

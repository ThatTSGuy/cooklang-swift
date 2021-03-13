//
//  TokenizerTests.swift
//  SwiftCookInSwiftTests
//
//  Created by Alexey Dubovskoy on 06/12/2020.
//  Copyright © 2020 Alexey Dubovskoy. All rights reserved.
//

import Foundation
@testable import CookInSwift
import XCTest

class LexerTests: XCTestCase {

    func testEmptyInput() {
        let lexer = Lexer("")
        XCTAssertEqual(lexer.getNextToken(), .eof)
    }

    func testWhitespaceOnlyInput() {
        let lexer = Lexer(" ")
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(" ")))
        XCTAssertEqual(lexer.getNextToken(), .eof)
    }

    func testNewLineInput() {
        let input = "   \n    "
        let lexer = Lexer(input)
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("   ")))
        XCTAssertEqual(lexer.getNextToken(), .eol)
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("    ")))
        XCTAssertEqual(lexer.getNextToken(), .eof)
    }
    
    func testMultipleNewLinesInput() {
        let input = "   \n\n    "
        let lexer = Lexer(input)
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("   ")))
        XCTAssertEqual(lexer.getNextToken(), .eol)
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("    ")))
        XCTAssertEqual(lexer.getNextToken(), .eof)
    }
    
    func testBasicString() {
        let input = "abc"
        let lexer = Lexer(input)
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("abc")))
        XCTAssertEqual(lexer.getNextToken(), .eof)
    }
    
    func testConcessiveStrings() {
        let input = "abc xyz"
        let lexer = Lexer(input)
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("abc")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(" ")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("xyz")))
        XCTAssertEqual(lexer.getNextToken(), .eof)
    }
    
    func testStringWithNumbers() {
        let input = "abc 777 xyz"
        let lexer = Lexer(input)
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("abc")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(" ")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.integer(777)))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(" ")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("xyz")))
        XCTAssertEqual(lexer.getNextToken(), .eof)
    }
    
    func testStringWithPunctuation() {
        let input = "abc – xyz: lol,"
        let lexer = Lexer(input)
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("abc")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(" ")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("–")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(" ")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("xyz")))
        XCTAssertEqual(lexer.getNextToken(), .colon)
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(" ")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("lol")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(",")))
        XCTAssertEqual(lexer.getNextToken(), .eof)
    }
    
    func testStringWithPunctuationRepeated() {
        let input = "abc – ...,,xyz: lol,"
        let lexer = Lexer(input)
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("abc")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(" ")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("–")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(" ")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("...,,")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("xyz")))
        XCTAssertEqual(lexer.getNextToken(), .colon)
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(" ")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("lol")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(",")))
        XCTAssertEqual(lexer.getNextToken(), .eof)
    }
    
    func testIngridientsOneLiner() {
        let input = "Add @onions{3%medium} chopped finely"
        let lexer = Lexer(input)
    
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("Add")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(" ")))
        XCTAssertEqual(lexer.getNextToken(), .at)
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("onions")))
        XCTAssertEqual(lexer.getNextToken(), .braces(.left))
        XCTAssertEqual(lexer.getNextToken(), .constant(.integer(3)))
        XCTAssertEqual(lexer.getNextToken(), .percent)
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("medium")))
        XCTAssertEqual(lexer.getNextToken(), .braces(.right))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(" ")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("chopped")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(" ")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("finely")))
        XCTAssertEqual(lexer.getNextToken(), .eof)
    }
    
    func testIngridientsDecimal() {
        let input = "@onions{3.5%medium}"
        let lexer = Lexer(input)
    
        XCTAssertEqual(lexer.getNextToken(), .at)
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("onions")))
        XCTAssertEqual(lexer.getNextToken(), .braces(.left))
        XCTAssertEqual(lexer.getNextToken(), .constant(.decimal(3.5)))
        XCTAssertEqual(lexer.getNextToken(), .percent)
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("medium")))
        XCTAssertEqual(lexer.getNextToken(), .braces(.right))
        XCTAssertEqual(lexer.getNextToken(), .eof)
    }
    
    func testIngridientsFractions() {
        let input = "@onions{1/4%medium}"
        let lexer = Lexer(input)
    
        XCTAssertEqual(lexer.getNextToken(), .at)
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("onions")))
        XCTAssertEqual(lexer.getNextToken(), .braces(.left))
        XCTAssertEqual(lexer.getNextToken(), .constant(.integer(1)))
        XCTAssertEqual(lexer.getNextToken(), .slash)
        XCTAssertEqual(lexer.getNextToken(), .constant(.integer(4)))
        XCTAssertEqual(lexer.getNextToken(), .percent)
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("medium")))
        XCTAssertEqual(lexer.getNextToken(), .braces(.right))
        XCTAssertEqual(lexer.getNextToken(), .eof)
    }
    
    func testIngridientsFractionsWithSpaces() {
        let input = "@onions{1 / 4 %medium}"
        let lexer = Lexer(input)
    
        XCTAssertEqual(lexer.getNextToken(), .at)
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("onions")))
        XCTAssertEqual(lexer.getNextToken(), .braces(.left))
        XCTAssertEqual(lexer.getNextToken(), .constant(.integer(1)))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(" ")))
        XCTAssertEqual(lexer.getNextToken(), .slash)
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(" ")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.integer(4)))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(" ")))
        XCTAssertEqual(lexer.getNextToken(), .percent)
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("medium")))
        XCTAssertEqual(lexer.getNextToken(), .braces(.right))
        XCTAssertEqual(lexer.getNextToken(), .eof)
    }
    
    func testComments() {
        let input = "// testing comments"
        let lexer = Lexer(input)
                
        XCTAssertEqual(lexer.getNextToken(), .eol)
        XCTAssertEqual(lexer.getNextToken(), .eof)
    }
    
    func testSlashLast() {
        let input = "onions /"
        let lexer = Lexer(input)
        
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("onions")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(" ")))
        XCTAssertEqual(lexer.getNextToken(), .slash)
        XCTAssertEqual(lexer.getNextToken(), .eof)
    }
    
    func testSlashInText() {
        let input = "Preheat the oven to 200℃/Fan 180°C."
        let lexer = Lexer(input)
        
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("Preheat")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(" ")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("the")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(" ")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("oven")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(" ")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("to")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(" ")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.integer(200)))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("℃")))
        XCTAssertEqual(lexer.getNextToken(), .slash)
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("Fan")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(" ")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.integer(180)))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("°")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("C")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(".")))
        XCTAssertEqual(lexer.getNextToken(), .eof)
    }
    
    func testIngridientsNoUnits() {
        let input = "@onions{3}"
        let lexer = Lexer(input)
    
        XCTAssertEqual(lexer.getNextToken(), .at)
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("onions")))
        XCTAssertEqual(lexer.getNextToken(), .braces(.left))
        XCTAssertEqual(lexer.getNextToken(), .constant(.integer(3)))
        XCTAssertEqual(lexer.getNextToken(), .braces(.right))
        XCTAssertEqual(lexer.getNextToken(), .eof)
    }
    
    func testIngridientsNoAmount() {
        let input = "@onions"
        let lexer = Lexer(input)
    
        XCTAssertEqual(lexer.getNextToken(), .at)
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("onions")))
        XCTAssertEqual(lexer.getNextToken(), .eof)
    }
    
    func testIngridientsMultiWordNoAmount() {
        let input = "@red onions{}"
        let lexer = Lexer(input)
    
        XCTAssertEqual(lexer.getNextToken(), .at)
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("red")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(" ")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("onions")))
        XCTAssertEqual(lexer.getNextToken(), .braces(.left))
        XCTAssertEqual(lexer.getNextToken(), .braces(.right))
        XCTAssertEqual(lexer.getNextToken(), .eof)
    }
    
    func testIngridientsMultiWordWithPunctuation() {
        let input = "@onions, chopped"
        let lexer = Lexer(input)
    
        XCTAssertEqual(lexer.getNextToken(), .at)
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("onions")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(",")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(" ")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("chopped")))
        XCTAssertEqual(lexer.getNextToken(), .eof)
    }
    
    func testIngridientsWordNoAmount() {
        let input = "an @onion finely chopped"
        let lexer = Lexer(input)
    
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("an")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(" ")))
        XCTAssertEqual(lexer.getNextToken(), .at)
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("onion")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(" ")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("finely")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(" ")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("chopped")))
        XCTAssertEqual(lexer.getNextToken(), .eof)
    }
    
    func testEquipment() {
        let input = "put into #oven"
        let lexer = Lexer(input)
    
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("put")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(" ")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("into")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(" ")))
        XCTAssertEqual(lexer.getNextToken(), .hash)
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("oven")))
        XCTAssertEqual(lexer.getNextToken(), .eof)
    }
    
    func testEquipmentMultiWord() {
        let input = "fry on #frying pan{}"
        let lexer = Lexer(input)
    
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("fry")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(" ")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("on")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(" ")))
        XCTAssertEqual(lexer.getNextToken(), .hash)
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("frying")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(" ")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("pan")))
        XCTAssertEqual(lexer.getNextToken(), .braces(.left))
        XCTAssertEqual(lexer.getNextToken(), .braces(.right))
        XCTAssertEqual(lexer.getNextToken(), .eof)
    }
    
    func tesTimer() {
        let input = "cook for ~{10%minutes}"
        let lexer = Lexer(input)
    
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("cook")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(" ")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("for")))
        XCTAssertEqual(lexer.getNextToken(), .tilde)
        XCTAssertEqual(lexer.getNextToken(), .braces(.left))
        XCTAssertEqual(lexer.getNextToken(), .constant(.integer(10)))
        XCTAssertEqual(lexer.getNextToken(), .percent)
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("minutes")))
        XCTAssertEqual(lexer.getNextToken(), .braces(.right))
        XCTAssertEqual(lexer.getNextToken(), .eof)
    }
    
    func testIngridientsMultiLiner() {
        let input = """
        Add @onions{3%medium} chopped finely

        Bonne appetite!
        """
        let lexer = Lexer(input)
    
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("Add")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(" ")))
        XCTAssertEqual(lexer.getNextToken(), .at)
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("onions")))
        XCTAssertEqual(lexer.getNextToken(), .braces(.left))
        XCTAssertEqual(lexer.getNextToken(), .constant(.integer(3)))
        XCTAssertEqual(lexer.getNextToken(), .percent)
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("medium")))
        XCTAssertEqual(lexer.getNextToken(), .braces(.right))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(" ")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("chopped")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(" ")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("finely")))
        XCTAssertEqual(lexer.getNextToken(), .eol)
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("Bonne")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(" ")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("appetite")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("!")))
        XCTAssertEqual(lexer.getNextToken(), .eof)
    }
    
    func testMetadata() {
        let input = ">> servings: 4|5|6"
        let lexer = Lexer(input)
    
        XCTAssertEqual(lexer.getNextToken(), .chevron)
        XCTAssertEqual(lexer.getNextToken(), .chevron)
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(" ")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.string("servings")))
        XCTAssertEqual(lexer.getNextToken(), .colon)
        XCTAssertEqual(lexer.getNextToken(), .constant(.string(" ")))
        XCTAssertEqual(lexer.getNextToken(), .constant(.integer(4)))
        XCTAssertEqual(lexer.getNextToken(), .pipe)
        XCTAssertEqual(lexer.getNextToken(), .constant(.integer(5)))
        XCTAssertEqual(lexer.getNextToken(), .pipe)
        XCTAssertEqual(lexer.getNextToken(), .constant(.integer(6)))
        XCTAssertEqual(lexer.getNextToken(), .eof)
    }

}
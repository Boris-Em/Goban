//
//  FunctionalParser.swift
//  GobanSampleProject
//
//  Created by John on 5/3/16.
//  Copyright © 2016 Boris Emorine. All rights reserved.
//

import Foundation

// helpers for the AnySequence.flatMap

struct JoinedGenerator<Element>: GeneratorType {
    var generator: AnyGenerator<AnyGenerator<Element>>
    var current: AnyGenerator<Element>?
    
    init<G: GeneratorType where G.Element: GeneratorType, G.Element.Element == Element>(_ g: G) {
        var varg = g
        generator = varg.mapOnce { AnyGenerator($0) }
        current = generator.next()
    }
    
    mutating func next() -> Element? {
        guard let c = current else { return nil }
        
        if let x = c.next() {
            return x
        } else {
            current = generator.next()
            return next()
        }
    }
}

extension SequenceType where Generator.Element: SequenceType {
    typealias NestedElement = Generator.Element.Generator.Element
    
    func join() -> AnySequence<NestedElement> {
        return AnySequence { () -> JoinedGenerator<NestedElement> in
            var generator = self.generate()
            return JoinedGenerator(generator.mapOnce { $0.generate() } )
        }
    }
}


// Combine Generators
func +<A>(l: AnyGenerator<A>, r: AnyGenerator<A>) -> AnyGenerator<A> {
    return AnyGenerator { l.next() ?? r.next() }
}

// Combine Sequences
func +<A>(l: AnySequence<A>, r: AnySequence<A>) -> AnySequence<A> {
    return AnySequence {l.generate() + r.generate()}
}

// GeneratorType map was removed - perhaps because it might unexpectedly exhaust the generator
// still it's convenient to have it
extension GeneratorType {
    mutating func mapOnce<U>(transform: (Self.Element) -> U) -> AnyGenerator<U> {
        return AnyGenerator { self.next().map(transform) }
    }
}

// Add flatmap for AnySequence
extension AnySequence {
    func flatMap<T, Seq: SequenceType where Seq.Generator.Element == T>(f: Element -> Seq) -> AnySequence<T> {
        return AnySequence<Seq>(self.map(f)).join()
    }
}

// convenience was of creating an AnySequence from a single Token.
func anySequenceOfOne<A>(x: A) -> AnySequence<A> {
    return AnySequence(GeneratorOfOne(x))
}

// Array(Slice) decomponse helpers

extension Array {
    var decompose: (Element, [Element])? {
        return isEmpty ? nil : (self[startIndex], Array(self.dropFirst()))
    }
}

extension ArraySlice {
    var decompose: (Element, ArraySlice<Element>)? {
        return isEmpty ? nil : (self[startIndex], self.dropFirst())
    }
}

extension String {
    var slice: ArraySlice<Character> {
        return Array(self.characters)[0 ..< self.characters.count]
    }
}


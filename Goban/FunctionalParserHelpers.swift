//
//  FunctionalParser.swift
//  GobanSampleProject
//
//  Created by John on 5/3/16.
//  Copyright © 2016 Boris Emorine. All rights reserved.
//

import Foundation

// helpers for the AnySequence.flatMap

struct JoinedGenerator<Element>: IteratorProtocol {
    var generator: AnyIterator<AnyIterator<Element>>
    var current: AnyIterator<Element>?
    
    init<G: IteratorProtocol>(_ g: G) where G.Element: IteratorProtocol, G.Element.Element == Element {
        var varg = g
        generator = varg.mapOnce { AnyIterator($0) }
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

extension Sequence where Iterator.Element: Sequence {
    typealias NestedElement = Iterator.Element.Iterator.Element
    
    func join() -> AnySequence<NestedElement> {
        return AnySequence { () -> JoinedGenerator<NestedElement> in
            var generator = self.makeIterator()
            return JoinedGenerator(generator.mapOnce { $0.makeIterator() } )
        }
    }
}


// Combine Generators
func +<A>(l: AnyIterator<A>, r: AnyIterator<A>) -> AnyIterator<A> {
    return AnyIterator { l.next() ?? r.next() }
}

// Combine Sequences
func +<A>(l: AnySequence<A>, r: AnySequence<A>) -> AnySequence<A> {
    return AnySequence {l.makeIterator() + r.makeIterator()}
}

// GeneratorType map was removed - perhaps because it might unexpectedly exhaust the generator
// still it's convenient to have it
extension IteratorProtocol {
    mutating func mapOnce<U>(_ transform: @escaping (Self.Element) -> U) -> AnyIterator<U> {
        var copy = self
        return AnyIterator { copy.next().map(transform) }
    }
}

struct TakeWhileGenerator<G: IteratorProtocol>: IteratorProtocol {
    var base: G
    let predicate: (G.Element) -> Bool
    
    mutating func next() -> G.Element? {
        guard let n = base.next(), predicate(n) else {
            return nil
        }
        return n
    }
}

struct LazyTakeWhileSequence<S: Sequence>: LazySequenceProtocol {
    let base: S
    let predicate: (S.Iterator.Element) -> Bool
    
    func makeIterator() -> TakeWhileGenerator<S.Iterator> {
        return TakeWhileGenerator(base: base.makeIterator(), predicate: predicate)
    }
}

extension LazySequenceProtocol {
    func takeWhile(_ predicate: @escaping (Iterator.Element) -> Bool) -> LazyTakeWhileSequence<Self> {
        return LazyTakeWhileSequence(base: self, predicate: predicate)
    }
}


// Add flatmap for AnySequence
extension AnySequence {
    func flatMap<T, Seq: Sequence>(_ f: (Element) -> Seq) -> AnySequence<T> where Seq.Iterator.Element == T {
        return AnySequence<Seq>(self.map(f)).join()
    }
}

// convenience was of creating an AnySequence from a single Token.
func anySequenceOfOne<A>(_ x: A) -> AnySequence<A> {
    return AnySequence(IteratorOverOne(_elements: x))
}

// empty sequence
func emptySequence<T>() -> AnySequence<T> {
    return AnySequence([])
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
        return Array(self)[0 ..< self.count]
    }
}

func curry<A,B,C>(_ f: @escaping (A,B) -> C) -> (A) -> (B) -> C  {
    return { a in { b in f(a,b) } }
}

func curry<A,B,C,D>(_ f: @escaping (A,B,C) -> D) -> (A) -> (B) -> (C) -> D  {
    return { a in { b in { c in f(a,b,c) } } }
}

func prepend<A>(_ l: A) -> ([A]) -> [A] {
    return { r in return [l] + r }
}

func concat<A>(_ l: [A]) -> ([A]) -> [A] {
    return { r in return l + r }
}

func stringFromChars(_ chars: [Character]) -> String {
    return String(chars)
}

func intFromChars(_ chars: [Character]) -> Int {
    return Int(String(chars))!
}


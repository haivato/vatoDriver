# KeyPathKit

[![Build Status](https://travis-ci.org/vincent-pradeilles/KeyPathKit.svg?branch=master)](https://travis-ci.org/vincent-pradeilles/KeyPathKit)
![platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS-333333.svg)
![pod](https://img.shields.io/cocoapods/v/KeyPathKit.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

## Context

Swift 4 has introduced a new type called `KeyPath`, with allows to access the properties of an object with a very nice syntax. For instance:

```swift
let string = "Foo"
let keyPathForCount = \String.count

let count = string[keyPath: keyPathForCount] // count == 3
```

The great part is that the syntax can be very concise, because it supports type inference and property chaining.

## Purpose of `KeyPathKit`

Consequently, I thought it would be nice to leverage this new concept in order to build an API that allows to perform data manipulation in a very declarative fashion.

SQL is a great language for such manipulations, so I took inspiration from it and implemented most of its standard operators in Swift 4 using `KeyPath`.

But what really stands `KeyPathKit` appart from the competition is its clever syntax that allows to express queries in a very seamless fashion. For instance :

```swift
contacts.filter(where: \.lastName == "Webb" && \.age < 40)
```

## Installation

### CocoaPods

Add the following to your `Podfile`:

`pod "KeyPathKit"`

### Carthage

Add the following to your `Cartfile`:

`github "vincent-pradeilles/KeyPathKit"`

### Swift Package Manager

Create a file `Package.swift`:

```swift
// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "YourProject",
    dependencies: [
        .package(url: "https://github.com/vincent-pradeilles/KeyPathKit.git", "1.0.0" ..< "2.0.0")
    ],
    targets: [
        .target(name: "YourProject", dependencies: ["KeyPathKit"])
    ]
)
```

## Operators

* [and](#and)
* [average](#average)
* [between](#between)
* [contains](#contains)
* [distinct](#distinct)
* [drop](#drop)
* [filter](#filter)
* [filterIn](#filterin)
* [filterLess](#filterless)
* [filterLike](#filterlike)
* [filterMore](#filtermore)
* [first](#first)
* [groupBy](#groupby)
* [join](#join)
* [map](#map)
* [mapTo](#mapto)
* [max](#max)
* [min](#min)
* [or](#or)
* [patternMatching](#patternMatching)
* [prefix](#prefix)
* [sum](#sum)
* [sort](#sort)

## Operator details

For the purpose of demonstrating the usage of the operators, the following mock data is defined:

```swift
struct Person {
    let firstName: String
    let lastName: String
    let age: Int
    let hasDriverLicense: Bool
    let isAmerican: Bool
}

let contacts = [
    Person(firstName: "Charlie", lastName: "Webb", age: 10, hasDriverLicense: false, isAmerican: true),
    Person(firstName: "Alex", lastName: "Elexson", age: 22, hasDriverLicense: false, isAmerican: true),
    Person(firstName: "Charles", lastName: "Webb", age: 45, hasDriverLicense: true, isAmerican: true),
    Person(firstName: "Alex", lastName: "Zunino", age: 34, hasDriverLicense: true, isAmerican: true),
    Person(firstName: "Alex", lastName: "Alexson", age: 8, hasDriverLicense: false, isAmerican: true),
    Person(firstName: "John", lastName: "Webb", age: 28, hasDriverLicense: true, isAmerican: true),
    Person(firstName: "Webb", lastName: "Elexson", age: 30, hasDriverLicense: true, isAmerican: true)
]
``` 
 
### and

Performs a boolean AND operation on a property of type `Bool`.

```swift
contacts.and(\.hasDriverLicense)
contacts.and(\.isAmerican)
```

```
false
true
```

### average

Calculates the average of a numerical property.

```swift
contacts.average(of: \.age).rounded()
```

```
25
```

### between

Filters out elements whose value for the property is not within the range.

```swift
contacts.between(\.age, range: 20...30)
// or
contacts.filter(where: 20...30 ~= \.age)
```

```
[Person(firstName: "Alex", lastName: "Elexson", age: 22, hasDriverLicense: false, isAmerican: true),
 Person(firstName: "John", lastName: "Webb", age: 28, hasDriverLicense: true, isAmerican: true), 
 Person(firstName: "Webb", lastName: "Elexson", age: 30, hasDriverLicense: true, isAmerican: true)]
```

### contains

Returns whether the sequence contains one element for which the specified boolean property or predicate is true.

```swift
contacts.contains(where: \.hasDriverLicense)
contacts.contains(where: \.lastName.count > 10)
```

```
true
false
```

### distinct

Returns all the distinct values for the property.

```swift
contacts.distinct(\.lastName)
```

```
["Webb", "Elexson", "Zunino", "Alexson"]
```

### drop

Returns a subsequence by skipping elements while a property of type `Bool` or a predicate evaluates to true, and returning the remaining elements.

```swift
contacts.drop(while: \.age < 40)
```

```
[Person(firstName: "Charles", lastName: "Webb", age: 45, hasDriverLicense: true, isAmerican: true), 
 Person(firstName: "Alex", lastName: "Zunino", age: 34, hasDriverLicense: true, isAmerican: true), 
 Person(firstName: "Alex", lastName: "Alexson", age: 8, hasDriverLicense: false, isAmerican: true), 
 Person(firstName: "John", lastName: "Webb", age: 28, hasDriverLicense: true, isAmerican: true), 
 Person(firstName: "Webb", lastName: "Elexson", age: 30, hasDriverLicense: true, isAmerican: true)]
```

### filter

Filters out elements whose value is `false` for one (or several) boolean property.

```swift
contacts.filter(where: \.hasDriverLicense)
```

```
[Person(firstName: "Charles", lastName: "Webb", age: 45, hasDriverLicense: true, isAmerican: true), 
 Person(firstName: "Alex", lastName: "Zunino", age: 34, hasDriverLicense: true, isAmerican: true), 
 Person(firstName: "John", lastName: "Webb", age: 28, hasDriverLicense: true, isAmerican: true), 
 Person(firstName: "Webb", lastName: "Elexson", age: 30, hasDriverLicense: true, isAmerican: true)]
```

Filter also works with predicates:

```swift
contacts.filter(where: \.firstName == "Webb")
```

```
[Person(firstName: "Charlie", lastName: "Webb", age: 10, hasDriverLicense: false, isAmerican: true),
 Person(firstName: "Charles", lastName: "Webb", age: 45, hasDriverLicense: true, isAmerican: true),
 Person(firstName: "John", lastName: "Webb", age: 28, hasDriverLicense: true, isAmerican: true)]
```

### filterIn

Filters out elements whose value for an `Equatable` property is not in a given `Sequence`.

```swift
contacts.filter(where: \.firstName, in: ["Alex", "John"])
```

```
[Person(firstName: "Alex", lastName: "Elexson", age: 22, hasDriverLicense: false, isAmerican: true), 
 Person(firstName: "Alex", lastName: "Zunino", age: 34, hasDriverLicense: true, isAmerican: true), 
 Person(firstName: "Alex", lastName: "Alexson", age: 8, hasDriverLicense: false, isAmerican: true), 
 Person(firstName: "John", lastName: "Webb", age: 28, hasDriverLicense: true, isAmerican: true)]
```

### filterLess

Filters out elements whose value is greater than a constant for a `Comparable` property.

```swift
contacts.filter(where: \.age, lessThan: 30)
// or
contacts.filter(where: \.age < 30)
```

```
[Person(firstName: "Charlie", lastName: "Webb", age: 10, hasDriverLicense: false, isAmerican: true), 
 Person(firstName: "Alex", lastName: "Elexson", age: 22, hasDriverLicense: false, isAmerican: true), 
 Person(firstName: "Alex", lastName: "Alexson", age: 8, hasDriverLicense: false, isAmerican: true), 
 Person(firstName: "John", lastName: "Webb", age: 28, hasDriverLicense: true, isAmerican: true)]
```
 
```swift
contacts.filter(where: \.age, lessOrEqual: 30)
// or
contacts.filter(where: \.age <= 30)
```

```
[Person(firstName: "Charlie", lastName: "Webb", age: 10, hasDriverLicense: false, isAmerican: true), 
 Person(firstName: "Alex", lastName: "Elexson", age: 22, hasDriverLicense: false, isAmerican: true), 
 Person(firstName: "Alex", lastName: "Alexson", age: 8, hasDriverLicense: false, isAmerican: true), 
 Person(firstName: "John", lastName: "Webb", age: 28, hasDriverLicense: true, isAmerican: true), 
 Person(firstName: "Webb", lastName: "Elexson", age: 30, hasDriverLicense: true, isAmerican: true)]
```

### filterLike

Filters out elements whose value for a string property does not match a regular expression.

```swift
contacts.filter(where: \.lastName, like: "^[A-Za-z]*son$")
```

```
[Person(firstName: "Alex", lastName: "Elexson", age: 22, hasDriverLicense: false, isAmerican: true), 
 Person(firstName: "Alex", lastName: "Alexson", age: 8, hasDriverLicense: false, isAmerican: true), 
 Person(firstName: "Webb", lastName: "Elexson", age: 30, hasDriverLicense: true, isAmerican: true)]
```

### filterMore

Filters out elements whose value is lesser than a constant for a `Comparable` property.

```swift
contacts.filter(where: \.age, moreThan: 30)
// or
contacts.filter(where: \.age > 30)
```

```
[Person(firstName: "Charles", lastName: "Webb", age: 45, hasDriverLicense: true, isAmerican: true), 
 Person(firstName: "Alex", lastName: "Zunino", age: 34, hasDriverLicense: true, isAmerican: true)]
```

```swift
contacts.filter(where: \.age, moreOrEqual: 30)
// or
contacts.filter(where: \.age >= 30)
```

```
[Person(firstName: "Charles", lastName: "Webb", age: 45, hasDriverLicense: true, isAmerican: true), 
 Person(firstName: "Alex", lastName: "Zunino", age: 34, hasDriverLicense: true, isAmerican: true), 
 Person(firstName: "Webb", lastName: "Elexson", age: 30, hasDriverLicense: true, isAmerican: true)]
```

### first

Returns the first element matching a predicate.

```swift
contacts.first(where: \.lastName == "Webb")
```

```
Optional(Person(firstName: "Charlie", lastName: "Webb", age: 10, hasDriverLicense: false, isAmerican: true))
```

### groupBy

Groups values by equality on the property. 

```swift
contacts.groupBy(\.lastName)
```

```
["Alexson": [Person(firstName: "Alex", lastName: "Alexson", age: 8, hasDriverLicense: false, isAmerican: true)], 
 "Webb": [Person(firstName: "Charlie", lastName: "Webb", age: 10, hasDriverLicense: false, isAmerican: true), Person(firstName: "Charles", lastName: "Webb", age: 45, hasDriverLicense: true, isAmerican: true), Person(firstName: "John", lastName: "Webb", age: 28, hasDriverLicense: true, isAmerican: true)], 
 "Elexson": [Person(firstName: "Alex", lastName: "Elexson", age: 22, hasDriverLicense: false, isAmerican: true), Person(firstName: "Webb", lastName: "Elexson", age: 30, hasDriverLicense: true, isAmerican: true)], 
 "Zunino": [Person(firstName: "Alex", lastName: "Zunino", age: 34, hasDriverLicense: true, isAmerican: true)]]
```

### join

Joins values of two sequences in tuples by the equality on their respective property.

```swift
contacts.join(\.firstName, with: contacts, on: \.lastName)
// or
contacts.join(with: contacts, where: \.firstName == \.lastName)
```

```
[(Person(firstName: "Webb", lastName: "Elexson", age: 30, hasDriverLicense: true, isAmerican: true), Person(firstName: "Charlie", lastName: "Webb", age: 10, hasDriverLicense: false, isAmerican: true)), 
 (Person(firstName: "Webb", lastName: "Elexson", age: 30, hasDriverLicense: true, isAmerican: true), Person(firstName: "Charles", lastName: "Webb", age: 45, hasDriverLicense: true, isAmerican: true)), 
 (Person(firstName: "Webb", lastName: "Elexson", age: 30, hasDriverLicense: true, isAmerican: true), Person(firstName: "John", lastName: "Webb", age: 28, hasDriverLicense: true, isAmerican: true))]
```

Joining on more than one attribute is also supported:

```swift
contacts.join(with: contacts, .where(\.firstName, equals: \.lastName), .where(\.hasDriverLicense, equals: \.isAmerican))
// or
contacts.join(with: contacts, where: \.firstName == \.lastName, \.hasDriverLicense == \.isAmerican)
```

### map

Maps elements to their values of the property.

```swift
contacts.map(\.lastName)
```

```
["Webb", "Elexson", "Webb", "Zunino", "Alexson", "Webb", "Elexson"]
```

### mapTo

Maps a sequence of properties to a function. This is, for instance, useful to extract a subset of properties into a structured type.

```swift
struct ContactCellModel {
    let firstName: String
    let lastName: String
}

contacts.map(\.lastName, \.firstName, to: ContactCellModel.init)
```

```
[ContactCellModel(firstName: "Webb", lastName: "Charlie"), 
 ContactCellModel(firstName: "Elexson", lastName: "Alex"), 
 ContactCellModel(firstName: "Webb", lastName: "Charles"), 
 ContactCellModel(firstName: "Zunino", lastName: "Alex"), 
 ContactCellModel(firstName: "Alexson", lastName: "Alex"), 
 ContactCellModel(firstName: "Webb", lastName: "John"), 
 ContactCellModel(firstName: "Elexson", lastName: "Webb")]
```

### max

Returns the element with the greatest value for a `Comparable` property.

```swift
contacts.max(by: \.age)
contacts.max(\.age)
```

```
Optional(Person(firstName: "Charles", lastName: "Webb", age: 45, hasDriverLicense: true, isAmerican: true))
Optional(45)
```

### min

Returns the element with the minimum value for a `Comparable` property.

```swift
contacts.min(by: \.age)
contacts.min(\.age)
```

```
Optional(Person(firstName: "Alex", lastName: "Alexson", age: 8, hasDriverLicense: false, isAmerican: true))
Optional(8)
```

### or

Performs a boolean OR operation on an property of type `Bool`.

```swift
contacts.or(\.hasDriverLicense)
```

```
true
```

### patternMatching

Allows the use of predicates inside a `switch` statement:

```swift
switch person {
case \.firstName == "Charlie":
    print("I'm Charlie!")
    fallthrough
case \.age < 18:
    print("I'm not an adult...")
    fallthrough
default:
    break
}
```

### prefix

Returns a subsequence containing the initial, consecutive elements for whose a property of type `Bool` or a predicate evaluates to true.

```swift
contacts.prefix(while: \.age < 40)
```

```
[Person(firstName: "Charlie", lastName: "Webb", age: 10, hasDriverLicense: false, isAmerican: true),
 Person(firstName: "Alex", lastName: "Elexson", age: 22, hasDriverLicense: false, isAmerican: true)]
```

### sum

Calculates the sum of the values for a numerical property.

```swift
contacts.sum(of: \.age)
```

```
177
```

### sort

Sorts the elements with respect to a `Comparable` property.

```swift
contacts.sorted(by: \.age)
```

```
[Person(firstName: "Alex", lastName: "Alexson", age: 8, hasDriverLicense: false, isAmerican: true), 
 Person(firstName: "Charlie", lastName: "Webb", age: 10, hasDriverLicense: false, isAmerican: true), 
 Person(firstName: "Alex", lastName: "Elexson", age: 22, hasDriverLicense: false, isAmerican: true), Person(firstName: "John", lastName: "Webb", age: 28, hasDriverLicense: true, isAmerican: true), 
 Person(firstName: "Webb", lastName: "Elexson", age: 30, hasDriverLicense: true, isAmerican: true), 
 Person(firstName: "Alex", lastName: "Zunino", age: 34, hasDriverLicense: true, isAmerican: true), 
 Person(firstName: "Charles", lastName: "Webb", age: 45, hasDriverLicense: true, isAmerican: true)]
```

It's also possible to specify the sorting order, to sort on multiple criteria, or to do both.

```swift
contacts.sorted(by: .ascending(\.lastName), .descending(\.age))
```

```
[Person(firstName: "Alex", lastName: "Alexson", age: 8, hasDriverLicense: false, isAmerican: true), 
 Person(firstName: "Webb", lastName: "Elexson", age: 30, hasDriverLicense: true, isAmerican: true), 
 Person(firstName: "Alex", lastName: "Elexson", age: 22, hasDriverLicense: false, isAmerican: true), 
 Person(firstName: "Charles", lastName: "Webb", age: 45, hasDriverLicense: true, isAmerican: true), 
 Person(firstName: "John", lastName: "Webb", age: 28, hasDriverLicense: true, isAmerican: true), 
 Person(firstName: "Charlie", lastName: "Webb", age: 10, hasDriverLicense: false, isAmerican: true), 
 Person(firstName: "Alex", lastName: "Zunino", age: 34, hasDriverLicense: true, isAmerican: true)]
```

## Thanks

A big thank you to Jérôme Alves ([elegantswift.com](http://elegantswift.com)) for coming up with the right modelization to allow sorting on multiple properties with heterogenous type.

# CoordinatorPlus

A protocol-oriented approach to the Coordinator app architecture pattern.

<p>
    <img src="https://github.com/richardpiazza/CoordinatorPlus/workflows/Swift/badge.svg?branch=main" />
    <img src="https://img.shields.io/badge/Swift-5.2-orange.svg" />
    <a href="https://twitter.com/richardpiazza">
        <img src="https://img.shields.io/badge/twitter-@richardpiazza-blue.svg?style=flat" alt="Twitter: @richardpiazza" />
    </a>
</p>

## Installation

**CoordinatorPlus** is distributed using the [Swift Package Manager](https://swift.org/package-manager). To install it into a project, add it 
as a dependency within your `Package.swift` manifest:

```swift
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/richardpiazza/CoordinatorPlus.git", from: "0.1.0")
    ],
    ...
)
```

Then import the **CoordinatorPlus** packages wherever you'd like to use it:

```swift
import CoordinatorPlus
```

## Why the 'Protocol-Oriented' approach?

Many projects use this architecture pattern, and each have a slightly different implementation.

Implementing the architecture through protocols and protocol extensions allows for simple implementations with minimal need to customize 
the handling and presentation of Coordinators & View Controllers.

This reduces the differences on a project-by-project basis and improves the comprehension and understanding of all those who interact with 
the framework.

## Features

The primary classes to note are:
* `AppCoordinator`
* `Task`
* `TaskCoordinator`
* `TaskCoordinatorDelegate`

All of the other files fall outside of what someone could consider a _standard_ Coordinated MVC architectural pattern. The purpose of these 
files is to provide default/sample implementations for specific use cases when used on a `UIKit` platform. This implement is rather 
_opinionated_.

## References

Heavily influenced by [Josh Sullivan's](https://github.com/JoshuaSullivan) [article](http://www.chibicode.org/?p=121) and example project 
[BeyondViewControllers](https://github.com/JoshuaSullivan).

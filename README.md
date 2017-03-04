# Goban
[![Build Status](https://travis-ci.org/Boris-Em/Goban.svg)](https://travis-ci.org/Boris-Em/Goban)
[![license](https://img.shields.io/github/license/mashape/apistatus.svg?maxAge=2592000?style=plastic)](https://github.com/Boris-Em/Goban/blob/master/LICENSE)

**Goban** is an open source library designed for the game of Go, also known as Baduk or Weiqi.  
While currently working, the project is not yet stable, and up until the v1.0 is released, breaking changes should be expected.

## Architecture

The project is architectured around two distincts, independent components:
- **GobanView**: the UI representation of the go board.
- **GobanManager**: the logic around a game of Go, including handling SGF files.

Those two components can be used independently of each other. For example, it is possible to use `GobanView` hooked up to a custom manager to handle the logic.

### GoabanView

[*Full documentation*]()

*img*

`GobanView` is a highly customizable `UIView` subclass representing a go board. Please note that it's not responsible for handling the touch inputs, only detecting and passing them through a delegate.  
A `GobanView` instance is "dumb" and must be managed in order to handle the game's logic and progression.

### GobanManager

[*Full documentation*]()


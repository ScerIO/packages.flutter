## 2.0.0-dev.4

* SliverList & SliverGrid now requires scrollController (From custom `CustomScrollView`). It is necessary in order to find out in which direction the widget scrolls in order to play the animation in the corresponding direction
* `hideWhenGoingBeyond` renamed to `reAnimateOnVisibility` & works with all widgets of the library normally

## 2.0.0-dev.3

* Fixed reanimate on view unmount
* Added `hideWhenGoingBeyond` value Hide the element when it approaches the frame of the screen so that in the future, when it falls into the visibility  range, the animation can be played again. The appearance animation will also play when the item is redrawn. Redrawing is peculiar for all list \ grid views with builder methods

## 2.0.0-dev.2

* Replace list gif in readme

## 2.0.0-dev.1

* Improvement animation algorithm for `AutoAnimatedList`, `AutoAnimatedSliverList`, `AutoAnimatedGrid`, `AutoAnimatedSliverGrid`. 
Now animations start on scroll (element visibility change)

## 1.4.0-dev.1

* Added `AnimateOnVisibilityChange` & `AnimateOnVisibilityWrapper`

## 1.3.0

* Fixed lexical error in `AutoAnimatedIconButton` (`firstToolip` & `secondToolip` renamed to `firstTooltip` & secondTooltip)

## 1.3.0-dev.5

* Fixed error when timer not initialized

## 1.3.0-dev.4

* Fixed items auto additions after animation end

## 1.3.0-dev.3

* Fixed retry animation on items count change
* Marked `itemCount` required 
* Removed deprecated props

## 1.3.0-dev.2

* Added `AutoAnimatedGrid`
* Added `AutoAnimatedSliverGrid`

## 1.3.0-dev.1

* Added `AutoAnimatedSliverList`

## 1.2.3

* Forward animation on items count changed in `AutoAnimatedList`

## 1.2.2 

* Fixed dispose in `AutoAnimatedIconButton`

## 1.2.1

* Fixed auto setting state on rebuild widget for `AutoAnimatedIconButton`

## 1.2.0

* Added constructor `AutoAnimatedIconButton.externalState` with `iconState` property

## 1.1.0

* Added `AutoAnimatedListState.sepparated`
* Added `AutoAnimatedIconButton`
* Optimized performance


## 1.0.1

* Fixed screenshots paths for pub.dev

## 1.0.0

* Initial release.

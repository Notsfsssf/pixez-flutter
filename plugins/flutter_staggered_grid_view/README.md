# flutter_staggered_grid_view

A Flutter staggered grid view which supports multiple columns with rows of varying sizes.

[![Pub](https://img.shields.io/pub/v/flutter_staggered_grid_view.svg)](https://pub.dartlang.org/packages/flutter_staggered_grid_view)
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=QTT34M25RDNL6)

![Screenshot](https://raw.githubusercontent.com/letsar/flutter_staggered_grid_view/master/doc/images/example_01.PNG)

## Features

* Configurable cross-axis count or max cross-axis extent like the [GridView](https://docs.flutter.io/flutter/widgets/GridView-class.html)
* Tiles can have a fixed main-axis extent, or a multiple of the cell's length.
* Configurable main-axis and cross-axis margins between tiles.
* SliverStaggeredGrid for using in a [CustomScrollView](https://docs.flutter.io/flutter/widgets/CustomScrollView-class.html).
* Staggered and Spannable grid layouts.

![Screenshot](https://raw.githubusercontent.com/letsar/flutter_staggered_grid_view/master/doc/images/staggered_1.gif)
![Screenshot](https://raw.githubusercontent.com/letsar/flutter_staggered_grid_view/master/doc/images/spannable_1.gif)
* Tiles can fit the content in the main axis.

![Screenshot](https://raw.githubusercontent.com/letsar/flutter_staggered_grid_view/master/doc/images/dynamic_tile_sizes.gif)

## Getting started

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  ...
  flutter_staggered_grid_view: "^0.2.7"
```

In your library add the following import:

```dart
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
```

For help getting started with Flutter, view the online [documentation](https://flutter.io/).

## Example

![Screenshot_Example](https://raw.githubusercontent.com/letsar/flutter_staggered_grid_view/master/doc/images/example_02.PNG)

```dart
new StaggeredGridView.countBuilder(
  crossAxisCount: 4,
  itemCount: 8,
  itemBuilder: (BuildContext context, int index) => new Container(
      color: Colors.green,
      child: new Center(
        child: new CircleAvatar(
          backgroundColor: Colors.white,
          child: new Text('$index'),
        ),
      )),
  staggeredTileBuilder: (int index) =>
      new StaggeredTile.count(2, index.isEven ? 2 : 1),
  mainAxisSpacing: 4.0,
  crossAxisSpacing: 4.0,
)
```

You can find more examples in the [Example](https://github.com/letsar/flutter_staggered_grid_view/tree/master/example) project.

## Constructors

The `StaggeredGridView` follow the same constructors convention than the [GridView](https://docs.flutter.io/flutter/widgets/GridView-class.html).  
There are two more constructors: `countBuilder` and `extentBuilder`. These constructors allow you to define a builder for the layout and a builder for the children.

## Tiles
A StaggeredGridView needs to know how to display each tile, and what widget is associated with a tile. 

A tile needs to have a fixed number of cell to occupy in the cross axis.
For the extent in the main axis you have 3 options:
* You want a fixed number of cells => use `StaggeredTile.count`.
* You want a fixed extent => use `StaggeredTile.extent`.
* You want a variable extent, defined by the content of the tile itself => use `StaggeredTile.fit`.

## Changelog

Please see the [Changelog](https://github.com/letsar/flutter_staggered_grid_view/blob/master/CHANGELOG.md) page to know what's recently changed.

## Contributions

Feel free to contribute to this project.

If you find a bug or want a feature, but don't know how to fix/implement it, please fill an [issue](https://github.com/letsar/flutter_staggered_grid_view/issues).  
If you fixed a bug or implemented a new feature, please send a [pull request](https://github.com/letsar/flutter_staggered_grid_view/pulls).
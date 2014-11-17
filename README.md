SwiftChart
===========

A line & area chart library for iOS, written in swift.

![swift](https://cloud.githubusercontent.com/assets/120693/5063755/dcfc9da0-6df3-11e4-9432-974e77a863ed.png)

**Main features**

* Multiple series
* Works with signed floats
* Touch events
* Partially filled series
* Highly customizable

**Example**

```swift
let chart = Chart()
let serie = ChartSerie([0, 6, 2, 8, 4, 7, 3, 10, 8])
serie.color = ChartColors.greenColor()
chart.addSerie(serie)
```

More examples can be found in the project.

## Content

This library contains:
- the [Chart](SwiftChart/Chart/Chart.swift) main class, to initialize and configure the chart content, e.g. for adding series or setting up the chart's appearance
- the [ChartSeries](SwiftChart/Chart/ChartSeries.swift) class, needed to add data to the chart and configure the aspect of each serie
- the [ChartDelegate](SwiftChart/Chart/Chart.swift) protocol, which tells your views about touch events
- the [ChartColor](SwiftChart/Chart/ChartColors.swift) struct, an handy shortcut for some predefined colors

## Installation

Add the content of the [Chart folder](SwiftChart/Chart) to your project.

## Usage

### To initialize a chart

The chart can be initialized with the Interface Builder. Simply drag a UIView into the scene and assign to it the `Chart` custom class:
 
![Example](https://cloud.githubusercontent.com/assets/120693/5063826/c01f26d2-6df6-11e4-8122-cb086709d96c.png)

To initialize it programmatically, you can use the `new Chart(frame: ...)` initializer, which requires a `frame`:

```swift
var chart = new Chart(frame: CGRect(x: 0, y: 0, width: 100, height: 200))
```

or, if you prefer to autolayout, set the frame to `0` and add constraint manually later in the code:

```swift
var chart = new Chart(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
// add constraints now
```


### To add series to the chart

You need to initialize each serie before adding them to the chart. Using the `ChartSerie` class, you initialize them with their y-values:

```swift
var serie = new ChartSerie([0, 6, 2, 8, 4, 7, 3, 10, 8])
chart.addSerie(serie)
```

By default, the values on the x-axis are the progressive index of the passed array (i.e. `[0, 1, 2, 3...]`) but you can specify those values as *an array of x, y touples* as well:

```swift
var serie = new ChartSerie([(x: 0, y: 0), (x: 0.5, y: 6), (x: 1.2, y: 2)...])
chart.addSerie(serie)
```

### To respond to touch events

Use the `ChartDelegate` protocol in your classes, i.e. in a `UIViewController`:

```swift
class MyViewController: UIViewController, ChartDelegate {
    override func viewDidLoad() {
        var chart = new Chart(frame: CGRect(x: 0, y: 0, width: 100, height: 200))
        chart.delegate = self
    }
    
    // Chart delegate
    func didTouchChart(chart: Chart, indexes: Array<Int?>, x: Float, left: CGFloat) {
        // Do something on touch
    }
    
    func didFinishTouchingChart(chart: Chart) {
        // Do something when finished
    }
}
```

## Reference

### `Chart` class

#### Labels

* `xLabelsFormatter`: formatter for the labels on the x-axis.
* `xLabelsTextAlignment`: text-alignment for the x-labels.
* `yLabelsFormatter`: Formatter for the labels on the y-axis.
* `yLabelsOnRightSide`: Place the y-labels on the right side.
* `labelFont`: Font used for the labels.
* `labelColor`: Color of the labels.

#### Axis and grid

_continue..._

## Credits
This project was originally a fork of [swift-linechart](https://github.com/zemirco/swift-linechart).
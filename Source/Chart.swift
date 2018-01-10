//
//  Chart.swift
//
//  Created by Giampaolo Bellavite on 07/11/14.
//  Copyright (c) 2014 Giampaolo Bellavite. All rights reserved.
//

import UIKit

public protocol ChartDelegate: class {

    /**
    Tells the delegate that the specified chart has been touched.

    - parameter chart: The chart that has been touched.
    - parameter indexes: Each element of this array contains the index of the data that has been touched, one for each 
      series. If the series hasn't been touched, its index will be nil.
    - parameter x: The value on the x-axis that has been touched.
    - parameter left: The distance from the left side of the chart.

    */
    func didTouchChart(_ chart: Chart, indexes: [Int?], x: Double, left: CGFloat)

    /**
    Tells the delegate that the user finished touching the chart. The user will 
    "finish" touching the chart only swiping left/right outside the chart.

    - parameter chart: The chart that has been touched.

    */
    func didFinishTouchingChart(_ chart: Chart)
    /**
     Tells the delegate that the user ended touching the chart. The user 
     will "end" touching the chart whenever the touchesDidEnd method is 
     being called.
     
     - parameter chart: The chart that has been touched.
     
     */
    func didEndTouchingChart(_ chart: Chart)
}

/**
Represent the x- and the y-axis values for each point in a chart series.
*/
typealias ChartPoint = (x: Double, y: Double)

/**
Set the a x-label orientation.
*/
public enum ChartLabelOrientation {
    case horizontal
    case vertical
}

@IBDesignable
open class Chart: UIControl {

    // MARK: Options

    @IBInspectable
    open var identifier: String?

    /**
    Series to display in the chart.
    */
    open var series: [ChartSeries] = [] {
        didSet {
            setNeedsDisplay()
        }
    }

    /**
    The values to display as labels on the x-axis. You can format these values  with the `xLabelFormatter` attribute. 
    As default, it will display the values of the series which has the most data.
    */
    open var xLabels: [Double]?

    /**
    Formatter for the labels on the x-axis. `index` represents the `xLabels` index, `value` its value.
    */
    open var xLabelsFormatter = { (labelIndex: Int, labelValue: Double) -> String in
        String(Int(labelValue))
    }

    /**
    Text alignment for the x-labels.
    */
    open var xLabelsTextAlignment: NSTextAlignment = .left

    /**
    Orientation for the x-labels.
    */
    open var xLabelsOrientation: ChartLabelOrientation = .horizontal

    /**
    Skip the last x-label. Setting this to false may make the label overflow the frame width.
    */
    open var xLabelsSkipLast: Bool = true

    /**
    Values to display as labels of the y-axis. If not specified, will display the lowest, the middle and the highest
    values.
    */
    open var yLabels: [Double]?

    /**
    Formatter for the labels on the y-axis.
    */
    open var yLabelsFormatter = { (labelIndex: Int, labelValue: Double) -> String in
        String(Int(labelValue))
    }

    /**
    Displays the y-axis labels on the right side of the chart.
    */
    open var yLabelsOnRightSide: Bool = false

    /**
    Font used for the labels.
    */
    open var labelFont: UIFont? = UIFont.systemFont(ofSize: 12)

    /**
    The color used for the labels.
    */
    @IBInspectable
    open var labelColor: UIColor = UIColor.black

    /**
    Color for the axes.
    */
    @IBInspectable
    open var axesColor: UIColor = UIColor.gray.withAlphaComponent(0.3)

    /**
    Color for the grid.
    */
    @IBInspectable
    open var gridColor: UIColor = UIColor.gray.withAlphaComponent(0.3)
    /**
    Enable the lines for the labels on the x-axis
    */
    open var showXLabelsAndGrid: Bool = true
    /**
    Enable the lines for the labels on the y-axis
    */
    open var showYLabelsAndGrid: Bool = true

    /**
    Height of the area at the bottom of the chart, containing the labels for the x-axis.
    */
    open var bottomInset: CGFloat = 20

    /**
    Height of the area at the top of the chart, acting a padding to make place for the top y-axis label.
    */
    open var topInset: CGFloat = 20

    /**
    Width of the chart's lines.
    */
    @IBInspectable
    open var lineWidth: CGFloat = 2

    /**
    Delegate for listening to Chart touch events.
    */
    weak open var delegate: ChartDelegate?

    /**
    Custom minimum value for the x-axis.
    */
    open var minX: Double?

    /**
    Custom minimum value for the y-axis.
    */
    open var minY: Double?

    /**
    Custom maximum value for the x-axis.
    */
    open var maxX: Double?

    /**
    Custom maximum value for the y-axis.
    */
    open var maxY: Double?

    /**
    Color for the highlight line.
    */
    open var highlightLineColor = UIColor.gray

    /**
    Width for the highlight line.
    */
    open var highlightLineWidth: CGFloat = 0.5

    /**
    Hide the highlight line when touch event ends, e.g. when stop swiping over the chart
    */
    open var hideHighlightLineOnTouchEnd = false

    /**
    Alpha component for the area color.
    */
    open var areaAlphaComponent: CGFloat = 0.1

    // MARK: Private variables

    fileprivate var highlightShapeLayer: CAShapeLayer!
    fileprivate var layerStore: [CAShapeLayer] = []

    fileprivate var drawingHeight: CGFloat!
    fileprivate var drawingWidth: CGFloat!

    // Minimum and maximum values represented in the chart
    fileprivate var min: ChartPoint!
    fileprivate var max: ChartPoint!

    // Represent a set of points corresponding to a segment line on the chart.
    typealias ChartLineSegment = [ChartPoint]

    // MARK: initializations

    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    convenience public init() {
        self.init(frame: .zero)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = UIColor.clear
        contentMode = .redraw // redraw rects on bounds change
    }

    override open func draw(_ rect: CGRect) {
        #if TARGET_INTERFACE_BUILDER
            drawIBPlaceholder()
            #else
            drawChart()
        #endif
    }

    /**
    Adds a chart series.
    */
    open func add(_ series: ChartSeries) {
        self.series.append(series)
    }

    /**
    Adds multiple chart series.
    */
    open func add(_ series: [ChartSeries]) {
        for s in series {
            add(s)
        }
    }

    /**
    Remove the series at the specified index.
    */
    open func removeSeriesAt(_ index: Int) {
        series.remove(at: index)
    }

    /**
    Remove all the series.
    */
    open func removeAllSeries() {
        series = []
    }

    /**
    Return the value for the specified series at the given index.
    */
    open func valueForSeries(_ seriesIndex: Int, atIndex dataIndex: Int?) -> Double? {
        if dataIndex == nil { return nil }
        let series = self.series[seriesIndex] as ChartSeries
        return series.data[dataIndex!].y
    }

    fileprivate func drawIBPlaceholder() {
        let placeholder = UIView(frame: self.frame)
        placeholder.backgroundColor = UIColor(red: 0.93, green: 0.93, blue: 0.93, alpha: 1)
        let label = UILabel()
        label.text = "Chart"
        label.font = UIFont.systemFont(ofSize: 28)
        label.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        label.sizeToFit()
        label.frame.origin.x += frame.width/2 - (label.frame.width / 2)
        label.frame.origin.y += frame.height/2 - (label.frame.height / 2)

        placeholder.addSubview(label)
        addSubview(placeholder)
    }

    fileprivate func drawChart() {

        drawingHeight = bounds.height - bottomInset - topInset
        drawingWidth = bounds.width

        let minMax = getMinMax()
        min = minMax.min
        max = minMax.max

        highlightShapeLayer = nil

        // Remove things before drawing, e.g. when changing orientation

        for view in self.subviews {
            view.removeFromSuperview()
        }
        for layer in layerStore {
            layer.removeFromSuperlayer()
        }
        layerStore.removeAll()

        // Draw content

        for (index, series) in self.series.enumerated() {

            // Separate each line in multiple segments over and below the x axis
            let segments = Chart.segmentLine(series.data as ChartLineSegment, zeroLevel: series.colors.zeroLevel)

            segments.forEach({ segment in
                let scaledXValues = scaleValuesOnXAxis( segment.map { $0.x } )
                let scaledYValues = scaleValuesOnYAxis( segment.map { $0.y } )

                if series.line {
                    drawLine(scaledXValues, yValues: scaledYValues, seriesIndex: index)
                }
                if series.area {
                    drawArea(scaledXValues, yValues: scaledYValues, seriesIndex: index)
                }
            })
        }

        drawAxes()

        if showXLabelsAndGrid && (xLabels != nil || series.count > 0) {
            drawLabelsAndGridOnXAxis()
        }
        if showYLabelsAndGrid && (yLabels != nil || series.count > 0) {
            drawLabelsAndGridOnYAxis()
        }

    }

    // MARK: - Scaling

    fileprivate func getMinMax() -> (min: ChartPoint, max: ChartPoint) {
        // Start with user-provided values

        var min = (x: minX, y: minY)
        var max = (x: maxX, y: maxY)

        // Check in datasets

        for series in self.series {
            let xValues =  series.data.map { $0.x }
            let yValues =  series.data.map { $0.y }

            let newMinX = xValues.minOrZero()
            let newMinY = yValues.minOrZero()
            let newMaxX = xValues.maxOrZero()
            let newMaxY = yValues.maxOrZero()

            if min.x == nil || newMinX < min.x! { min.x = newMinX }
            if min.y == nil || newMinY < min.y! { min.y = newMinY }
            if max.x == nil || newMaxX > max.x! { max.x = newMaxX }
            if max.y == nil || newMaxY > max.y! { max.y = newMaxY }
        }

        // Check in labels

        if let xLabels = self.xLabels {
            let newMinX = xLabels.minOrZero()
            let newMaxX = xLabels.maxOrZero()
            if min.x == nil || newMinX < min.x! { min.x = newMinX }
            if max.x == nil || newMaxX > max.x! { max.x = newMaxX }
        }

        if let yLabels = self.yLabels {
            let newMinY = yLabels.minOrZero()
            let newMaxY = yLabels.maxOrZero()
            if min.y == nil || newMinY < min.y! { min.y = newMinY }
            if max.y == nil || newMaxY > max.y! { max.y = newMaxY }
        }

        if min.x == nil { min.x = 0 }
        if min.y == nil { min.y = 0 }
        if max.x == nil { max.x = 0 }
        if max.y == nil { max.y = 0 }

        return (min: (x: min.x!, y: min.y!), max: (x: max.x!, max.y!))
    }

    fileprivate func scaleValuesOnXAxis(_ values: [Double]) -> [Double] {
        let width = Double(drawingWidth)

        var factor: Double
        if max.x - min.x == 0 {
            factor = 0
        } else {
            factor = width / (max.x - min.x)
        }

        let scaled = values.map { factor * ($0 - self.min.x) }
        return scaled
    }

    fileprivate func scaleValuesOnYAxis(_ values: [Double]) -> [Double] {
        let height = Double(drawingHeight)
        var factor: Double
        if max.y - min.y == 0 {
            factor = 0
        } else {
            factor = height / (max.y - min.y)
        }

        let scaled = values.map { Double(self.topInset) + height - factor * ($0 - self.min.y) }

        return scaled
    }

    fileprivate func scaleValueOnYAxis(_ value: Double) -> Double {
        let height = Double(drawingHeight)
        var factor: Double
        if max.y - min.y == 0 {
            factor = 0
        } else {
            factor = height / (max.y - min.y)
        }

        let scaled = Double(self.topInset) + height - factor * (value - min.y)
        return scaled
    }

    fileprivate func getZeroValueOnYAxis(zeroLevel: Double) -> Double {
        if min.y > zeroLevel {
            return scaleValueOnYAxis(min.y)
        } else {
            return scaleValueOnYAxis(zeroLevel)
        }
    }

    // MARK: - Drawings

    fileprivate func drawLine(_ xValues: [Double], yValues: [Double], seriesIndex: Int) {
        // YValues are "reverted" from top to bottom, so 'above' means <= level
        let isAboveZeroLine = yValues.max()! <= self.scaleValueOnYAxis(series[seriesIndex].colors.zeroLevel)
        let path = CGMutablePath()
        path.move(to: CGPoint(x: CGFloat(xValues.first!), y: CGFloat(yValues.first!)))
        for i in 1..<yValues.count {
            let y = yValues[i]
            path.addLine(to: CGPoint(x: CGFloat(xValues[i]), y: CGFloat(y)))
        }

        let lineLayer = CAShapeLayer()
        lineLayer.frame = self.bounds
        lineLayer.path = path

        if isAboveZeroLine {
            lineLayer.strokeColor = series[seriesIndex].colors.above.cgColor
        } else {
            lineLayer.strokeColor = series[seriesIndex].colors.below.cgColor
        }
        lineLayer.fillColor = nil
        lineLayer.lineWidth = lineWidth
        lineLayer.lineJoin = kCALineJoinBevel

        self.layer.addSublayer(lineLayer)

        layerStore.append(lineLayer)
    }

    fileprivate func drawArea(_ xValues: [Double], yValues: [Double], seriesIndex: Int) {
        // YValues are "reverted" from top to bottom, so 'above' means <= level
        let isAboveZeroLine = yValues.max()! <= self.scaleValueOnYAxis(series[seriesIndex].colors.zeroLevel)
        let area = CGMutablePath()
        let zero = CGFloat(getZeroValueOnYAxis(zeroLevel: series[seriesIndex].colors.zeroLevel))

        area.move(to: CGPoint(x: CGFloat(xValues[0]), y: zero))
        for i in 0..<xValues.count {
            area.addLine(to: CGPoint(x: CGFloat(xValues[i]), y: CGFloat(yValues[i])))
        }
        area.addLine(to: CGPoint(x: CGFloat(xValues.last!), y: zero))
        let areaLayer = CAShapeLayer()
        areaLayer.frame = self.bounds
        areaLayer.path = area
        areaLayer.strokeColor = nil
        if isAboveZeroLine {
            areaLayer.fillColor = series[seriesIndex].colors.above.withAlphaComponent(areaAlphaComponent).cgColor
        } else {
            areaLayer.fillColor = series[seriesIndex].colors.below.withAlphaComponent(areaAlphaComponent).cgColor
        }
        areaLayer.lineWidth = 0

        self.layer.addSublayer(areaLayer)

        layerStore.append(areaLayer)
    }

    fileprivate func drawAxes() {
        let context = UIGraphicsGetCurrentContext()!
        context.setStrokeColor(axesColor.cgColor)
        context.setLineWidth(0.5)

        // horizontal axis at the bottom
        context.move(to: CGPoint(x: CGFloat(0), y: drawingHeight + topInset))
        context.addLine(to: CGPoint(x: CGFloat(drawingWidth), y: drawingHeight + topInset))
        context.strokePath()

        // horizontal axis at the top
        context.move(to: CGPoint(x: CGFloat(0), y: CGFloat(0)))
        context.addLine(to: CGPoint(x: CGFloat(drawingWidth), y: CGFloat(0)))
        context.strokePath()

        // horizontal axis when y = 0
        if min.y < 0 && max.y > 0 {
            let y = CGFloat(getZeroValueOnYAxis(zeroLevel: 0))
            context.move(to: CGPoint(x: CGFloat(0), y: y))
            context.addLine(to: CGPoint(x: CGFloat(drawingWidth), y: y))
            context.strokePath()
        }

        // vertical axis on the left
        context.move(to: CGPoint(x: CGFloat(0), y: CGFloat(0)))
        context.addLine(to: CGPoint(x: CGFloat(0), y: drawingHeight + topInset))
        context.strokePath()

        // vertical axis on the right
        context.move(to: CGPoint(x: CGFloat(drawingWidth), y: CGFloat(0)))
        context.addLine(to: CGPoint(x: CGFloat(drawingWidth), y: drawingHeight + topInset))
        context.strokePath()
    }

    fileprivate func drawLabelsAndGridOnXAxis() {
        let context = UIGraphicsGetCurrentContext()!
        context.setStrokeColor(gridColor.cgColor)
        context.setLineWidth(0.5)

        var labels: [Double]
        if xLabels == nil {
            // Use labels from the first series
            labels = series[0].data.map({ (point: ChartPoint) -> Double in
                return point.x })
        } else {
            labels = xLabels!
        }

        let scaled = scaleValuesOnXAxis(labels)
        let padding: CGFloat = 5
        scaled.enumerated().forEach { (i, value) in
            let x = CGFloat(value)
            let isLastLabel = x == drawingWidth

            // Add vertical grid for each label, except axes on the left and right

            if x != 0 && x != drawingWidth {
                context.move(to: CGPoint(x: x, y: CGFloat(0)))
                context.addLine(to: CGPoint(x: x, y: bounds.height))
                context.strokePath()
            }

            if xLabelsSkipLast && isLastLabel {
                // Do not add label at the most right position
                return
            }

            // Add label
            let label = UILabel(frame: CGRect(x: x, y: drawingHeight, width: 0, height: 0))
            label.font = labelFont
            label.text = xLabelsFormatter(i, labels[i])
            label.textColor = labelColor

            // Set label size
            label.sizeToFit()
            // Center label vertically
            label.frame.origin.y += topInset
            if xLabelsOrientation == .horizontal {
                // Add left padding
                label.frame.origin.y -= (label.frame.height - bottomInset) / 2
                label.frame.origin.x += padding

                // Set label's text alignment
                label.frame.size.width = (drawingWidth / CGFloat(labels.count)) - padding * 2
                label.textAlignment = xLabelsTextAlignment
            } else {
                label.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))

                // Adjust vertical position according to the label's height
                label.frame.origin.y += label.frame.size.height / 2

                // Adjust horizontal position as the series line
                label.frame.origin.x = x
                if xLabelsTextAlignment == .center {
                    // Align horizontally in series
                    label.frame.origin.x += ((drawingWidth / CGFloat(labels.count)) / 2) - (label.frame.size.width / 2)
                } else {
                    // Give some space from the vertical line
                    label.frame.origin.x += padding
                }
            }
            self.addSubview(label)
        }
    }

    fileprivate func drawLabelsAndGridOnYAxis() {
        let context = UIGraphicsGetCurrentContext()!
        context.setStrokeColor(gridColor.cgColor)
        context.setLineWidth(0.5)

        var labels: [Double]
        if yLabels == nil {
            labels = [(min.y + max.y) / 2, max.y]
            if yLabelsOnRightSide || min.y != 0 {
                labels.insert(min.y, at: 0)
            }
        } else {
            labels = yLabels!
        }

        let scaled = scaleValuesOnYAxis(labels)
        let padding: CGFloat = 5
        let zero = CGFloat(getZeroValueOnYAxis(zeroLevel: 0))

        scaled.enumerated().forEach { (i, value) in

            let y = CGFloat(value)

            // Add horizontal grid for each label, but not over axes
            if y != drawingHeight + topInset && y != zero {

                context.move(to: CGPoint(x: CGFloat(0), y: y))
                context.addLine(to: CGPoint(x: self.bounds.width, y: y))
                if labels[i] != 0 {
                    // Horizontal grid for 0 is not dashed
                    context.setLineDash(phase: CGFloat(0), lengths: [CGFloat(5)])
                } else {
                    context.setLineDash(phase: CGFloat(0), lengths: [])
                }
                context.strokePath()
            }

            let label = UILabel(frame: CGRect(x: padding, y: y, width: 0, height: 0))
            label.font = labelFont
            label.text = yLabelsFormatter(i, labels[i])
            label.textColor = labelColor
            label.sizeToFit()

            if yLabelsOnRightSide {
                label.frame.origin.x = drawingWidth
                label.frame.origin.x -= label.frame.width + padding
            }

            // Labels should be placed above the horizontal grid
            label.frame.origin.y -= label.frame.height

            self.addSubview(label)
        }
        UIGraphicsEndImageContext()
    }

    // MARK: - Touch events

    fileprivate func drawHighlightLineFromLeftPosition(_ left: CGFloat) {
        if let shapeLayer = highlightShapeLayer {
            // Use line already created
            let path = CGMutablePath()

            path.move(to: CGPoint(x: left, y: 0))
            path.addLine(to: CGPoint(x: left, y: drawingHeight + topInset))
            shapeLayer.path = path
        } else {
            // Create the line
            let path = CGMutablePath()

            path.move(to: CGPoint(x: left, y: CGFloat(0)))
            path.addLine(to: CGPoint(x: left, y: drawingHeight + topInset))
            let shapeLayer = CAShapeLayer()
            shapeLayer.frame = self.bounds
            shapeLayer.path = path
            shapeLayer.strokeColor = highlightLineColor.cgColor
            shapeLayer.fillColor = nil
            shapeLayer.lineWidth = highlightLineWidth

            highlightShapeLayer = shapeLayer
            layer.addSublayer(shapeLayer)
            layerStore.append(shapeLayer)
        }
    }

    func handleTouchEvents(_ touches: Set<UITouch>, event: UIEvent!) {
        let point = touches.first!
        let left = point.location(in: self).x
        let x = valueFromPointAtX(left)

        if left < 0 || left > (drawingWidth as CGFloat) {
            // Remove highlight line at the end of the touch event
            if let shapeLayer = highlightShapeLayer {
                shapeLayer.path = nil
            }
            delegate?.didFinishTouchingChart(self)
            return
        }

        drawHighlightLineFromLeftPosition(left)

        if delegate == nil {
            return
        }

        var indexes: [Int?] = []

        for series in self.series {
            var index: Int? = nil
            let xValues = series.data.map({ (point: ChartPoint) -> Double in
                return point.x })
            let closest = Chart.findClosestInValues(xValues, forValue: x)
            if closest.lowestIndex != nil && closest.highestIndex != nil {
                // Consider valid only values on the right
                index = closest.lowestIndex
            }
            indexes.append(index)
        }
        delegate!.didTouchChart(self, indexes: indexes, x: x, left: left)
    }

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouchEvents(touches, event: event)
    }

    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouchEvents(touches, event: event)
        if self.hideHighlightLineOnTouchEnd {
            if let shapeLayer = highlightShapeLayer {
                shapeLayer.path = nil
            }
        }
        delegate?.didEndTouchingChart(self)
    }

    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouchEvents(touches, event: event)
    }

    // MARK: - Utilities

    fileprivate func valueFromPointAtX(_ x: CGFloat) -> Double {
        let value = ((max.x-min.x) / Double(drawingWidth)) * Double(x) + min.x
        return value
    }

    fileprivate func valueFromPointAtY(_ y: CGFloat) -> Double {
        let value = ((max.y - min.y) / Double(drawingHeight)) * Double(y) + min.y
        return -value
    }

    fileprivate class func findClosestInValues(
        _ values: [Double],
        forValue value: Double
    ) -> (
            lowestValue: Double?,
            highestValue: Double?,
            lowestIndex: Int?,
            highestIndex: Int?
        ) {
        var lowestValue: Double?, highestValue: Double?, lowestIndex: Int?, highestIndex: Int?

        values.enumerated().forEach { (i, currentValue) in

            if currentValue <= value && (lowestValue == nil || lowestValue! < currentValue) {
                lowestValue = currentValue
                lowestIndex = i
            }
            if currentValue >= value && (highestValue == nil || highestValue! > currentValue) {
                highestValue = currentValue
                highestIndex = i
            }

        }
        return (
            lowestValue: lowestValue,
            highestValue: highestValue,
            lowestIndex: lowestIndex,
            highestIndex: highestIndex
        )
    }

    /**
    Segment a line in multiple lines when the line touches the x-axis, i.e. separating
    positive from negative values.
    */
    fileprivate class func segmentLine(_ line: ChartLineSegment, zeroLevel: Double) -> [ChartLineSegment] {
        var segments: [ChartLineSegment] = []
        var segment: ChartLineSegment = []

        line.enumerated().forEach { (i, point) in
            segment.append(point)
            if i < line.count - 1 {
                let nextPoint = line[i+1]
                if point.y >= zeroLevel && nextPoint.y < zeroLevel || point.y < zeroLevel && nextPoint.y >= zeroLevel {
                    // The segment intersects zeroLevel, close the segment with the intersection point
                    let closingPoint = Chart.intersectionWithLevel(point, and: nextPoint, level: zeroLevel)
                    segment.append(closingPoint)
                    segments.append(segment)
                    // Start a new segment
                    segment = [closingPoint]
                }
            } else {
                // End of the line
                segments.append(segment)
            }
        }
        return segments
    }

    /**
    Return the intersection of a line between two points and 'y = level' line
    */
    fileprivate class func intersectionWithLevel(_ p1: ChartPoint, and p2: ChartPoint, level: Double) -> ChartPoint {
        let dy1 = level - p1.y
        let dy2 = level - p2.y
        return (x: (p2.x * dy1 - p1.x * dy2) / (dy1 - dy2), y: level)
    }
}

extension Sequence where Element == Double {
    func minOrZero() -> Double {
        return self.min() ?? 0.0
    }
    func maxOrZero() -> Double {
        return self.max() ?? 0.0
    }
}

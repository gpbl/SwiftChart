//
//  Chart.swift
//
//  Created by Giampaolo Bellavite on 07/11/14.
//  Copyright (c) 2014 Giampaolo Bellavite. All rights reserved.
//

import UIKit

public protocol ChartDelegate {

    /**
    Tells the delegate that the specified chart has been touched.

    - parameter chart: The chart that has been touched.
    - parameter indexes: Each element of this array contains the index of the data that has been touched, one for each series.
            If the series hasn't been touched, its index will be nil.
    - parameter x: The value on the x-axis that has been touched.
    - parameter left: The distance from the left side of the chart.

    */
    func didTouchChart(chart: Chart, indexes: Array<Int?>, x: Float, left: CGFloat)

    /**
    Tells the delegate that the user finished touching the chart. The user will "finish" touching the
    chart only swiping left/right outside the chart.

    - parameter chart: The chart that has been touched.

    */
    func didFinishTouchingChart(chart: Chart)
}

/**
Represent the x- and the y-axis values for each point in a chart series.
*/
typealias ChartPoint = (x: Float, y: Float)

@IBDesignable
public class Chart: UIControl {

    // MARK: Options

    @IBInspectable
    public var identifier: String?

    /**
    Series to display in the chart.
    */
    public var series: Array<ChartSeries> = []

    /**
    The values to display as labels on the x-axis. You can format these values with the `xLabelFormatter` attribute.
    As default, it will display the values of the series which has the most data.
    */
    public var xLabels: Array<Float>?

    /**
    Formatter for the labels on the x-axis. The `index` represents the `xLabels` index, `value` its value:
    */
    public var xLabelsFormatter = { (labelIndex: Int, labelValue: Float) -> String in
        String(Int(labelValue))
    }

    /**
    Text alignment for the x-labels
    */
    public var xLabelsTextAlignment: NSTextAlignment = .Left

    /**
    Values to display as labels of the y-axis. If not specified, will display the
    lowest, the middle and the highest values.
    */
    public var yLabels: Array<Float>?

    /**
    Formatter for the labels on the y-axis.
    */
    public var yLabelsFormatter = { (labelIndex: Int, labelValue: Float) -> String in
        String(Int(labelValue))
    }

    /**
    Displays the y-axis labels on the right side of the chart.
    */
    public var yLabelsOnRightSide: Bool = false

    /**
    Font used for the labels.
    */
    public var labelFont: UIFont? = UIFont.systemFontOfSize(12)

    /**
    Font used for the labels.
    */
    @IBInspectable
    public var labelColor: UIColor = UIColor.blackColor()

    /**
    Color for the axes.
    */
    @IBInspectable
    public var axesColor: UIColor = UIColor.grayColor().colorWithAlphaComponent(0.3)

    /**
    Color for the grid.
    */
    @IBInspectable
    public var gridColor: UIColor = UIColor.grayColor().colorWithAlphaComponent(0.3)

    /**
    Height of the area at the bottom of the chart, containing the labels for the x-axis.
    */
    public var bottomInset: CGFloat = 20

    /**
    Height of the area at the top of the chart, acting a padding to make place for the top y-axis label.
    */
    public var topInset: CGFloat = 20

    /**
    Width of the chart's lines.
    */
    @IBInspectable
    public var lineWidth: CGFloat = 2

    /**
    Delegate for listening to Chart touch events.
    */
    public var delegate: ChartDelegate?

    /**
    Custom minimum value for the x-axis.
    */
    public var minX: Float?

    /**
    Custom minimum value for the y-axis.
    */
    public var minY: Float?

    /**
    Custom maximum value for the x-axis.
    */
    public var maxX: Float?

    /**
    Custom maximum value for the y-axis.
    */
    public var maxY: Float?

    /**
    Color for the highlight line.
    */
    public var highlightLineColor = UIColor.grayColor()

    /**
    Width for the highlight line.
    */
    public var highlightLineWidth: CGFloat = 0.5

    /**
    Alpha component for the area's color.
    */
    public var areaAlphaComponent: CGFloat = 0.1

    // MARK: Private variables

    private var highlightShapeLayer: CAShapeLayer!
    private var layerStore: Array<CAShapeLayer> = []

    private var drawingHeight: CGFloat!
    private var drawingWidth: CGFloat!

    // Minimum and maximum values represented in the chart
    private var min: ChartPoint!
    private var max: ChartPoint!

    // Represent a set of points corresponding to a segment line on the chart.
    typealias ChartLineSegment = Array<ChartPoint>

    // MARK: initializations

    override public init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clearColor()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    convenience public init() {
        self.init(frame: CGRectZero)
    }

    override public func drawRect(rect: CGRect) {
        #if TARGET_INTERFACE_BUILDER
            drawIBPlaceholder()
            #else
            drawChart()
        #endif
    }

    /**
    Adds a chart series.
    */
    public func addSeries(series: ChartSeries) {
        self.series.append(series)
    }

    /**
    Adds multiple series.
    */
    public func addSeries(series: Array<ChartSeries>) {
        for s in series {
            addSeries(s)
        }
    }

    /**
    Remove the series at the specified index.
    */
    public func removeSeriesAtIndex(index: Int) {
        series.removeAtIndex(index)
    }

    /**
    Remove all the series.
    */
    public func removeSeries() {
        series = []
    }

    /**
    Returns the value for the specified series at the given index
    */
    public func valueForSeries(seriesIndex: Int, atIndex dataIndex: Int?) -> Float? {
        if dataIndex == nil { return nil }
        let series = self.series[seriesIndex] as ChartSeries
        return series.data[dataIndex!].y
    }


    private func drawIBPlaceholder() {
        let placeholder = UIView(frame: self.frame)
        placeholder.backgroundColor = UIColor(red: 0.93, green: 0.93, blue: 0.93, alpha: 1)
        let label = UILabel()
        label.text = "Chart"
        label.font = UIFont.systemFontOfSize(28)
        label.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        label.sizeToFit()
        label.frame.origin.x += frame.width/2 - (label.frame.width / 2)
        label.frame.origin.y += frame.height/2 - (label.frame.height / 2)

        placeholder.addSubview(label)
        addSubview(placeholder)
    }

    private func drawChart() {

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

        for (index, series) in self.series.enumerate() {

            // Separate each line in multiple segments over and below the x axis
            let segments = Chart.segmentLine(series.data as ChartLineSegment)

            segments.forEach({ segment in
                let scaledXValues = scaleValuesOnXAxis( segment.map({ return $0.x }) )
                let scaledYValues = scaleValuesOnYAxis( segment.map({ return $0.y }) )

                if series.line {
                    drawLine(xValues: scaledXValues, yValues: scaledYValues, seriesIndex: index)
                }
                if series.area {
                    drawArea(xValues: scaledXValues, yValues: scaledYValues, seriesIndex: index)
                }
            })
        }

        drawAxes()

        if xLabels != nil || series.count > 0 {
            drawLabelsAndGridOnXAxis()
        }
        if yLabels != nil || series.count > 0 {
            drawLabelsAndGridOnYAxis()
        }

    }

    // MARK: - Scaling

    private func getMinMax() -> (min: ChartPoint, max: ChartPoint) {

        // Start with user-provided values

        var min = (x: minX, y: minY)
        var max = (x: maxX, y: maxY)

        // Check in datasets

        for series in self.series {
            let xValues =  series.data.map({ (point: ChartPoint) -> Float in
                return point.x })
            let yValues =  series.data.map({ (point: ChartPoint) -> Float in
                return point.y })

            let newMinX = xValues.minElement()!
            let newMinY = yValues.minElement()!
            let newMaxX = xValues.maxElement()!
            let newMaxY = yValues.maxElement()!

            if min.x == nil || newMinX < min.x! { min.x = newMinX }
            if min.y == nil || newMinY < min.y! { min.y = newMinY }
            if max.x == nil || newMaxX > max.x! { max.x = newMaxX }
            if max.y == nil || newMaxY > max.y! { max.y = newMaxY }
        }

        // Check in labels

        if xLabels != nil {
            let newMinX = (xLabels!).minElement()!
            let newMaxX = (xLabels!).maxElement()!
            if min.x == nil || newMinX < min.x { min.x = newMinX }
            if max.x == nil || newMaxX > max.x { max.x = newMaxX }
        }

        if yLabels != nil {
            let newMinY = (yLabels!).minElement()!
            let newMaxY = (yLabels!).maxElement()!
            if min.y == nil || newMinY < min.y { min.y = newMinY }
            if max.y == nil || newMaxY > max.y { max.y = newMaxY }
        }

        if min.x == nil { min.x = 0 }
        if min.y == nil { min.y = 0 }
        if max.x == nil { max.x = 0 }
        if max.y == nil { max.y = 0 }

        return (min: (x: min.x!, y: min.y!), max: (x: max.x!, max.y!))

    }

    private func scaleValuesOnXAxis(values: Array<Float>) -> Array<Float> {
        let width = Float(drawingWidth)

        var factor: Float
        if max.x - min.x == 0 {
            factor = 0
        } else {
            factor = width / (max.x - min.x)
        }

        let scaled = values.map { factor * ($0 - self.min.x) }
        return scaled
    }

    private func scaleValuesOnYAxis(values: Array<Float>) -> Array<Float> {

        let height = Float(drawingHeight)
        var factor: Float
        if max.y - min.y == 0 {
            factor = 0
        } else {
            factor = height / (max.y - min.y)
        }

        let scaled = values.map { Float(self.topInset) + height - factor * ($0 - self.min.y) }

        return scaled
    }

    private func scaleValueOnYAxis(value: Float) -> Float {

        let height = Float(drawingHeight)
        var factor: Float
        if max.y - min.y == 0 {
            factor = 0
        } else {
            factor = height / (max.y - min.y)
        }

        let scaled = Float(self.topInset) + height - factor * (value - min.y)
        return scaled
    }

    private func getZeroValueOnYAxis() -> Float {
        if min.y > 0 {
            return scaleValueOnYAxis(min.y)
        } else {
            return scaleValueOnYAxis(0)
        }

    }

    // MARK: - Drawings

    private func isVerticalSegmentAboveXAxis(yValues: Array<Float>) -> Bool {

        // YValues are "reverted" from top to bottom, so min is actually the maxz
        let min = yValues.maxElement()!
        let zero = getZeroValueOnYAxis()

        return min <= zero

    }

    private func drawLine(xValues xValues: Array<Float>, yValues: Array<Float>, seriesIndex: Int) -> CAShapeLayer {

        let isAboveXAxis = isVerticalSegmentAboveXAxis(yValues)
        let path = CGPathCreateMutable()

        CGPathMoveToPoint(path, nil, CGFloat(xValues.first!), CGFloat(yValues.first!))

        for i in 1..<yValues.count {
            let y = yValues[i]
            CGPathAddLineToPoint(path, nil, CGFloat(xValues[i]), CGFloat(y))
        }

        let lineLayer = CAShapeLayer()
        lineLayer.frame = self.bounds
        lineLayer.path = path

        if isAboveXAxis {
            lineLayer.strokeColor = series[seriesIndex].colors.above.CGColor
        } else {
            lineLayer.strokeColor = series[seriesIndex].colors.below.CGColor
        }
        lineLayer.fillColor = nil
        lineLayer.lineWidth = lineWidth
        lineLayer.lineJoin = kCALineJoinBevel

        self.layer.addSublayer(lineLayer)

        layerStore.append(lineLayer)

        return lineLayer
    }

    private func drawArea(xValues xValues: Array<Float>, yValues: Array<Float>, seriesIndex: Int) {
        let isAboveXAxis = isVerticalSegmentAboveXAxis(yValues)
        let area = CGPathCreateMutable()
        let zero = CGFloat(getZeroValueOnYAxis())

        CGPathMoveToPoint(area, nil, CGFloat(xValues[0]), zero)

        for i in 0..<xValues.count {
            CGPathAddLineToPoint(area, nil, CGFloat(xValues[i]), CGFloat(yValues[i]))
        }

        CGPathAddLineToPoint(area, nil, CGFloat(xValues.last!), zero)

        let areaLayer = CAShapeLayer()
        areaLayer.frame = self.bounds
        areaLayer.path = area
        areaLayer.strokeColor = nil
        if isAboveXAxis {
            areaLayer.fillColor = series[seriesIndex].colors.above.colorWithAlphaComponent(areaAlphaComponent).CGColor
        } else {
            areaLayer.fillColor = series[seriesIndex].colors.below.colorWithAlphaComponent(areaAlphaComponent).CGColor
        }
        areaLayer.lineWidth = 0

        self.layer.addSublayer(areaLayer)

        layerStore.append(areaLayer)
    }

    private func drawAxes() {

        let context = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(context, axesColor.CGColor)
        CGContextSetLineWidth(context, 0.5)

        // horizontal axis at the bottom
        CGContextMoveToPoint(context, 0, drawingHeight + topInset)
        CGContextAddLineToPoint(context, drawingWidth, drawingHeight + topInset)
        CGContextStrokePath(context)

        // horizontal axis at the top
        CGContextMoveToPoint(context, 0, 0)
        CGContextAddLineToPoint(context, drawingWidth, 0)
        CGContextStrokePath(context)

        // horizontal axis when y = 0
        if min.y < 0 && max.y > 0 {
            let y = CGFloat(getZeroValueOnYAxis())
            CGContextMoveToPoint(context, 0, y)
            CGContextAddLineToPoint(context, drawingWidth, y)
            CGContextStrokePath(context)
        }

        // vertical axis on the left
        CGContextMoveToPoint(context, 0, 0)
        CGContextAddLineToPoint(context, 0, drawingHeight + topInset)
        CGContextStrokePath(context)


        // vertical axis on the right
        CGContextMoveToPoint(context, drawingWidth, 0)
        CGContextAddLineToPoint(context, drawingWidth, drawingHeight + topInset)
        CGContextStrokePath(context)

    }

    private func drawLabelsAndGridOnXAxis() {

        let context = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(context, gridColor.CGColor)
        CGContextSetLineWidth(context, 0.5)

        var labels: Array<Float>
        if xLabels == nil {
            // Use labels from the first series
            labels = series[0].data.map({ (point: ChartPoint) -> Float in
                return point.x })
        } else {
            labels = xLabels!
        }

        let scaled = scaleValuesOnXAxis(labels)
        let padding: CGFloat = 5

        scaled.enumerate().forEach { (i, value) in
            let x = CGFloat(value)


            // Add vertical grid for each label, except axes on the left and right

            if x != 0 && x != drawingWidth {
                CGContextMoveToPoint(context, x, 0)
                CGContextAddLineToPoint(context, x, bounds.height)
                CGContextStrokePath(context)
            }

            if x == drawingWidth {
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

            // Add left padding
            label.frame.origin.x += padding

            // Center label vertically
            label.frame.origin.y += topInset
            label.frame.origin.y -= (label.frame.height - bottomInset) / 2

            // Set label's text alignment
            label.frame.size.width = (drawingWidth / CGFloat(labels.count)) - padding * 2
            label.textAlignment = xLabelsTextAlignment


            self.addSubview(label)

        }

    }

    private func drawLabelsAndGridOnYAxis() {

        let context = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(context, gridColor.CGColor)
        CGContextSetLineWidth(context, 0.5)

        var labels: Array<Float>
        if yLabels == nil {
            labels = [(min.y + max.y) / 2, max.y]
            if yLabelsOnRightSide || min.y != 0 {
                labels.insert(min.y, atIndex: 0)
            }
        } else {
            labels = yLabels!
        }

        let scaled = scaleValuesOnYAxis(labels)
        let padding: CGFloat = 5
        let zero = CGFloat(getZeroValueOnYAxis())

        scaled.enumerate().forEach { (i, value) in

            let y = CGFloat(value)

            // Add horizontal grid for each label, but not over axes
            if y != drawingHeight + topInset && y != zero {

                CGContextMoveToPoint(context, 0, y)
                CGContextAddLineToPoint(context, self.bounds.width, y)
                if labels[i] != 0 {
                    // Horizontal grid for 0 is not dashed
                    CGContextSetLineDash(context, 0, [5], 1)
                } else {
                    CGContextSetLineDash(context, 0, nil, 0)
                }
                CGContextStrokePath(context)
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

    private func drawHighlightLineFromLeftPosition(left: CGFloat) {
        if let shapeLayer = highlightShapeLayer {
            // Use line already created
            let path = CGPathCreateMutable()

            CGPathMoveToPoint(path, nil, left, 0)
            CGPathAddLineToPoint(path, nil, left, drawingHeight  + topInset)
            shapeLayer.path = path
        } else {
            // Create the line
            let path = CGPathCreateMutable()

            CGPathMoveToPoint(path, nil, left, 0)
            CGPathAddLineToPoint(path, nil, left, drawingHeight + topInset)

            let shapeLayer = CAShapeLayer()
            shapeLayer.frame = self.bounds
            shapeLayer.path = path
            shapeLayer.strokeColor = highlightLineColor.CGColor
            shapeLayer.fillColor = nil
            shapeLayer.lineWidth = highlightLineWidth

            highlightShapeLayer = shapeLayer
            layer.addSublayer(shapeLayer)
            layerStore.append(shapeLayer)
        }

    }

    func handleTouchEvents(touches: NSSet!, event: UIEvent!) {
        let point: AnyObject! = touches.anyObject()
        let left = point.locationInView(self).x
        let x = valueFromPointAtX(left)

        if left < 0 || left > drawingWidth {
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

        var indexes: Array<Int?> = []

        for series in self.series {
            var index: Int? = nil
            let xValues = series.data.map({ (point: ChartPoint) -> Float in
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
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        handleTouchEvents(touches, event: event)
    }

    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        handleTouchEvents(touches, event: event)
    }

    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        handleTouchEvents(touches, event: event)
    }


    // MARK: - Utilities

    private func valueFromPointAtX(x: CGFloat) -> Float {
        let value = ((max.x-min.x) / Float(drawingWidth)) * Float(x) + min.x
        return value
    }

    private func valueFromPointAtY(y: CGFloat) -> Float {
        let value = ((max.y - min.y) / Float(drawingHeight)) * Float(y) + min.y
        return -value
    }

    private class func findClosestInValues(values: Array<Float>, forValue value: Float) -> (lowestValue: Float?, highestValue: Float?, lowestIndex: Int?, highestIndex: Int?) {
        var lowestValue: Float?, highestValue: Float?, lowestIndex: Int?, highestIndex: Int?

        values.enumerate().forEach { (i, currentValue) in

            if currentValue <= value && (lowestValue == nil || lowestValue! < currentValue) {
                lowestValue = currentValue
                lowestIndex = i
            }
            if currentValue >= value && (highestValue == nil || highestValue! > currentValue) {
                highestValue = currentValue
                highestIndex = i
            }

        }
        return (lowestValue: lowestValue, highestValue: highestValue, lowestIndex: lowestIndex, highestIndex: highestIndex)
    }


    /**
    Segment a line in multiple lines when the line touches the x-axis, i.e. separating
    positive from negative values.
    */
    private class func segmentLine(line: ChartLineSegment) -> Array<ChartLineSegment> {
        var segments: Array<ChartLineSegment> = []
        var segment: ChartLineSegment = []

        line.enumerate().forEach { (i, point) in

            segment.append(point)
            if i < line.count - 1 {
                let nextPoint = line[i+1]
                if point.y * nextPoint.y < 0 || point.y < 0 && nextPoint.y == 0 {
                    // The sign changed, close the segment with the intersection on x-axis
                    let closingPoint = Chart.intersectionOnXAxisBetween(point, and: nextPoint)
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
    Return the intersection of a line between two points on the x-axis
    */
    private class func intersectionOnXAxisBetween(p1: ChartPoint, and p2: ChartPoint) -> ChartPoint {
        return (x: p1.x - (p2.x - p1.x) / (p2.y - p1.y) * p1.y, y: 0)
    }
}

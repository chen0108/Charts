//
//  BarLineScatterCandleBubbleRenderer.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import UIKit
import CoreGraphics

@objc(BarLineScatterCandleBubbleChartRenderer)
open class BarLineScatterCandleBubbleRenderer: DataRenderer
{
    internal var _xBounds = XBounds() // Reusable XBounds object
    
    public override init(animator: Animator, viewPortHandler: ViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
    }
    
    /// Checks if the provided entry object is in bounds for drawing considering the current animation phase.
    internal func isInBoundsX(entry e: ChartDataEntry, dataSet: IBarLineScatterCandleBubbleChartDataSet) -> Bool
    {
        let entryIndex = dataSet.entryIndex(entry: e)
        return Double(entryIndex) < Double(dataSet.entryCount) * animator.phaseX
    }

    /// Calculates and returns the x-bounds for the given DataSet in terms of index in their values array.
    /// This includes minimum and maximum visible x, as well as range.
    internal func xBounds(chart: BarLineScatterCandleBubbleChartDataProvider,
                          dataSet: IBarLineScatterCandleBubbleChartDataSet,
                          animator: Animator?) -> XBounds
    {
        return XBounds(chart: chart, dataSet: dataSet, animator: animator)
    }
    
    /// - Returns: `true` if the DataSet values should be drawn, `false` if not.
    internal func shouldDrawValues(forDataSet set: IChartDataSet) -> Bool
    {
        return set.isVisible && (set.isDrawValuesEnabled || set.isDrawIconsEnabled)
    }
    
    ///
    /// Draws vertical & horizontal highlight-lines if enabled.
    /// :param: context
    /// :param: points
    /// :param: horizontal
    /// :param: vertical
    @objc open func drawHighlightLines(context: CGContext, point: CGPoint, set: IBarLineScatterCandleBubbleChartDataSet)
    {
        context.saveGState()
        
        context.setStrokeColor(set.highlightLineColor.cgColor)
        context.setLineWidth(set.highlightLineWidth)
        if set.highlightLineDashLengths != nil
        {
            context.setLineDash(phase: set.highlightLineDashPhase, lengths: set.highlightLineDashLengths!)
        }
        else
        {
            context.setLineDash(phase: 0.0, lengths: [])
        }
        
        // draw vertical highlight lines
        if set.isVerticalHighlightIndicatorEnabled
        {
            context.beginPath()
            context.move(to: CGPoint(x: point.x, y: viewPortHandler.contentTop))
            context.addLine(to: CGPoint(x: point.x, y: viewPortHandler.contentBottom))
            context.strokePath()
        }
        
        // draw horizontal highlight lines
        if set.isHorizontalHighlightIndicatorEnabled
        {
            context.beginPath()
            context.move(to: CGPoint(x: viewPortHandler.contentLeft, y: point.y))
            context.addLine(to: CGPoint(x: viewPortHandler.contentRight, y: point.y))
            context.strokePath()
        }
        context.restoreGState()
    }
    
    /// draw XAxis Highlight
    @objc open func drawXAxisHighlight(context: CGContext, point: CGPoint, set: IBarLineScatterCandleBubbleChartDataSet, entry: ChartDataEntry, xAxis: XAxis)
    {
        context.saveGState()
        
        if set.isDrawXAxisHighlightEnabled
        {
            context.setStrokeColor(set.xAxisHighlightColor.cgColor)
            context.setLineWidth(set.xAxisHighlightLineWidth)
            context.setFillColor(set.xAxisHighlightFillColor.cgColor)
            
            let radius = set.xAxisHighlightRadius
            let center = CGPoint(x: point.x, y: viewPortHandler.contentBottom)
            let fillRect = CGRect(x: point.x-radius, y: center.y-radius, width: radius*2, height: radius*2)
            context.fillEllipse(in: fillRect)
            context.strokePath()
            context.addArc(center: center, radius: radius, startAngle: 0, endAngle: 6.29, clockwise: true)
            context.strokePath()
            
            // draw text
            let label = xAxis.valueFormatter?.stringForValue(entry.x, axis: xAxis) ?? String(format: "%.0f", entry.x)
            var drawAttributes = [NSAttributedString.Key : Any]()
            drawAttributes[.font] = set.xAxisHighlightLabelFont
            drawAttributes[.foregroundColor] = set.xAxisHighlightLabelColor
            let size = label.size(withAttributes: drawAttributes)
            NSUIGraphicsPushContext(context)
            label.draw(at: CGPoint(x: center.x-size.width/2.0, y: center.y-size.height/2.0), withAttributes: drawAttributes)
            NSUIGraphicsPopContext()
        }

        context.restoreGState()
    }

    /// Class representing the bounds of the current viewport in terms of indices in the values array of a DataSet.
    open class XBounds
    {
        /// minimum visible entry index
        open var min: Int = 0

        /// maximum visible entry index
        open var max: Int = 0

        /// range of visible entry indices
        open var range: Int = 0

        public init()
        {
            
        }
        
        public init(chart: BarLineScatterCandleBubbleChartDataProvider,
                    dataSet: IBarLineScatterCandleBubbleChartDataSet,
                    animator: Animator?)
        {
            self.set(chart: chart, dataSet: dataSet, animator: animator)
        }
        
        /// Calculates the minimum and maximum x values as well as the range between them.
        open func set(chart: BarLineScatterCandleBubbleChartDataProvider,
                      dataSet: IBarLineScatterCandleBubbleChartDataSet,
                      animator: Animator?)
        {
            let phaseX = Swift.max(0.0, Swift.min(1.0, animator?.phaseX ?? 1.0))
            
            let low = chart.lowestVisibleX
            let high = chart.highestVisibleX
            
            let entryFrom = dataSet.entryForXValue(low, closestToY: .nan, rounding: .down)
            let entryTo = dataSet.entryForXValue(high, closestToY: .nan, rounding: .up)
            
            self.min = entryFrom == nil ? 0 : dataSet.entryIndex(entry: entryFrom!)
            self.max = entryTo == nil ? 0 : dataSet.entryIndex(entry: entryTo!)
            range = Int(Double(self.max - self.min) * phaseX)
        }
    }
}

extension BarLineScatterCandleBubbleRenderer.XBounds: RangeExpression {
    public func relative<C>(to collection: C) -> Swift.Range<Int>
        where C : Collection, Bound == C.Index
    {
        return Swift.Range<Int>(min...min + range)
    }

    public func contains(_ element: Int) -> Bool {
        return (min...min + range).contains(element)
    }
}

extension BarLineScatterCandleBubbleRenderer.XBounds: Sequence {
    public struct Iterator: IteratorProtocol {
        private var iterator: IndexingIterator<ClosedRange<Int>>
        
        fileprivate init(min: Int, max: Int) {
            self.iterator = (min...max).makeIterator()
        }
        
        public mutating func next() -> Int? {
            return self.iterator.next()
        }
    }
    
    public func makeIterator() -> Iterator {
        return Iterator(min: self.min, max: self.max)
    }
}

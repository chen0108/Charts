//
//  BarLineScatterCandleBubbleChartDataSet.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics


open class BarLineScatterCandleBubbleChartDataSet: ChartDataSet, IBarLineScatterCandleBubbleChartDataSet
{
    // MARK: - Data functions and accessors
    
    // MARK: - Styling functions and accessors
    
    open var highlightColor = NSUIColor.red
    open var highlightLineWidth = CGFloat(1)
    open var highlightLineDashPhase = CGFloat(0.0)
    open var highlightLineDashLengths: [CGFloat]?
    
    open var drawHorizontalHighlightIndicatorEnabled = false
    open var drawVerticalHighlightIndicatorEnabled = false
    open var isHorizontalHighlightIndicatorEnabled: Bool { return drawHorizontalHighlightIndicatorEnabled }
    open var isVerticalHighlightIndicatorEnabled: Bool { return drawVerticalHighlightIndicatorEnabled }
    /// Enables / disables both vertical and horizontal highlight-indicators.
    open func setDrawHighlightIndicators(_ enabled: Bool)
    {
        drawHorizontalHighlightIndicatorEnabled = enabled
        drawVerticalHighlightIndicatorEnabled = enabled
    }

    // MARK: x轴视觉增强
    open var drawXAxisHighlightEnabled = false
    open var xAxisHighlightColor = NSUIColor.black
    open var xAxisHighlightFillColor = NSUIColor.gray
    open var xAxisHighlightLineWidth = CGFloat(2.0)
    open var xAxisHighlightRadius = CGFloat(15.0)
    open var xAxisHighlightLabelFont = NSUIFont.systemFont(ofSize: 13)
    open var xAxisHighlightLabelColor = NSUIColor.black
    open var isDrawXAxisHighlightEnabled: Bool { return drawXAxisHighlightEnabled }
    
    // MARK: - NSCopying

    open override func copy(with zone: NSZone? = nil) -> Any
    {
        let copy = super.copy(with: zone) as! BarLineScatterCandleBubbleChartDataSet
        copy.highlightColor = highlightColor
        copy.highlightLineWidth = highlightLineWidth
        copy.highlightLineDashPhase = highlightLineDashPhase
        copy.highlightLineDashLengths = highlightLineDashLengths
        copy.drawHorizontalHighlightIndicatorEnabled = drawHorizontalHighlightIndicatorEnabled
        copy.drawVerticalHighlightIndicatorEnabled = drawVerticalHighlightIndicatorEnabled
        copy.drawXAxisHighlightEnabled = drawXAxisHighlightEnabled
        copy.xAxisHighlightColor = xAxisHighlightColor
        copy.xAxisHighlightFillColor = xAxisHighlightFillColor
        copy.xAxisHighlightLineWidth = xAxisHighlightLineWidth
        copy.xAxisHighlightRadius = xAxisHighlightRadius
        copy.xAxisHighlightLabelFont = xAxisHighlightLabelFont
        copy.xAxisHighlightLabelColor = xAxisHighlightLabelColor
        return copy
    }
}

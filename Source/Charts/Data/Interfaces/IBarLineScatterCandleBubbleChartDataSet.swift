//
//  IBarLineScatterCandleBubbleChartDataSet.swift
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

@objc
public protocol IBarLineScatterCandleBubbleChartDataSet: IChartDataSet
{
    // MARK: - Data functions and accessors
    
    // MARK: - Styling functions and accessors
    
    var highlightColor: NSUIColor { get set }
    var highlightLineWidth: CGFloat { get set }
    var highlightLineColor: NSUIColor { get set }
    var highlightLineDashPhase: CGFloat { get set }
    var highlightLineDashLengths: [CGFloat]? { get set }
    
    var drawHorizontalHighlightIndicatorEnabled: Bool { get set }
    var drawVerticalHighlightIndicatorEnabled: Bool { get set }
    var isHorizontalHighlightIndicatorEnabled: Bool { get }
    var isVerticalHighlightIndicatorEnabled: Bool { get }
    var horizontalHighlightIndicatorToPoint: Bool { get set }
    var verticalHighlightIndicatorToPoint: Bool { get set }
    
    /// Enables / disables both vertical and horizontal highlight-indicators.
    /// :param: enabled
    func setDrawHighlightIndicators(_ enabled: Bool)
    
    /// x轴视觉增强
    var drawXAxisHighlightEnabled: Bool { get set }
    var isDrawXAxisHighlightEnabled: Bool { get }
    var xAxisHighlightColor: NSUIColor { get set }
    var xAxisHighlightFillColor: NSUIColor { get set }
    var xAxisHighlightLineWidth: CGFloat { get set }
    var xAxisHighlightRadius: CGFloat { get set }
    var xAxisHighlightLabelFont: NSUIFont { get set }
    var xAxisHighlightLabelColor: NSUIColor { get set }
}

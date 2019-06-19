// IDangleChartDataSet.swift 
// Charts 
// 
// Created by HCC on 2019/6/18. 
//  
//

import Foundation
import CoreGraphics

@objc
public protocol IDangleChartDataSet: ILineScatterCandleRadarChartDataSet
{
    // MARK: - Data functions and accessors
    
    // MARK: - Styling functions and accessors
    
    /// the space that is left out on the left and right side of each candle,
    /// **default**: 0.1 (10%), max 0.45, min 0.0
    var barSpace: CGFloat { get set }
    var barAbsoluteWidth: CGFloat { get set }
    var barColor: NSUIColor? { get set }
    
    var drawGradientBar: Bool { get set }
    var isDrawGradientBar: Bool { get }
    var barGradient: CGGradient? { get set }
    var barAlpha: CGFloat { get set }
    
    /// Whether the upper and lower ends of the boundary are smooth
    var portSmooth: Bool { get set }
    var isPortSmooth: Bool { get }
    
    /// Draw boundary point
    var drawBoundaryPointsEnable: Bool { get set }
    var isDrawBoundaryPointsEnable: Bool { get }
    var maxPointColor: NSUIColor? { get set }
    var minPointColor: NSUIColor? { get set }
    var boundaryPointRadius: CGFloat { get set }
    
    var drawBoundaryPointLinkLineEnable: Bool { get set }
    var isDrawBoundaryPointLinkLineEnable: Bool { get }
    var maxPointLinkLineColor: NSUIColor? { get set }
    var maxPointLinkLineWidth: CGFloat { get set }
    var minPointLinkLineColor: NSUIColor? { get set }
    var minPointLinkLineWidth: CGFloat { get set }
    
    /// Draw main points
    var drawMainPointEnable: Bool { get set }
    var isDrawMainPointEnable: Bool { get }
    var mainPointColor: NSUIColor? { get set }
    var mainPointRadius: CGFloat { get set }
    
    var drawMainPointLinkLineEnable: Bool { get set }
    var isDrawMainPointLinkLineEnable: Bool { get }
    var mainPointLinkLineColor: NSUIColor? { get set }
    var mainPointLinkLineWidth: CGFloat { get set }
    
}

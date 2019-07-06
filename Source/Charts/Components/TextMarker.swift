// XYMarker.swift 
// Charts 
// 
// Created by HCC on 2019/7/4. 
//  
//

import Foundation

open class TextMarker: MarkerImage {
    
    @objc public enum VerticalAlignment: Int
    {
        case top
        case adapt
    }
    @objc public enum HorizontalAlignment: Int
    {
        case left
        case center
        case right
    }
    
    @objc public enum MarkerShape: Int
    {
        case none
        case arrow
        case bound
    }
    
    @objc open var textColor: UIColor
    @objc open var font: UIFont
    @objc open var shape: MarkerShape
    
    @objc open var color: UIColor = NSUIColor.gray
    @objc open var arrowSize = CGSize(width: 10, height: 6)
    @objc open var boundRadius: CGFloat = 4
    @objc open var insets: UIEdgeInsets = UIEdgeInsets(top: 2.5, left: 5, bottom: 2.5, right: 5)
    @objc open var minimumSize = CGSize(width: 30, height: 20)
    @objc open var vAlignment: VerticalAlignment = .adapt
    @objc open var hAlignment: HorizontalAlignment = .center
    
    open var label: String?
    open var _underPoint:Bool = false
    open var _labelSize: CGSize = CGSize()
    open var _paragraphStyle: NSMutableParagraphStyle?
    open var _drawAttributes = [NSAttributedString.Key : Any]()
    
    @objc public init(drawShape: MarkerShape, font: UIFont, textColor: UIColor)
    {
        self.shape = drawShape
        self.font = font
        self.textColor = textColor
        _paragraphStyle = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
        _paragraphStyle?.alignment = .center
        super.init()
    }
    
    /// 越界时,返回计算的偏移量
    open override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint
    {
        var offset = self.offset
        var size = self.size
        
        if size.width == 0.0 && image != nil
        {
            size.width = image!.size.width
        }
        if size.height == 0.0 && image != nil
        {
            size.height = image!.size.height
        }
        
        let width = size.width
        let height = size.height
        let padding: CGFloat = 8.0
        
        var origin = point
        // x
        if self.hAlignment == .left
        {
            origin.x -= width
        }
        else if self.hAlignment == .center
        {
            origin.x -= width / 2.0
        }
        else{
            
        }
        // y
        if self.vAlignment == .top
        {
            origin.y =  0
        }
        else
        {
            origin.y -= height
        }
        
        
        if origin.x + offset.x < 0.0
        {
            offset.x = -origin.x + padding
        }
        else if let chart = chartView,
            origin.x + width + offset.x > chart.bounds.size.width
        {
            offset.x = chart.bounds.size.width - origin.x - width - padding
        }
        
        if origin.y + offset.y < 0
        {
            offset.y = height + padding;
        }
        else if let chart = chartView,
            origin.y + height + offset.y > chart.bounds.size.height
        {
            offset.y = chart.bounds.size.height - origin.y - height - padding
        }
        
        return offset
    }
    
    /// 绘制内容
    open override func draw(context: CGContext, point: CGPoint)
    {
        guard let label = label else { return }
        
        let offset = self.offsetForDrawing(atPoint: point)
        let size = self.size
        
        var rect = CGRect(
            origin: CGPoint(
                x: point.x + offset.x,
                y: point.y + offset.y),
            size: size)
        
        // x
        if self.hAlignment == .left
        {
            rect.origin.x -= size.width
        }
        else if self.hAlignment == .center
        {
            rect.origin.x -= size.width / 2.0
        }
        else{
            
        }
        
        // y
        if self.vAlignment == .top
        {
            rect.origin.y =  0.0
        }
        else
        {
            rect.origin.y -= size.height
        }
        
        context.saveGState()
        
        if self.shape == .arrow
        {
            context.setFillColor(color.cgColor)
            
            context.beginPath()
            context.move(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y))
            context.addLine(to: CGPoint(
                x: rect.origin.x + rect.size.width,
                y: rect.origin.y))
            context.addLine(to: CGPoint(
                x: rect.origin.x + rect.size.width,
                y: rect.origin.y + rect.size.height - arrowSize.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x + (rect.size.width + arrowSize.width) / 2.0,
                y: rect.origin.y + rect.size.height - arrowSize.height))
            //arrow vertex
            context.addLine(to: CGPoint(
                x: point.x,
                y: rect.origin.y + rect.size.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x + (rect.size.width - arrowSize.width) / 2.0,
                y: rect.origin.y + rect.size.height - arrowSize.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y + rect.size.height - arrowSize.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y))
            context.fillPath()
        }
        else if self.shape == .bound
        {
            context.setFillColor(color.cgColor)
            let fillPath = UIBezierPath.init(roundedRect: rect, cornerRadius: self.boundRadius)
            fillPath.fill()
        }
        
        rect.origin.x += self.insets.left
        rect.origin.y += self.insets.top
        rect.size.height -= (self.insets.top + self.insets.bottom)
        rect.size.width -= (self.insets.left + self.insets.right)
        
        if self.shape == .arrow
        {
            rect.size.height -= arrowSize.height
        }
        
        UIGraphicsPushContext(context)
        
        label.draw(in: rect, withAttributes: _drawAttributes)
        
        UIGraphicsPopContext()
        
        context.restoreGState()
    }
    
    open override func refreshContent(entry: ChartDataEntry, highlight: Highlight)
    {
        setLabel(String(format: "%.0f",entry.y))
    }
    
    @objc open func setLabel(_ newLabel: String)
    {
        label = newLabel
        
        _drawAttributes.removeAll()
        _drawAttributes[.font] = self.font
        _drawAttributes[.paragraphStyle] = _paragraphStyle
        _drawAttributes[.foregroundColor] = self.textColor
        
        _labelSize = label?.size(withAttributes: _drawAttributes) ?? CGSize.zero
        
        var size = CGSize()
        size.width = _labelSize.width + self.insets.left + self.insets.right
        size.height = _labelSize.height + self.insets.top + self.insets.bottom
        size.width = max(minimumSize.width, size.width)
        size.height = max(minimumSize.height, size.height)
        if self.shape == .arrow
        {
            size.height += arrowSize.height
        }
        self.size = size
    }
}

//
//  YSRangeSlider.swift
//  YSRangeSlider
//
//  Created by Laurentiu Ungur on 22/01/16.
//  Copyright © 2016 Yardi. All rights reserved.
//

import UIKit

@IBDesignable public final class YSRangeSlider: UIControl {
    // MARK: - Public Properties
    
    /// The minimum possible value to select in the range
    @IBInspectable public var minimumValue: CGFloat = 0.0 {
        didSet { updateComponentsPosition() }
    }
    /// The maximum possible value to select in the range
    @IBInspectable public var maximumValue: CGFloat = 1.0 {
        didSet { updateComponentsPosition() }
    }
    /// The preselected minimum value from range [minimumValue, maximumValue]
    @IBInspectable public var minimumSelectedValue: CGFloat = 0.0 {
        didSet{
            if minimumSelectedValue < minimumValue || minimumSelectedValue > maximumValue {
                minimumSelectedValue = minimumValue
            }
            updateComponentsPosition()
        }
    }
    /// The preselected maximum value from range [minimumValue, maximumValue]
    @IBInspectable public var maximumSelectedValue: CGFloat = 1.0 {
        didSet{
            if maximumSelectedValue < minimumValue || maximumSelectedValue > maximumValue {
                maximumSelectedValue = maximumValue
            }
            updateComponentsPosition()
        }
    }
    /// The color of the slider
    @IBInspectable public var sliderLineColor: UIColor = UIColor.blackColor() {
        didSet { sliderLineLayer.backgroundColor = sliderLineColor.CGColor }
    }
    /// The color of slider between left and right thumb
    @IBInspectable public var sliderLineColorBetweenThumbs: UIColor = UIColor.yellowColor() {
        didSet { thumbsDistanceLineLayer.backgroundColor = sliderLineColorBetweenThumbs.CGColor }
    }
    /// Padding between slider and controller sides
    @IBInspectable public var sliderSidePadding: CGFloat = 15.0 {
        didSet { layoutSubviews() }
    }
    /// The color of the left thumb
    @IBInspectable public var leftThumbColor: UIColor = UIColor.blackColor() {
        didSet { leftThumbLayer.backgroundColor = leftThumbColor.CGColor }
    }
    /// The color of the right thumb
    @IBInspectable public var rightThumbColor: UIColor = UIColor.blackColor() {
        didSet { rightThumbLayer.backgroundColor = rightThumbColor.CGColor }
    }
    /// The corner radius of the left thumb
    @IBInspectable public var leftThumbCornerRadius: CGFloat = 10.0 {
        didSet { leftThumbLayer.cornerRadius = leftThumbCornerRadius }
    }
    /// The corner radius of the right thumb
    @IBInspectable public var rightThumbCornerRadius: CGFloat = 10.0 {
        didSet { rightThumbLayer.cornerRadius = rightThumbCornerRadius }
    }
    /// The size of the thumbs
    @IBInspectable public var thumbsSize: CGFloat = 20.0 {
        didSet {
            leftThumbLayer.frame.size = CGSize(width: thumbsSize, height: thumbsSize)
            rightThumbLayer.frame.size = CGSize(width: thumbsSize, height: thumbsSize)
        }
    }
    /// The height of the slider
    @IBInspectable public var sliderLineHeight: CGFloat = 1.0 {
        didSet {
            sliderLineLayer.frame.size.height = sliderLineHeight
            thumbsDistanceLineLayer.frame.size.height = sliderLineHeight
        }
    }
    public weak var delegate: YSRangeSLiderDelegate?
    
    // MARK: - Private Properties
    
    private let sliderLineLayer = CALayer()
    private let leftThumbLayer = CALayer()
    private let rightThumbLayer = CALayer()
    private let thumbsDistanceLineLayer = CALayer()
    private let thumbTouchAreaExpansion: CGFloat = -90.0
    private var leftThumbSelected = false
    private var rightThumbSelected = false
    
    // MARK: - Init
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        sliderLineLayer.backgroundColor = sliderLineColor.CGColor
        layer.addSublayer(sliderLineLayer)
        
        thumbsDistanceLineLayer.backgroundColor = sliderLineColorBetweenThumbs.CGColor
        layer.addSublayer(thumbsDistanceLineLayer)
        
        leftThumbLayer.backgroundColor = leftThumbColor.CGColor
        leftThumbLayer.cornerRadius = leftThumbCornerRadius
        leftThumbLayer.frame = CGRect(x: 0, y: 0, width: thumbsSize, height: thumbsSize)
        layer.addSublayer(leftThumbLayer)
        
        rightThumbLayer.backgroundColor = rightThumbColor.CGColor
        rightThumbLayer.cornerRadius = rightThumbCornerRadius
        rightThumbLayer.frame = CGRect(x: 0, y: 0, width: thumbsSize, height: thumbsSize)
        layer.addSublayer(rightThumbLayer)
        
        updateComponentsPosition()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let frameMiddleY = CGRectGetHeight(frame) / 2.0
        let lineLeftSide = CGPoint(x: sliderSidePadding, y: frameMiddleY)
        let lineRightSide = CGPoint(x: CGRectGetWidth(frame) - sliderSidePadding, y: frameMiddleY)
        
        sliderLineLayer.frame = CGRect(x: lineLeftSide.x, y: lineLeftSide.y, width: lineRightSide.x - lineLeftSide.x, height: sliderLineHeight)
        
        updateThumbsPosition()
    }
    
    // MARK: - Touch Tracking
    
    override public func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let pressGestureLocation = touch.locationInView(self)
        
        if CGRectContainsPoint(CGRectInset(leftThumbLayer.frame, thumbTouchAreaExpansion, thumbTouchAreaExpansion), pressGestureLocation) ||
           CGRectContainsPoint(CGRectInset(rightThumbLayer.frame, thumbTouchAreaExpansion, thumbTouchAreaExpansion), pressGestureLocation) {
            let distanceFromLeftThumb = distanceBetweenPoints(pressGestureLocation, centerOfRect(leftThumbLayer.frame))
            let distanceFromRightThumb = distanceBetweenPoints(pressGestureLocation, centerOfRect(rightThumbLayer.frame))
            
            if distanceFromLeftThumb < distanceFromRightThumb {
                leftThumbSelected = true
                animateThumbLayer(leftThumbLayer, isSelected: true)
            } else if maximumSelectedValue == maximumValue && centerOfRect(leftThumbLayer.frame).x == centerOfRect(rightThumbLayer.frame).x {
                leftThumbSelected = true
                animateThumbLayer(leftThumbLayer, isSelected: true)
            } else {
                rightThumbSelected = true
                animateThumbLayer(rightThumbLayer, isSelected: true)
            }
            
            return true
        }
        
        return false
    }
    
    override public func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let location = touch.locationInView(self)
        let percentage = (location.x - CGRectGetMinX(sliderLineLayer.frame) - thumbsSize / 2) / (CGRectGetMaxX(sliderLineLayer.frame) - CGRectGetMinX(sliderLineLayer.frame))
        let selectedValue = percentage * (maximumValue - minimumValue) + minimumValue
        
        if leftThumbSelected {
            minimumSelectedValue = (selectedValue < maximumSelectedValue) ? selectedValue : maximumSelectedValue
        } else if rightThumbSelected {
            maximumSelectedValue = (selectedValue > minimumSelectedValue) ? selectedValue : minimumSelectedValue
        }
        
        return true
    }
    
    override public func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        if leftThumbSelected {
            leftThumbSelected = false
            animateThumbLayer(leftThumbLayer, isSelected: false)
        } else {
            rightThumbSelected = false
            animateThumbLayer(rightThumbLayer, isSelected: false)
        }
    }
    
    // MARK: - Private Methods
    
    private func updateComponentsPosition() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        updateThumbsPosition()
        CATransaction.commit()
        
        delegate?.rangeSliderDidChange(self, minimumSelectedValue: minimumSelectedValue, maximumSelectedValue: maximumSelectedValue)
    }
    
    private func updateThumbsPosition() {
        let leftThumbCenter = CGPoint(x: getXPositionAlongSliderForValue(minimumSelectedValue), y: CGRectGetMidY(sliderLineLayer.frame))
        let rightThumbCenter = CGPoint(x: getXPositionAlongSliderForValue(maximumSelectedValue), y: CGRectGetMidY(sliderLineLayer.frame))
        
        leftThumbLayer.position = leftThumbCenter
        rightThumbLayer.position = rightThumbCenter
        thumbsDistanceLineLayer.frame = CGRect(x: leftThumbLayer.position.x, y: sliderLineLayer.frame.origin.y, width: rightThumbLayer.position.x - leftThumbLayer.position.x, height: sliderLineHeight)
    }
    
    private func getPercentageAlongSliderForValue(value: CGFloat) -> CGFloat {
        return (minimumValue != maximumValue) ? (value - minimumValue) / (maximumValue - minimumValue) : 0
    }
    
    private func getXPositionAlongSliderForValue(value: CGFloat) -> CGFloat {
        let percentage = getPercentageAlongSliderForValue(value)
        let differenceBetweenMaxMinCoordinatePositionX = CGRectGetMaxX(sliderLineLayer.frame) - CGRectGetMinX(sliderLineLayer.frame)
        let offset = percentage * differenceBetweenMaxMinCoordinatePositionX
    
        return CGRectGetMinX(sliderLineLayer.frame) + offset
    }
    
    private func distanceBetweenPoints(firstPoint: CGPoint, _ secondPoint: CGPoint) -> CGFloat {
        let xDistance = secondPoint.x - firstPoint.x
        let yDistance = secondPoint.y - firstPoint.y
        
        return sqrt(pow(xDistance, 2) + pow(yDistance, 2))
    }
    
    private func centerOfRect(rect: CGRect) -> CGPoint {
        return CGPoint(x: CGRectGetMidX(rect), y: CGRectGetMidY(rect))
    }
    
    private func animateThumbLayer(thumbLayer: CALayer, isSelected selected: Bool) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.5)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
        thumbLayer.transform = selected ? CATransform3DMakeScale(1.3, 1.3, 1) : CATransform3DIdentity
        CATransaction.commit()
    }
}

// MARK: - YSRangeSliderDelegate

public protocol YSRangeSLiderDelegate: class {
    /**
        Delegate method that is called every time minimum or maximum selected value is changed
        - Parameters:
            - rangeSlider: Current instance of `YSRangeSlider`
            - minimumSelectedValue: The minimum selected value
            - maximumSelectedValue: The maximum selected value
     */
    func rangeSliderDidChange(rangeSlider: YSRangeSlider, minimumSelectedValue: CGFloat, maximumSelectedValue: CGFloat)
}

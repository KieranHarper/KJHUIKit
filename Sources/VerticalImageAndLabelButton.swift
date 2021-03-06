//
//  VerticalImageAndLabelButton.swift
//  KJHUIKit
//
//  Created by Kieran Harper on 12/7/17.
//  Copyright © 2017 Kieran Harper. All rights reserved.
//

import UIKit


/// Button that contains an image and a label vertically stacked, with the choice of which one is on top.
@objc open class VerticalImageAndLabelButton: Button {
    
    
    
    // MARK: - Types
    
    /// Arrangement options - the button has 2 elements where one is on top and the other is below it.
    public enum ImageAndLabelArrangement {
        case imageTopLabelBottom
        case imageBottomLabelTop
    }
    
    
    
    // MARK: - Properties
    
    /**
     The label part of the button.
     */
    @objc public let label = CrossfadingLabel()
    
    /**
     The image view part of the button.
     */
    @objc public let imageView = CrossfadingImageView()
    
    /**
     The layout style / ordering of the elements.
     */
    public var arrangement: ImageAndLabelArrangement = .imageTopLabelBottom {
        didSet {
            self.invalidateIntrinsicContentSize()
            self.setNeedsLayout()
        }
    }
    
    /**
     The spacing between the image and the label.
     */
    @objc public var imageToLabelSpacing: CGFloat = 0.0 {
        didSet {
            self.invalidateIntrinsicContentSize()
            self.setNeedsLayout()
        }
    }
    
    /**
     The horizontal offset of the label from a X-centered position.
     
     Positive numbers move it to the right, negative to the left.
     */
    @objc public var labelCenterXOffset: CGFloat = 0.0 {
        didSet {
            self.invalidateIntrinsicContentSize()
            self.setNeedsLayout()
        }
    }
    
    /**
     The horizontal offset of the image from a X-centered position.
     
     Positive numbers move it to the right, negative to the left.
     */
    @objc public var imageCenterXOffset: CGFloat = 0.0 {
        didSet {
            self.invalidateIntrinsicContentSize()
            self.setNeedsLayout()
        }
    }
    
    /**
     The vertical offset of the label and image combined, from a Y-centered position.
     
     Positive numbers move it down, negative moves up.
     */
    @objc public var combinedCenterYOffset: CGFloat = 0.0 {
        didSet {
            self.invalidateIntrinsicContentSize()
            self.setNeedsLayout()
        }
    }
    
    /**
     A size to constrain the image view to, independent of the button size.
     
     This is useful if your image is bigger than you expect, but you don't want it to be flush with the edge of the button (or the button has constraints which shouldn't relate to the image).
     */
    public var imageViewConstrainedSize: CGSize? = nil {
        didSet {
            self.invalidateIntrinsicContentSize()
            self.setNeedsLayout()
        }
    }
    
    
    
    // MARK: - Private variables
    
    private var imageViewConstrainedWidth: CGFloat? {
        if let width = imageViewConstrainedSize?.width, width != UIView.noIntrinsicMetric {
            return width
        } else {
            return nil
        }
    }
    
    private var imageViewConstrainedHeight: CGFloat? {
        if let height = imageViewConstrainedSize?.height, height != UIView.noIntrinsicMetric {
            return height
        } else {
            return nil
        }
    }
    
    
    
    // MARK: - Lifecycle
    
    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupVerticalImageAndLabelButton()
    }
    
    @objc public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupVerticalImageAndLabelButton()
    }
    
    @objc public convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    private func setupVerticalImageAndLabelButton() {
        
        // Setup the image view
        imageView.contentMode = .center
        imageView.clipsToBounds = true
        self.addSubview(imageView)
        
        // Setup the label
        label.textAlignment = .center
        self.addSubview(label)
        
        helperSetFrames()
    }
    
    @objc open override func layoutSubviews() {
        super.layoutSubviews()
        helperSetFrames()
    }
    
    private func helperSetFrames() {
        var imageRect: CGRect
        var labelRect: CGRect
        let labelIntrinsic = label.intrinsicContentSize
        let imageIntrinsic = imageView.intrinsicContentSize
        
        // Determine the size that things want to be
        let imageWidth: CGFloat
        let imageHeight: CGFloat
        if let custom = imageViewConstrainedWidth {
            imageWidth = custom
        } else {
            imageWidth = imageIntrinsic.width
        }
        if let custom = imageViewConstrainedHeight {
            imageHeight = custom
        } else {
            imageHeight = imageIntrinsic.height
        }
        let labelWidth = self.bounds.width
        let labelHeight = labelIntrinsic.height
        
        // Determine where the items sit horizontally
        let mid = self.bounds.width / 2.0
        let labelX = mid + labelCenterXOffset - labelWidth / 2.0
        let imageX = mid + imageCenterXOffset - imageWidth / 2.0
        let bottomEdge: CGFloat
        
        // Do the main positioning
        // NOTE: during imperfect scenarios the image is favouring being the natural size or the requested size rather than fitting into the current frame, choosing to avoid aspect problems. Label is the reverse, opting to use the available space so it benefits from truncation.
        switch arrangement {
        case .imageTopLabelBottom:
            imageRect = CGRect(x: imageX, y: combinedCenterYOffset, width: imageWidth, height: imageHeight)
            let labelY = combinedCenterYOffset + imageRect.height + imageToLabelSpacing
            labelRect = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
            bottomEdge = labelRect.origin.y + labelRect.height
        case .imageBottomLabelTop:
            labelRect = CGRect(x: labelX, y: combinedCenterYOffset, width: labelWidth, height: labelHeight)
            let imageY = combinedCenterYOffset + labelRect.height + imageToLabelSpacing
            imageRect = CGRect(x: imageX, y: imageY, width: imageWidth, height: imageHeight)
            bottomEdge = imageRect.origin.y + imageRect.height
        }
        
        // Adjust vertically if needed when there's excess space
        let excessDiv2 = max(0, (self.bounds.height - bottomEdge) / 2.0)
        labelRect.origin.y += excessDiv2
        imageRect.origin.y += excessDiv2
        
        label.frame = labelRect
        imageView.frame = imageRect
    }
    
    @objc open override var intrinsicContentSize: CGSize {
        let imageIntrinsicWidth = imageViewConstrainedWidth ?? imageView.intrinsicContentSize.width
        let imageIntrinsicHeight = imageViewConstrainedHeight ?? imageView.intrinsicContentSize.height
        let imageWidthAccountingForOffset = imageIntrinsicWidth + 2.0 * abs(imageCenterXOffset)
        
        let labelIntrinsicSize = label.intrinsicContentSize
        let labelWidthAccountingForOffset = labelIntrinsicSize.width + 2.0 * abs(labelCenterXOffset)
        
        let width = imageWidthAccountingForOffset > labelWidthAccountingForOffset ? imageWidthAccountingForOffset : labelWidthAccountingForOffset
        let height = imageIntrinsicHeight + labelIntrinsicSize.height + imageToLabelSpacing + 2.0 * abs(combinedCenterYOffset)
        return CGSize(width: width, height: height)
    }
}

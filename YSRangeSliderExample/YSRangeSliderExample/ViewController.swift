//
//  ViewController.swift
//  YSRangeSliderExample
//
//  Created by Laurentiu Ungur on 04/02/16.
//  Copyright © 2016 Yardi. All rights reserved.
//

import UIKit
import YSRangeSlider

class ViewController: UIViewController {
    @IBOutlet weak var rangeSlider: YSRangeSlider!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rangeSlider.delegate = self
    }
}

// MARK: - YSRangeSliderDelegate
extension ViewController: YSRangeSLiderDelegate {
    func rangeSliderDidChange(rangeSlider: YSRangeSlider, minimumSelectedValue: CGFloat, maximumSelectedValue maximumSelectedSelectedValue: CGFloat) {
        label.text = "From \(minimumSelectedValue) to \(maximumSelectedSelectedValue)"
    }
}


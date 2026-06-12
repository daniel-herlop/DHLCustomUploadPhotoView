//
//  DHLFourButtonsModal.swift
//  DHLCustomUploadPhotoView
//
//  Created by Daniel Hernandez on 27/4/26.
//

import Foundation
import UIKit

class DHLFourButtonsModal: UIView {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var backgroundButton: UIButton!
    
    @IBOutlet var buttonViews: [UIView]!
    @IBOutlet var buttonLabels: [UILabel]!
    
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var thirdView: UIView!
    @IBOutlet weak var fourthView: UIView!
    
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var thirdLabel: UILabel!
    @IBOutlet weak var fourthLabel: UILabel!
    
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    @IBOutlet weak var thirdButton: UIButton!
    @IBOutlet weak var fourthButton: UIButton!
    
    private var firstAction: (() -> Void)?
    private var secondAction: (() -> Void)?
    private var thirdAction: (() -> Void)?
    private var fourthAction: (() -> Void)?

    override init(frame: CGRect) {

        super.init(frame: frame)
        nibSetup()
    }

    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
        nibSetup()
    }

    private func nibSetup() {

        backgroundColor = .clear

        let bundle = Bundle(for: DHLFourButtonsModal.self)
        
        if let xibView = bundle.loadNibNamed("DHLFourButtonsModal", owner: self, options: nil)?.first as? UIView {

            xibView.frame = self.bounds
            xibView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addSubview(xibView)

            commonInit()
        }
    }

    override func awakeFromNib() {

        super.awakeFromNib()

        commonInit()
    }

    func commonInit() {
        
        setUpAccessiblity()
        setUpViews()
    }
    
    private func setUpAccessiblity() {
        
        self.accessibilityViewIsModal = true
        
        backgroundButton.isAccessibilityElement = false
        firstLabel.isAccessibilityElement = false
        secondLabel.isAccessibilityElement = false
        thirdView.isAccessibilityElement = false
        fourthLabel.isAccessibilityElement = false
        titleLabel.accessibilityTraits = .header
    }
     
     private func setUpViews() {
         
         containerView.layer.cornerRadius = 8
         
         for label in buttonLabels {
             label.textColor = .white
         }
         
         for view in buttonViews {
             view.layer.cornerRadius = 6
             view.layer.borderWidth = 1
         }
     }

    func setUp(title: String?, subtitle: String?, titleFont: UIFont? = .systemFont(ofSize: 20, weight: .bold), subtitleFont: UIFont? = .systemFont(ofSize: 14), buttonsFont: UIFont? = .systemFont(ofSize: 14), buttonsColor: UIColor = .blue, first: String?, firstAction: (() -> Void)?, firstButtonReserveColor: Bool = false, second: String? = nil, secondAction: (() -> Void)? = nil, secondButtonReserveColor: Bool = false, third: String? = nil, thirdAction: (() -> Void)? = nil, thirdButtonReserveColor: Bool = false, fourth: String? = nil, fourthAction: (() -> Void)? = nil, fourthButtonReserveColor: Bool = false) {
        
        self.firstAction = firstAction
        self.secondAction = secondAction
        self.thirdAction = thirdAction
        self.fourthAction = fourthAction
        
        titleLabel.font = titleFont
        subtitleLabel.font = subtitleFont
        
        for label in buttonLabels {
            label.font = buttonsFont
        }
        
        for view in buttonViews {
            view.backgroundColor = buttonsColor
            view.layer.borderColor = buttonsColor.cgColor
        }
        
        titleLabel.text = title
        subtitleLabel.text = subtitle
        
        firstLabel.text = first
        secondLabel.text = second
        thirdLabel.text = third
        fourthLabel.text = fourth
        
        firstView.isHidden = first == nil
        secondView.isHidden = second == nil
        thirdView.isHidden = third == nil
        fourthView.isHidden = fourth == nil
        
        if firstButtonReserveColor {
            firstView.backgroundColor = .white
            firstLabel.textColor = buttonsColor
        }
        
        if secondButtonReserveColor {
            secondView.backgroundColor = .white
            secondLabel.textColor = buttonsColor
        }
        
        if thirdButtonReserveColor {
            thirdView.backgroundColor = .white
            thirdLabel.textColor = buttonsColor
        }
        
        if fourthButtonReserveColor {
            fourthView.backgroundColor = .white
            fourthLabel.textColor = buttonsColor
        }
    }
    
    @IBAction func firstButtonPressed(_ sender: Any) {
        firstAction?()
    }
    
    @IBAction func secondButtonPressed(_ sender: Any) {
        secondAction?()
    }
    
    @IBAction func thirdButtonPressed(_ sender: Any) {
        thirdAction?()
    }
    
    @IBAction func fourthButtonPressed(_ sender: Any) {
        fourthAction?()
    }
}

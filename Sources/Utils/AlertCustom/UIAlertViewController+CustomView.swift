//  File name   : UIAlertViewController+CustomView.swift
//
//  Author      : Dung Vu
//  Created date: 4/3/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import Atributika
import SnapKit
import FwiCore

private extension UIView {
    /// Searches a `UILabel` with the given text in the view's subviews hierarchy.
    ///
    /// - Parameter text: The label text to search
    /// - Returns: A `UILabel` in the view's subview hierarchy, containing the searched text or `nil` if no `UILabel` was found.
    func findLabel(withText text: String) -> UILabel? {
        if let label = self as? UILabel, label.text == text {
            return label
        }

        for subview in self.subviews {
            if let found = subview.findLabel(withText: text) {
                return found
            }
        }

        return nil
    }
}

extension UIAlertController {

    /// Creates a `UIAlertController` with a custom `UIView` instead the message text.
    /// - Note: In case anything goes wrong during replacing the message string with the custom view, a fallback message will
    /// be used as normal message string.
    ///
    /// - Parameters:
    ///   - title: The title text of the alert controller
    ///   - customView: A `UIView` which will be displayed in place of the message string.
    ///   - fallbackMessage: An optional fallback message string, which will be displayed in case something went wrong with inserting the custom view.
    ///   - preferredStyle: The preferred style of the `UIAlertController`.
    convenience init(title: String?, customView: UIView, fallbackMessage: String?, preferredStyle: UIAlertController.Style, numberLine: Int) {

        let marker = "__CUSTOM_CONTENT_MARKER__"
        self.init(title: title, message: marker, preferredStyle: preferredStyle)

        // Try to find the message label in the alert controller's view hierarchie
        if let customContentPlaceholder = self.view.findLabel(withText: marker),
            let customContainer =  customContentPlaceholder.superview {

            // The message label was found. Add the custom view over it and fix the autolayout...
            customView >>> customContainer >>> {
                $0.snp.makeConstraints { (make) in
                    make.top.equalTo(45)
                    make.left.equalTo(16)
                    make.right.equalTo(-16)
                    make.bottom.equalTo(-4).priority(.high)
                }
            }
            let text = (0..<numberLine).map { _ in "\n" }.joined()
            customContentPlaceholder.text = text
        } else { // In case something fishy is going on, fall back to the standard behaviour and display a fallback message string
            self.message = fallbackMessage
        }
    }
}

@objc
public extension UIAlertController {
    static func showAlertUseSupplyService(on controller: UIViewController?, path: String, cancel: ((UIAlertAction) -> Void)?, completed: ((UIAlertAction) -> Void)?) {
        let text = "Để bật dịch vụ tài xế cần phải đồng ý <a href=\"\(path)\">Điều khoản dịch vụ, Quy định và quy tắc ứng xử</a> của VATO"
        let url = Atributika.Style("a").foregroundColor(#colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), .highlighted).foregroundColor(#colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), .normal)
        let all = Atributika.Style.font(.systemFont(ofSize: 13, weight: .regular)).foregroundColor(.black)
        let att = text.style(tags: url).styleAll(all)
        let label = AttributedLabel()
        label.attributedText = att
        label.numberOfLines = 3
        label.textAlignment = .center
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        label.onClick = { _, detection in
            switch detection.type {
            case let .tag(tag):
                guard let href = tag.attributes["href"], let url = URL(string: href) else {
                    return
                }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            default:
                break
            }
        }
        
        let alertVC = UIAlertController(title: "Thông báo", customView: label, fallbackMessage: "Error", preferredStyle: .alert, numberLine: 3)
        let actionCancel = UIAlertAction(title: "Huỷ", style: .default, handler: cancel)
        alertVC.addAction(actionCancel)
        let action = UIAlertAction(title: "Đồng ý", style: .default, handler: completed)
        alertVC.addAction(action)
        controller?.present(alertVC, animated: true, completion: nil)
    }
}

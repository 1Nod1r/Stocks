//
//  Extensions.swift
//  Stocks
//
//  Created by Nodirbek on 24/05/22.
//

import Foundation
import UIKit

// MARK: Notification

extension Notification.Name {
    static let didAddWatchlist = Notification.Name("didAddWatchlist")
}


// MARK: NumberFormatter

extension NumberFormatter {
    static let percentFormmater: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = .current
        numberFormatter.numberStyle = .percent
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter
    }()
    
    static let numberFormmater : NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = .current
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter
    }()
}

// MARK: UIImageView

extension UIImageView {
    func setImage(with url: URL?){
        guard let url = url else { return }
        DispatchQueue.global(qos: .userInteractive).async {
            let task = URLSession.shared.dataTask(with: url) {[weak self] data, _, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    self?.image = UIImage(data: data)
                }
            }
            task.resume()
        }
    }
}

// MARK: String

extension String {
    static func string(from timeInterval: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timeInterval)
        return DateFormatter.prettyDateFormatter.string(from: date)
    }
    
    static func percentage(from double: Double) -> String {
        let formatter = NumberFormatter.percentFormmater
        return formatter.string(from: NSNumber(value: double)) ?? "\(double)"
    }
    
    static func formatted(number: Double) -> String {
        let formatter = NumberFormatter.numberFormmater
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

// MARK: DateFormatter

extension DateFormatter {
    static let newsDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        return formatter
    }()
    
    static let prettyDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

// MARK: UIView

extension UIView {
    func addSubviews(_ views: UIView...){
        views.forEach { addSubview($0) }
    }
}

extension UIView {
    
    var width: CGFloat {
        return frame.size.width
    }
    
    var height: CGFloat {
        return frame.size.height
    }
    
    var left: CGFloat {
        return frame.origin.x
    }
    
    var right: CGFloat {
        return left + width
    }
    
    var top: CGFloat {
        return frame.origin.y
    }
    
    var bottom: CGFloat {
        return right + height
    }
    
}

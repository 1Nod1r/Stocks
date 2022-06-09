//
//  HapticksManager.swift
//  Stocks
//
//  Created by Nodirbek on 23/05/22.
//

import Foundation
import UIKit

class HapticsManager {
    static let shared = HapticsManager()
    
    private init(){}
    
    // MARK: - Public
    
    public func vibrateForSelection(){
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    // Vibrate for type
    public func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType){
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
    
}

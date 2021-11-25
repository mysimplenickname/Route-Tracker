//
//  Blur.swift
//  Route Tracker
//
//  Created by Leo Malikov on 25.11.2021.
//

import UIKit

final class BlurManager {
    
    private let blurViewTag: Int = 330
    private let view: UIView
    
    init(for view: UIView) {
        self.view = view
        configureNotificationCenter()
    }
    
    deinit {
        deconfigureNotificationCenter()
    }
    
    private func addBlur() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.tag = blurViewTag
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
    }
    
    private func removeBlur() {
        if let blurView = view.viewWithTag(blurViewTag) {
            blurView.removeFromSuperview()
        }
    }
    
    private func configureNotificationCenter() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeInactive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
    
    private func deconfigureNotificationCenter() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
    
    @objc private func applicationDidBecomeInactive() {
        addBlur()
    }
    
    @objc private func applicationDidBecomeActive() {
        removeBlur()
    }
    
}

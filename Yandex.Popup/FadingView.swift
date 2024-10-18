//
//  FadingView.swift
//  Yandex.Popup
//
//  Copyright © 2024 Yandex L.L.C. All rights reserved.

import Foundation
import Cocoa

class FadingView: NSView {
    
    var gradientColor: NSColor = .black {
        didSet {
            updateGradientLayer()
        }
    }
    
    private let gradientLayer = CAGradientLayer()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupLayer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayer()
    }
    
    public func fadeIn() {
        self.gradientColor = .clear
    }
    
    public func fadeOut() {
        self.gradientColor = .black
    }
    
    private func setupLayer() {
        wantsLayer = true
        guard let layer = self.layer else { return }

        gradientLayer.colors = [
            NSColor.white.withAlphaComponent(1.0).cgColor, // Начальный цвет (например, белый)
            gradientColor.cgColor // Конечный цвет (например, прозрачный)
        ]
        gradientLayer.locations = [0.65, 0.7]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        layer.mask = gradientLayer
    }

    private func updateGradientLayer() {
        gradientLayer.colors = [
            NSColor.white.withAlphaComponent(1.0).cgColor,
            gradientColor.cgColor
        ]
    }
    
    override func layout() {
        super.layout()
        gradientLayer.frame = bounds
    }

}


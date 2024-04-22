//
//  AppViewStyles.swift
//  NetworkScan
//
//  Created by Volodymyr Tretiak on 22.04.2024.
//

import UIKit

struct AppViewStyles {
    // Buttons
    static func addBlueButtonStyle(for button: UIButton, title: String) {
        button.backgroundColor = AppColors.Purple.defaultPurple
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20.0, weight: .semibold)
        button.setTitle(title, for: .normal)
        button.layer.cornerRadius = 25.0
        button.clipsToBounds = true
    }
}

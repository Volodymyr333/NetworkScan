//
//  MagneticDetectionViewController.swift
//  NetworkScan
//
//  Created by Volodymyr Tretiak on 19.04.2024.
//

import SnapKit
import UIKit

class MagneticDetectionViewController: UIViewController {
    enum State {
        case search
        case stop
    }
    
    
    // MARK: Properties
    
    private lazy var mainView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "fireplaceImage")
        return imageView
    }()
    
    
    private lazy var topContainerView: UIView = {
        let view = UIImageView()
        view.backgroundColor = .black.withAlphaComponent(0.4)
        return view
    }()
    
    private lazy var topImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "magnetImage")
        return imageView
    }()
    
    private lazy var scaleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "scaleImage")
        return imageView
    }()
    
    private lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "purpleArrowImage")
        return imageView
    }()
    
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 17.0, weight: .medium)
        label.textAlignment = .center
        label.text = NSLocalizedString("search_checking_title", comment: "")
        return label
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .custom)
        AppViewStyles.addBlueButtonStyle(for: button, title: buttonTitle)
        button.addTarget(self, action: #selector(actionButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    private var activeState: State = .stop {
        didSet {
            actionButton.setTitle(buttonTitle, for: .normal)
            
            switch activeState {
            case .search:
                startChecking()
            case .stop:
                stopChecking()
            }
        }
    }
    
    private var buttonTitle: String {
        switch activeState {
        case .search:
            NSLocalizedString("stop_title", comment: "")
        case .stop:
            NSLocalizedString("search_title", comment: "")
        }
    }
    
    private var timer: Timer?
    private var second = 0
    private var timeInterval = 1.0
    
    private let arrowWidth: CGFloat = 100
    private let arrowHeight: CGFloat = 32
    
    private var maxValue: CGFloat = 100
    private var currentValue: CGFloat = 0.0 {
        didSet {
            if currentValue > 0.0 {
                valueLabel.text = String(Int(currentValue)) + " " + NSLocalizedString("microtesla_symbol_short", comment: "")
            } else {
                valueLabel.text = NSLocalizedString("search_checking_title", comment: "")
            }
        }
    }
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        setupInterface()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addGradient(to: mainView)
    }
    
    deinit {
        timer?.invalidate()
    }
    
    
    // MARK: Logic
    // The logic of the condition of continuous measurement data collection
    
    /// Several values are used for the example
    private func getValues() -> [CGFloat] {
        return [20.0, 30.0, 40.0, 50.0, 45.0, 51.0, 50.0]
    }
    
    private func getMeasurementValue() {
        guard getValues().count > second else {
            activeState = .stop
            return
        }
        
        currentValue = getValues()[second]
        addRotationAnimation(for: arrowImageView, duration: timeInterval)
        second += 1
    }
    
    private func startChecking() {
        if currentValue != 0.0 {
            currentValue = 0.0
            addRotationAnimation(for: arrowImageView, duration: 0.1)
        }
        startTimer()
    }
    
    private func stopChecking() {
        timer?.invalidate()
        second = 0
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    
    // MARK: UI
    
    private func setupNavBar() {
        title = NSLocalizedString("magnetic_detection_title", comment: "")
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
    }
    
    private func setupInterface() {
        view.addSubview(backgroundImageView)
        view.addSubview(mainView)
        mainView.addSubview(topContainerView)
        topContainerView.addSubview(topImageView)
        mainView.addSubview(scaleImageView)
        mainView.addSubview(actionButton)
        scaleImageView.addSubview(arrowImageView)
        mainView.addSubview(valueLabel)
        
        setupConstraints()
        view.setNeedsUpdateConstraints()
    }
    
    private func setupConstraints() {
        backgroundImageView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(view.snp.width).multipliedBy(1.41)
        }
        
        mainView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        topContainerView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(mainView.snp.width).multipliedBy(0.85)
        }
        
        topImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(34.0)
            make.right.equalToSuperview().offset(-34.0)
            make.top.equalTo(topContainerView.safeAreaLayoutGuide.snp.top).offset(18.0)
            make.bottom.equalToSuperview().offset(-28.0)
        }
        
        scaleImageView.snp.makeConstraints { make in
            make.centerX.equalTo(mainView.snp.centerX)
            make.top.equalTo(topContainerView.snp.bottom).offset(62.0).priority(.medium)
            make.left.equalToSuperview().offset(20.0)
            make.right.equalToSuperview().offset(-20.0)
            make.height.equalTo(scaleImageView.snp.width).multipliedBy(0.511)
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.top.equalTo(scaleImageView.snp.top).offset((view.bounds.width - 40) * 0.44)
            make.centerX.equalToSuperview().offset(-(arrowWidth - arrowHeight) / 2)
            make.width.equalTo(arrowWidth)
            make.height.equalTo(arrowHeight)
        }
        
        valueLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20.0)
            make.right.equalToSuperview().offset(-20.0)
            make.top.equalTo(arrowImageView.snp.bottom).offset(46.0).priority(.medium)
        }
        
        actionButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20.0)
            make.right.equalToSuperview().offset(-20.0)
            make.bottom.equalToSuperview().offset(-36.0)
            make.top.greaterThanOrEqualTo(valueLabel.snp.bottom).offset(30.0)
            make.height.equalTo(50.0)
        }
    }
    
    private func addRotationAnimation(for view: UIView, duration: TimeInterval) {
        let anchorPoint = CGPoint(x: (arrowWidth - arrowHeight / 2) / arrowWidth, y: 0.5)
        arrowImageView.setAnchorPoint(anchorPoint)
        
        UIView.animate(withDuration: duration) {
            self.arrowImageView.transform = CGAffineTransform(rotationAngle: self.currentValue  / self.maxValue * .pi)
        }
    }
    
    private func addGradient(to view: UIView) {
        view.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor.black.cgColor,
            AppColors.Purple.defaultPurple.withAlphaComponent(0.3).cgColor,
            UIColor.black.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.08)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.36)
        
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    
    // MARK: Actions
    
    @objc private func actionButtonTapped(_ sender: UIButton) {
        switch activeState {
        case .search:
            activeState = .stop
        case .stop:
            activeState = .search
        }
    }
    
    @objc func timerAction() {
        getMeasurementValue()
    }
}

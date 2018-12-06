//
//  LumenIntroViewController.swift
//  Client
//
//  Created by Mahmoud Adam on 11/26/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit
struct LumenIntroUX {
    static let imageHeight: CGFloat = 375
}

class LumenIntroViewController: UIViewController {
    weak var delegate: IntroViewControllerDelegate?
    
    // We need to hang on to views so we can animate and change constraints as we scroll
    var cardViews = [LumenCardView]()
    var cards = LumenIntroCard.defaultCards()
    var horizontalPadding: Int {
        return self.view.frame.width <= 320 ? 20 : 50
    }
    
    var topOffset : CGFloat {
        if isIphoneX { return 50 }
        return self.view.frame.width <= 320 ? -30 : 20
    }
    
    var bottomOffset : CGFloat {
        if isIphoneX { return 70 }
        return self.view.frame.width <= 320 ? 10 : 20
    }
    
    var verticalPadding: CGFloat {
        if isIphoneX { return 25 }
        return self.view.frame.width <= 320 ? 10 : 20
    }
    
    var isIphoneX: Bool {
         return UIDevice.current.isiPhoneXDevice()
    }
    
    private let backgroundView = LoginGradientView()
    
    lazy fileprivate var startBrowsingButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = AuthenticationUX.blue
        button.layer.cornerRadius = 15.0
        button.setTitle(CliqzStrings.LumenOnboarding().getStartedButtonText, for: UIControlState())
        button.setTitleColor(.white, for: UIControlState())
        button.addTarget(self, action: #selector(startBrowsing), for: UIControlEvents.touchUpInside)
        button.accessibilityIdentifier = "IntroViewController.startBrowsingButton"
        button.isHidden = true
        return button
    }()
    
    lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.pageIndicatorTintColor = UIColor.cliqzBlueOneSecondary.withAlphaComponent(0.3)
        pc.currentPageIndicatorTintColor = AuthenticationUX.blue
        pc.accessibilityIdentifier = "IntroViewController.pageControl"
        pc.addTarget(self, action: #selector(IntroViewController.changePage), for: UIControlEvents.valueChanged)
        return pc
    }()
    
    lazy fileprivate var scrollView: UIScrollView = {
        let sc = UIScrollView()
        sc.backgroundColor = UIColor.clear
        sc.accessibilityLabel = NSLocalizedString("Intro Tour Carousel", comment: "Accessibility label for the introduction tour carousel")
        sc.delegate = self
        sc.bounces = false
        sc.isPagingEnabled = true
        sc.showsHorizontalScrollIndicator = false
        sc.accessibilityIdentifier = "IntroViewController.scrollView"
        sc.isUserInteractionEnabled = true
        return sc
    }()
    
    lazy var optInView: OptInView = {
        let optInView = OptInView()
        optInView.setCustomIcons(normalIcon: "blank-lumen-toggle", selectedIcon: "selected-lumen-toggle")
        optInView.clipsToBounds = false
        optInView.textLabel.numberOfLines = 0
        optInView.textLabel.adjustsFontSizeToFitWidth = true
        optInView.textLabel.minimumScaleFactor = 0.2
        optInView.textLabel.textAlignment = .left
        optInView.textLabel.textColor = UIColor.white
        optInView.textLabel.text = CliqzStrings.LumenOnboarding().telemetryText
        optInView.toggle.isSelected = true
        return optInView
    }()
    
    lazy fileprivate var imageViewContainer: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.backgroundColor = .clear
        return sv
    }()
    
    override func viewDidLoad() {
        assert(cards.count > 1, "Intro is empty. At least 2 cards are required")
        view.backgroundColor = UIColor.clear
        
        // Add Views
        view.addSubview(backgroundView)
        view.addSubview(scrollView)
        view.addSubview(pageControl)
        view.addSubview(startBrowsingButton)
        view.addSubview(optInView)
        scrollView.addSubview(imageViewContainer)
        
        optInView.delegate = self
        optInView.snp.makeConstraints { make in
            make.trailing.leading.equalToSuperview()
            make.height.equalTo(44)
            make.bottom.equalToSuperview().inset(bottomOffset)
        }
        
        // Setup constraints
        imageViewContainer.snp.makeConstraints { make in
            make.top.equalTo(self.view).offset(topOffset)
            make.height.equalTo(LumenIntroUX.imageHeight)
        }
        startBrowsingButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(30)
            make.bottom.equalTo(optInView.snp.top).offset(-verticalPadding)
            make.height.equalTo(30)
        }
        scrollView.snp.makeConstraints { make in
            make.left.right.top.equalTo(self.view)
            make.bottom.equalTo(startBrowsingButton.snp.top)
        }
        
        pageControl.snp.makeConstraints { make in
            make.centerX.equalTo(self.scrollView)
            make.bottom.equalTo(self.startBrowsingButton.snp.top).offset(-10)
        }
        
        createSlides()
        pageControl.addTarget(self, action: #selector(changePage), for: .valueChanged)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.backgroundView.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.backgroundView.gradient.frame = self.backgroundView.bounds
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = imageContainerSize()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    func createSlides() {
        // Make sure the scrollView has been setup before setting up the slides
        guard scrollView.superview != nil else {
            return
        }
        // Wipe any existing slides
        imageViewContainer.subviews.forEach { $0.removeFromSuperview() }
        cardViews.forEach { $0.removeFromSuperview() }
        cardViews = cards.compactMap { addIntro(card: $0) }
        pageControl.numberOfPages = cardViews.count
        setupDynamicFonts()
        if let firstCard = cardViews.first {
            setActive(firstCard, forPage: 0)
        }
        imageViewContainer.layoutSubviews()
        scrollView.contentSize = imageContainerSize()
        startBrowsingButton.isHidden = false
    }
    
    func addIntro(card: LumenIntroCard) -> LumenCardView? {
        guard let image = UIImage(named: card.imageName) else {
            return nil
        }
        let imageView = UIImageView(image: image)
        imageViewContainer.addArrangedSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.width.equalTo(self.view.snp.width)
            make.height.equalTo(self.view.snp.width)
        }
        
        let cardView: LumenCardView
        cardView = LumenCardView(verticleSpacing: verticalPadding)
        cardView.configureWith(card: card)
        self.view.addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.top.equalTo(self.imageViewContainer.snp.bottom).offset(-10)
            make.bottom.equalTo(self.startBrowsingButton.snp.top)
            make.left.right.equalTo(self.view).inset(10)
        }
        return cardView
    }
    
    @objc func startBrowsing() {
        // Start the necessary stuff for antitracking
        delegate?.introViewControllerDidFinish(self, requestToLogin: false)
    }
    
    func login() {
        delegate?.introViewControllerDidFinish(self, requestToLogin: true)
    }
    
    @objc func changePage() {
        let swipeCoordinate = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x: swipeCoordinate, y: 0), animated: true)
    }
    
    fileprivate func setActive(_ introView: UIView, forPage page: Int) {
        guard introView.alpha != 1 else {
            return
        }
        
        UIView.animate(withDuration: IntroUX.FadeDuration, animations: {
            self.cardViews.forEach { $0.alpha = 0.0 }
            introView.alpha = 1.0
            introView.superview?.bringSubview(toFront: introView)
            introView.isUserInteractionEnabled = true
            self.pageControl.currentPage = page
        }, completion: nil)
    }
    
    func imageContainerSize() -> CGSize {
        return CGSize(width: self.view.frame.width * CGFloat(cards.count), height: LumenIntroUX.imageHeight)
    }

}
//MARK:- OptInViewDelegate
extension LumenIntroViewController: OptInViewDelegate {
    func toggled(value: Bool) {
        SettingsPrefs.shared.updateSendUsageDataPref(value)
        SettingsPrefs.shared.updateSendCrashReportsPref(value)
    }
}

//MARK:- Dynamic Font Helper
extension LumenIntroViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Gradient Background
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = [UIColor(red:0.31, green:0.67, blue:0.91, alpha:1.00).cgColor, UIColor.black.cgColor]
        gradient.locations = [0.0 , 1.0]
        let width: CGFloat
        let height: CGFloat
        
        //Fix for gradient bug when the intro is shown while the device is in landscape.
        if UIDevice.current.getDeviceAndOrientation().1 == .portrait && self.view.frame.size.width > self.view.frame.size.height {
            width = self.view.frame.size.height
            height = self.view.frame.size.width
        }
        else {
            width = self.view.frame.width
            height = self.view.frame.height
        }
        
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        
        self.view.layer.insertSublayer(gradient, at: 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(dynamicFontChanged(_:)), name: .DynamicFontChanged, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .DynamicFontChanged, object: nil)
    }
    
    @objc func dynamicFontChanged(_ notification: Notification) {
        guard notification.name == .DynamicFontChanged else { return }
        setupDynamicFonts()
    }
    
    fileprivate func setupDynamicFonts() {
        
        startBrowsingButton.titleLabel?.font = UIFont.systemFont(ofSize: 14.0, weight: .light)
        cardViews.forEach { cardView in
            cardView.titleLabel.font = UIFont.systemFont(ofSize: 20.0, weight: .regular)
            cardView.textLabel.font = UIFont.systemFont(ofSize: 16.0, weight: .light)
        }
    }
}

//MARK:- ScrollViewDelegate
extension LumenIntroViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // Need to add this method so that when forcibly dragging, instead of letting deceleration happen, should also calculate what card it's on.
        // This especially affects sliding to the last or first cards.
        if !decelerate {
            scrollViewDidEndDecelerating(scrollView)
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        // Need to add this method so that tapping the pageControl will also change the card texts.
        // scrollViewDidEndDecelerating waits until the end of the animation to calculate what card it's on.
        scrollViewDidEndDecelerating(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        if let cardView = cardViews[safe: page] {
            setActive(cardView, forPage: page)
        }
        startBrowsingButton.isHidden = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //empty
    }
}
//MARK:- CardView
class LumenCardView: UIView {
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        return stackView
    }()
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = IntroUX.MinimumFontScale
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        titleLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .vertical)
        return titleLabel
    }()
    
    lazy var textLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.numberOfLines = 5
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.minimumScaleFactor = IntroUX.MinimumFontScale
        textLabel.textAlignment = .center
        textLabel.textColor = UIColor.white
        textLabel.lineBreakMode = .byTruncatingTail
        textLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .vertical)
        return textLabel
    }()
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(verticleSpacing: CGFloat) {
        super.init(frame: .zero)
        stackView.spacing = verticleSpacing
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(textLabel)
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(self)
            make.bottom.lessThanOrEqualTo(self).offset(-IntroUX.PageControlHeight)
        }
        alpha = 0
        self.isUserInteractionEnabled = true
    }
    
    func configureWith(card: LumenIntroCard) {
        titleLabel.text = card.title
        textLabel.text = card.text
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
    
}
//MARK:- Card DataModel
struct LumenIntroCard: Codable, Equatable {
    let title: String
    let text: String
    let imageName: String
    
    init(title: String, text: String, imageName: String) {
        self.title = title
        self.text = text
        self.imageName = imageName
    }
    
    static func defaultCards() -> [LumenIntroCard] {
       
        
        let onboardingStrings = CliqzStrings.LumenOnboarding()
        
        let welcome = LumenIntroCard(title: onboardingStrings.introTitle, text: onboardingStrings.introText, imageName: "lumen-Logo")
        let adblock = LumenIntroCard(title: onboardingStrings.adblockerTitle, text: onboardingStrings.adblockerText, imageName: "lumen-Adblock")
        let vpn = LumenIntroCard(title: onboardingStrings.vpnTitle, text: onboardingStrings.vpnText, imageName: "lumen-VPN")
        let dashboard = LumenIntroCard(title: onboardingStrings.dashboardTitle, text: onboardingStrings.dashboardText, imageName: "lumen-Dashboard")
        return [welcome, adblock, vpn, dashboard]
    }
    
    
    /* Codable doesnt allow quick conversion to a dictonary */
    func asDictonary() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
    
    static func == (lhs: LumenIntroCard, rhs: LumenIntroCard) -> Bool {
        return lhs.imageName == rhs.imageName && lhs.text == rhs.text && lhs.title == rhs.title
    }
}

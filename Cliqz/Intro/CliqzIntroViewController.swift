//
//  CliqzIntroViewController.swift
//  Client
//
//  Created by Tim Palade on 5/18/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit
import Shared

struct CliqzIntroUX {
    static let imageHeight: CGFloat = 290
}

class CliqzIntroViewController: UIViewController {
    weak var delegate: IntroViewControllerDelegate?
    
    // We need to hang on to views so we can animate and change constraints as we scroll
    var cardViews = [CliqzCardView]()
    var cards = CliqzIntroCard.defaultCards()
    
    lazy fileprivate var startBrowsingButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.cliqzBluePrimary
        button.layer.cornerRadius = 23.0
        button.setTitle(Strings.StartBrowsingButtonTitle, for: UIControlState())
        button.setTitleColor(.white, for: UIControlState())
        button.addTarget(self, action: #selector(startBrowsing), for: UIControlEvents.touchUpInside)
        button.accessibilityIdentifier = "IntroViewController.startBrowsingButton"
        button.isHidden = true
        return button
    }()
    
    lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.pageIndicatorTintColor = UIColor.cliqzBlueOneSecondary.withAlphaComponent(0.3)
        pc.currentPageIndicatorTintColor = UIColor.cliqzBluePrimary
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
    
    var horizontalPadding: Int {
        return self.view.frame.width <= 320 ? 20 : 50
    }
    
    var verticalPadding: CGFloat {
        return self.view.frame.width <= 320 ? 10 : 20
    }
    
    lazy fileprivate var imageViewContainer: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.backgroundColor = .clear
        return sv
    }()
    
    // Because a stackview cannot have a background color
    fileprivate var imagesBackgroundView = UIView()
    
    override func viewDidLoad() {
        assert(cards.count > 1, "Intro is empty. At least 2 cards are required")
        view.backgroundColor = UIColor.clear
        imagesBackgroundView.backgroundColor = UIColor.clear
        
        // Gradient Background
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = [UIColor(red:0.31, green:0.67, blue:0.91, alpha:1.00).cgColor, UIColor.black.cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        
        self.view.layer.insertSublayer(gradient, at: 0)

        // Add Views
        view.addSubview(pageControl)
        view.addSubview(scrollView)
        view.addSubview(startBrowsingButton)
        scrollView.addSubview(imagesBackgroundView)
        scrollView.addSubview(imageViewContainer)

        // Setup constraints
        imagesBackgroundView.snp.makeConstraints { make in
            make.edges.equalTo(imageViewContainer)
        }
        imageViewContainer.snp.makeConstraints { make in
            make.top.equalTo(self.view)
            make.height.equalTo(CliqzIntroUX.imageHeight)
        }
        startBrowsingButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2.2)
            make.bottom.equalTo(self.view.safeArea.bottom).offset(-IntroUX.PagerCenterOffsetFromScrollViewBottom)
            make.height.equalTo(45)
        }
        scrollView.snp.makeConstraints { make in
            make.left.right.top.equalTo(self.view)
            make.bottom.equalTo(startBrowsingButton.snp.top)
        }

        pageControl.snp.makeConstraints { make in
            make.centerX.equalTo(self.scrollView)
            make.centerY.equalTo(self.startBrowsingButton.snp.top).offset(-IntroUX.PagerCenterOffsetFromScrollViewBottom)
        }

        createSlides()
        pageControl.addTarget(self, action: #selector(changePage), for: .valueChanged)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = imageContainerSize()
    }
    
    func createSlides() {
        // Make sure the scrollView has been setup before setting up the slides
        guard scrollView.superview != nil else {
            return
        }
        // Wipe any existing slides
        imageViewContainer.subviews.forEach { $0.removeFromSuperview() }
        cardViews.forEach { $0.removeFromSuperview() }
        cardViews = cards.flatMap { addIntro(card: $0) }
        pageControl.numberOfPages = cardViews.count
        setupDynamicFonts()
        if let firstCard = cardViews.first {
            setActive(firstCard, forPage: 0)
        }
        imageViewContainer.layoutSubviews()
        scrollView.contentSize = imageContainerSize()
        startBrowsingButton.isHidden = false
    }
    
    func addIntro(card: CliqzIntroCard) -> CliqzCardView? {
        guard let image = UIImage(named: card.imageName) else {
            return nil
        }
        let imageView = UIImageView(image: image)
        imageViewContainer.addArrangedSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.height.equalTo(imageViewContainer.snp.height)
            make.width.equalTo(self.view.snp.width)
        }
        
        let cardView = CliqzCardView(verticleSpacing: verticalPadding)
        cardView.configureWith(card: card)
        
        if let tickButtons = cardView.tickButtons {
            for i in 0..<tickButtons.count {
                let tickButton = tickButtons[i]
                tickButton.addTarget(self, action: #selector(tickButtonPressed), for: .touchUpInside)
                tickButton.tag = i + 1
            }
        }
        
        if let _ = card.optInText, let _ = card.optInToggleValue { /*, self.responds(to: NSSelectorFromString(selectorString)) {*/
            //cardView.button.addTarget(self, action: NSSelectorFromString(selectorString), for: .touchUpInside)
            cardView.optInView.snp.makeConstraints { make in
                make.trailing.leading.equalToSuperview()
                make.height.equalTo(44)
            }
            cardView.optInView.delegate = self
        }
        self.view.addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.top.equalTo(self.imageViewContainer.snp.bottom)//.offset(verticalPadding)
            make.bottom.equalTo(self.startBrowsingButton.snp.top)
            make.left.right.equalTo(self.view).inset(10)
        }
        return cardView
    }
    
    @objc func tickButtonPressed(_ sender: UIButton) {
        //assume: Only one card with tick buttons
        let tickButtonCard = cardViews.filter { (card) -> Bool in
            return card.tickButtons != nil
            }.first
        
        if let tickButtonCard = tickButtonCard, let tickButtons = tickButtonCard.tickButtons {
            for tickButton in tickButtons {
                tickButton.isSelected = false
            }
        }
        
        sender.isSelected = true
    }
    
    @objc func startBrowsing() {
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
        return CGSize(width: self.view.frame.width * CGFloat(cards.count), height: CliqzIntroUX.imageHeight)
    }
}

extension CliqzIntroViewController: OptInViewDelegate {
    func toggled(value: Bool) {
        if pageControl.currentPage == 0 {
            SettingsPrefs.shared.updateSendUsageDataPref(value)
            SettingsPrefs.shared.updateHumanWebPref(value)
            SettingsPrefs.shared.updateSendCrashReportsPref(value)
        }
    }
}

// UIViewController setup
extension CliqzIntroViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // This actually does the right thing on iPad where the modally
        // presented version happily rotates with the iPad orientation.
        return .portrait
    }
}

// Dynamic Font Helper
extension CliqzIntroViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        startBrowsingButton.titleLabel?.font = UIFont(name: "FiraSans-Regular", size: DynamicFontHelper.defaultHelper.IntroStandardFontSize)
        cardViews.forEach { cardView in
            cardView.titleLabel.font = UIFont(name: "FiraSans-Medium", size: 22)
            cardView.textLabel.font = UIFont(name: "FiraSans-Regular", size: DynamicFontHelper.defaultHelper.IntroStandardFontSize)
            cardView.optInView.textLabel.font = UIFont(name: "FiraSans-Regular", size: DynamicFontHelper.defaultHelper.IntroStandardFontSize)
        }
    }
}

extension CliqzIntroViewController: UIScrollViewDelegate {
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

// A cardView repersents the text for each page of the intro. It does not include the image.
class CliqzCardView: UIView {
    
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
    
    lazy var optInView: OptInView = {
        let optInView = OptInView()
        optInView.clipsToBounds = false
        optInView.textLabel.numberOfLines = 0
        optInView.textLabel.adjustsFontSizeToFitWidth = true
        optInView.textLabel.minimumScaleFactor = 0.2
        optInView.textLabel.textAlignment = .left
        optInView.textLabel.textColor = UIColor.white
        return optInView
    }()
    
    
    var tickButtons: [TickButton]? = nil
    
    func createTickButton(info: TickButtonInfo) -> TickButton {
        
        var subtitle: Bool = false
        
        if info.subtitle != nil {
            subtitle = true
        }
        
        let tickButton = TickButton(subtitle: subtitle)
        tickButton.setTitle(info.title, for: [])
        tickButton.subtitleLabel.text = info.subtitle
        if info.selected {
            tickButton.isSelected = true
        }
        return tickButton
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
    
    func configureWith(card: CliqzIntroCard) {
        titleLabel.text = card.title
        textLabel.text = card.text
        if let optInText = card.optInText, let optInToggleValue = card.optInToggleValue {
            stackView.addArrangedSubview(optInView)
            optInView.textLabel.text = optInText
            optInView.toggle.isSelected = optInToggleValue
            // When there is a button reduce the spacing to make more room for text
            stackView.spacing = stackView.spacing / 2
        }
        
        if let tickButtonsInfo = card.tickButtons {
            
            let buttonStackView = UIStackView()
            buttonStackView.axis = .vertical
            buttonStackView.alignment = .center
            buttonStackView.spacing = 0
            
            stackView.addArrangedSubview(buttonStackView)
            buttonStackView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
            }
            
            tickButtons = []
            for i in 0..<tickButtonsInfo.count {
                let info = tickButtonsInfo[i]
                let tickButton = createTickButton(info: info)
                buttonStackView.addArrangedSubview(tickButton)
                tickButton.snp.makeConstraints { (make) in
                    make.left.right.equalToSuperview()
                    make.height.equalTo(50)
                }
                if i != tickButtonsInfo.count - 1 {
                    tickButton.bottomSep.isHidden = true
                }
                tickButton.label.textColor = .white
                tickButton.subtitleLabel.textColor = .white
                tickButton.label.font = UIFont.systemFont(ofSize: 16)
                tickButton.subtitleLabel.font = UIFont.systemFont(ofSize: 12)
                tickButton.sepColor = UIColor.white.withAlphaComponent(0.2)
                tickButton.bgColorSelected = UIColor.white.withAlphaComponent(0.2)
                tickButton.isEnabled = true
                tickButton.isUserInteractionEnabled = true
                
                tickButtons?.append(tickButton)
            }
        }
    }
    
    // Allows the scrollView to scroll while the CardView is in front
//    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
//        if let buttonSV = optInView.superview {
//            return convert(optInView.frame, from: buttonSV).contains(point)
//        }
//        return false
//    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct TickButtonInfo: Codable {
    let title: String
    let subtitle: String?
    let selected: Bool
}

struct CliqzIntroCard: Codable {
    let title: String
    let text: String
    let imageName: String
    let optInText: String?
    let optInToggleValue: Bool?
    let tickButtons: [TickButtonInfo]?
    
    init(title: String, text: String, imageName: String, optInText: String? = nil, optInToggleValue: Bool? = nil, tickButtons: [TickButtonInfo]? = nil) {
        self.title = title
        self.text = text
        self.imageName = imageName
        self.optInText = optInText
        self.optInToggleValue = optInToggleValue
        self.tickButtons = tickButtons
    }
    
    static func defaultCards() -> [CliqzIntroCard] {
        
        var oldUser: Bool = false
        if let _ = UserDefaults.standard.value(forKey: HasRunBeforeKey) as? String {
            oldUser = true
        }
        
        let OnboardingStrings = CliqzStrings.Onboarding()
        
        let welcome: CliqzIntroCard
        if oldUser {
            welcome = CliqzIntroCard(title: OnboardingStrings.introTitleOldUsers, text: OnboardingStrings.introTextOldUsers, imageName: "ghostery-Introduction", optInText: OnboardingStrings.telemetryText, optInToggleValue: true)
        }
        else {
            welcome = CliqzIntroCard(title: OnboardingStrings.introTitle, text: OnboardingStrings.introText, imageName: "ghostery-Introduction", optInText: OnboardingStrings.telemetryText, optInToggleValue: true)
        }
        let adblock = CliqzIntroCard(title: OnboardingStrings.adblockerTitle, text: OnboardingStrings.adblockerText, imageName: "ghostery-Adblock", tickButtons: CliqzIntroCard.createAdblockerTickButtons())
        let quicksearch = CliqzIntroCard(title: OnboardingStrings.quickSearchTitle, text: OnboardingStrings.quickSearchText, imageName: "ghostery-QuickSearch")
        let freshtab = CliqzIntroCard(title: OnboardingStrings.tabTitle, text: OnboardingStrings.tabText, imageName: "ghostery-CliqzTab")
        return [welcome, adblock, quicksearch, freshtab]
    }
    
    static func createAdblockerTickButtons() -> [TickButtonInfo] {
        let first = TickButtonInfo(title: "Block Nothing", subtitle: nil, selected: false)
        let second = TickButtonInfo(title: "Block Recommended", subtitle: "Ads, site analytics and adult advertising", selected: true)
        let third = TickButtonInfo(title: "Block Everything", subtitle: nil, selected: false)
        return [first, second, third]
    }
    
    /* Codable doesnt allow quick conversion to a dictonary */
    func asDictonary() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}

extension CliqzIntroCard: Equatable {
    static func == (lhs: CliqzIntroCard, rhs: CliqzIntroCard) -> Bool {
        return lhs.optInText == rhs.optInText && lhs.imageName == rhs.imageName && lhs.text == rhs.text && lhs.title == rhs.title
    }
}

protocol OptInViewDelegate: class {
    func toggled(value: Bool)
}

class OptInView: UIView {
    let toggle = UIButton()
    let textLabel = UILabel()
    
    weak var delegate: OptInViewDelegate? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        toggle.addTarget(self, action: #selector(toggled), for: .touchUpInside)
		toggle.setImage(UIImage(named: "blank"), for: .normal)
		toggle.setImage(UIImage(named: "selected"), for: .selected)
        addSubview(toggle)
        addSubview(textLabel)
        setConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setConstraints() {
        toggle.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(5)
			make.width.height.equalTo(40)
        }
        
        textLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
			make.leading.equalTo(toggle.snp.trailing).offset(7)
            make.trailing.equalToSuperview().offset(-7)
        }
    }
    
    @objc func toggled(_ sender: UIButton) {
		sender.isSelected = !sender.isSelected
        self.delegate?.toggled(value: sender.isSelected)
    }
}

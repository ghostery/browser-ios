//
//  CliqzIntroViewController.swift
//  Client
//
//  Created by Tim Palade on 5/18/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit
import Shared

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
        button.addTarget(self, action: #selector(IntroViewController.startBrowsing), for: UIControlEvents.touchUpInside)
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
        return sc
    }()
    
    var horizontalPadding: Int {
        return self.view.frame.width <= 320 ? 20 : 50
    }
    
    var verticalPadding: CGFloat {
        return self.view.frame.width <= 320 ? 10 : 38
    }
    
    lazy fileprivate var imageViewContainer: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        return sv
    }()
    
    // Because a stackview cannot have a background color
    fileprivate var imagesBackgroundView = UIView()
    
    override func viewDidLoad() {
        if AppConstants.MOZ_LP_INTRO {
            syncViaLP()
        }

        assert(cards.count > 1, "Intro is empty. At least 2 cards are required")
        view.backgroundColor = UIColor.white

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
            make.height.equalTo(self.view.snp.width)
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
    
    func syncViaLP() {
        /* Cliqz: comment references to LeanPlumClient
         let startTime = Date.now()
         LeanPlumClient.shared.introScreenVars?.onValueChanged({ [weak self] in
         guard let newIntro = LeanPlumClient.shared.introScreenVars?.object(forKey: nil) as? [[String: Any]] else {
         return
         }
         let decoder = JSONDecoder()
         let newCards = newIntro.flatMap { (obj) -> IntroCard? in
         guard let object = try? JSONSerialization.data(withJSONObject: obj, options: []) else {
         return nil
         }
         let card = try? decoder.decode(IntroCard.self, from: object)
         // Make sure the selector actually goes somewhere. Otherwise dont show that slide
         if let selectorString = card?.buttonSelector, let wself = self {
         return wself.responds(to: NSSelectorFromString(selectorString)) ? card : nil
         } else {
         return card
         }
         }
         
         guard newCards != IntroCard.defaultCards(), newCards.count > 1 else {
         return
         }
         
         // We need to still be on the first page otherwise the content will change underneath the user's finger
         // We also need to let LP know this happened so we can track when a A/B test was not run
         guard self?.pageControl.currentPage == 0 else {
         let totalTime = Date.now() - startTime
         LeanPlumClient.shared.track(event: .onboardingTestLoadedTooSlow, withParameters: ["Total time": "\(totalTime) ms" as AnyObject])
         return
         }
         
         self?.cards = newCards
         self?.createSlides()
         self?.viewDidLayoutSubviews()
         
         })
         */
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
            make.width.equalTo(imageViewContainer.snp.height)
        }
        
        let cardView = CliqzCardView(verticleSpacing: verticalPadding)
        cardView.configureWith(card: card)
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
            make.top.equalTo(self.imageViewContainer.snp.bottom).offset(verticalPadding)
            make.bottom.equalTo(self.startBrowsingButton.snp.top)
            make.left.right.equalTo(self.view).inset(10)
        }
        return cardView
    }
    
    func startBrowsing() {
        delegate?.introViewControllerDidFinish(self, requestToLogin: false)
        LeanPlumClient.shared.track(event: .dismissedOnboarding, withParameters: ["dismissedOnSlide": pageControl.currentPage as AnyObject])
    }
    
    func login() {
        delegate?.introViewControllerDidFinish(self, requestToLogin: true)
        LeanPlumClient.shared.track(event: .dismissedOnboardingShowLogin, withParameters: ["dismissedOnSlide": pageControl.currentPage as AnyObject])
    }
    
    func changePage() {
        let swipeCoordinate = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x: swipeCoordinate, y: 0), animated: true)
    }
    
    fileprivate func setActive(_ introView: UIView, forPage page: Int) {
        guard introView.alpha != 1 else {
            return
        }
        
        UIView.animate(withDuration: IntroUX.FadeDuration, animations: { _ in
            self.cardViews.forEach { $0.alpha = 0.0 }
            introView.alpha = 1.0
            self.pageControl.currentPage = page
        }, completion: nil)
    }
    
    func imageContainerSize() -> CGSize {
        return CGSize(width: self.view.frame.width * CGFloat(cards.count), height: 375)
    }
}

extension CliqzIntroViewController: OptInViewDelegate {
    func toggled(value: Bool) {
        if pageControl.currentPage == 0 {
            SettingsPrefs.shared.updateSendUsageDataPref(value)
            SettingsPrefs.shared.updateHumanWebPref(value)
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
        NotificationCenter.default.addObserver(self, selector: #selector(dynamicFontChanged), name: .DynamicFontChanged, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .DynamicFontChanged, object: nil)
    }
    
    func dynamicFontChanged(_ notification: Notification) {
        guard notification.name == .DynamicFontChanged else { return }
        setupDynamicFonts()
    }
    
    fileprivate func setupDynamicFonts() {
        startBrowsingButton.titleLabel?.font = UIFont(name: "FiraSans-Regular", size: DynamicFontHelper.defaultHelper.IntroStandardFontSize)
        cardViews.forEach { cardView in
            cardView.titleLabel.font = UIFont(name: "FiraSans-Medium", size: 25)
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
        let maximumHorizontalOffset = scrollView.frame.width
        let currentHorizontalOffset = scrollView.contentOffset.x
        
        var percentageOfScroll = currentHorizontalOffset / maximumHorizontalOffset
        percentageOfScroll = percentageOfScroll > 1.0 ? 1.0 : percentageOfScroll
        let whiteComponent = UIColor.white.components
        let grayComponent = UIColor(rgb: 0xF2F2F2).components
        let newRed   = (1.0 - percentageOfScroll) * whiteComponent.red   + percentageOfScroll * grayComponent.red
        let newGreen = (1.0 - percentageOfScroll) * whiteComponent.green + percentageOfScroll * grayComponent.green
        let newBlue  = (1.0 - percentageOfScroll) * whiteComponent.blue  + percentageOfScroll * grayComponent.blue
        imagesBackgroundView.backgroundColor = UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
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
        titleLabel.textColor = UIColor.cliqzBluePrimary
        titleLabel.setContentHuggingPriority(1000, for: .vertical)
        return titleLabel
    }()
    
    lazy var textLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.numberOfLines = 5
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.minimumScaleFactor = IntroUX.MinimumFontScale
        textLabel.textAlignment = .center
        textLabel.textColor = UIColor.cliqzBluePrimary
        textLabel.lineBreakMode = .byTruncatingTail
        textLabel.setContentHuggingPriority(1000, for: .vertical)
        return textLabel
    }()
    
    lazy var optInView: OptInView = {
        let optInView = OptInView()
        optInView.clipsToBounds = false
        optInView.textLabel.numberOfLines = 0
        optInView.textLabel.adjustsFontSizeToFitWidth = true
        optInView.textLabel.minimumScaleFactor = 0.2
        optInView.textLabel.textAlignment = .left
        optInView.textLabel.textColor = UIColor.cliqzBluePrimary
        return optInView
    }()
    
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
    }
    
    // Allows the scrollView to scroll while the CardView is in front
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if let buttonSV = optInView.superview {
            return convert(optInView.frame, from: buttonSV).contains(point)
        }
        return false
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct CliqzIntroCard: Codable {
    let title: String
    let text: String
    let imageName: String
    let optInText: String?
    let optInToggleValue: Bool?
    
    init(title: String, text: String, imageName: String, optInText: String? = nil, optInToggleValue: Bool? = nil) {
        self.title = title
        self.text = text
        self.imageName = imageName
        self.optInText = optInText
        self.optInToggleValue = optInToggleValue
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
        let adblock = CliqzIntroCard(title: OnboardingStrings.adblockerTitle, text: OnboardingStrings.adblockerText, imageName: "ghostery-Adblock")
        let quicksearch = CliqzIntroCard(title: OnboardingStrings.quickSearchTitle, text: OnboardingStrings.quickSearchText, imageName: "ghostery-QuickSearch")
        let freshtab = CliqzIntroCard(title: OnboardingStrings.tabTitle, text: OnboardingStrings.tabText, imageName: "ghostery-CliqzTab")
        return [welcome, adblock, quicksearch, freshtab]
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

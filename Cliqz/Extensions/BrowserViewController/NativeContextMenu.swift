//
//  NativeContextMenu.swift
//  Client
//
//  Created by Sahakyan on 3/15/18.
//  Copyright © 2018 Mozilla. All rights reserved.
//

import Foundation
import Shared
import Storage

extension BrowserViewController {
	
	@objc func urlBarDidPressPageCliqzOptions(notification: Notification) {
		print(notification)
		if let button = notification.object as? UIButton {
			self.showPageOptions(self.urlBar, from: button)
		}
	}
	
	private func showPageOptions(_ urlBar: URLBarView, from button: UIButton) {
		guard let tab = tabManager.selectedTab, let urlString = tab.url?.absoluteString else { return }
		
		let actionMenuPresenter = {
			guard let url = tab.canonicalURL?.displayURL else { return }
			self.presentActivityViewController(url, tab: tab, sourceView: button, sourceRect: button.bounds, arrowDirection: .up)
		}
		
		let findInPageAction = {
			self.updateFindInPageVisibility(visible: true)
		}
		
		let successCallback: (String) -> Void = { (successMessage) in
			SimpleToast().showAlertWithText(successMessage, bottomContainer: self.webViewContainer)
		}
		
		fetchBookmarkStatus(for: urlString).uponQueue(.main) {
			let isBookmarked = $0.successValue ?? false
			print($0)
			self.showTabActionSheet(tab: tab, buttonView: button, presentShareMenu: actionMenuPresenter, findInPage: findInPageAction, presentableVC: self, isBookmarked: isBookmarked, success: successCallback)
		}
	}

	private func showActionSheet(title: String?, message: String?, actions:[UIAlertAction]) {
		let alertController = UIAlertController (title: title, message: message, preferredStyle: .actionSheet)
		for action in actions {
			alertController.addAction(action)
		}
		DispatchQueue.main.async { [weak self] in
			self?.presentViewController(alertController, animated: true)
		}
	}

	private func showTabActionSheet(tab: Tab, buttonView: UIView,
					  presentShareMenu: @escaping () -> Void,
					  findInPage:  @escaping () -> Void,
					  presentableVC: PresentableVC,
					  isBookmarked: Bool,
					  success: @escaping (String) -> Void) {
		let actions = getTabAlertActions(tab: tab, buttonView: buttonView, presentShareMenu: presentShareMenu, findInPage: findInPage, presentableVC: presentableVC, isBookmarked: isBookmarked, success: success)
		self.showActionSheet(title: tab.url?.absoluteString, message: nil, actions: actions)
	}

	private func getTabAlertActions(tab: Tab, buttonView: UIView,
					   presentShareMenu: @escaping () -> Void,
					   findInPage:  @escaping () -> Void,
					   presentableVC: PresentableVC,
					   isBookmarked: Bool,
					   success: @escaping (String) -> Void) -> [UIAlertAction] {
		let toggleActionTitle = tab.desktopSite ? Strings.AppMenuViewMobileSiteTitleString : Strings.AppMenuViewDesktopSiteTitleString
		let toggleDesktopSite = UIAlertAction(title: toggleActionTitle, style: .default) { (action) in
			tab.toggleDesktopSite()
		}

		let addReadingList = UIAlertAction(title: Strings.AppMenuAddToReadingListTitleString, style: .default) { (action) in
			guard let url = tab.url?.displayURL else { return }
			
			self.profile.readingList?.createRecordWithURL(url.absoluteString, title: tab.title ?? "", addedBy: UIDevice.current.name)
			UnifiedTelemetry.recordEvent(category: .action, method: .add, object: .readingListItem, value: .pageActionMenu)
			success(Strings.AppMenuAddToReadingListConfirmMessage)
		}
		
		let findInPageAction = UIAlertAction(title: Strings.AppMenuFindInPageTitleString, style: .default) { (action) in
			findInPage()
		}
	
		let bookmarkPage = UIAlertAction(title: Strings.AppMenuAddBookmarkTitleString, style: .default) { (action) in
			//TODO: can all this logic go somewhere else?
			guard let url = tab.canonicalURL?.displayURL else { return }
			let absoluteString = url.absoluteString
			let shareItem = ShareItem(url: absoluteString, title: tab.title, favicon: tab.displayFavicon)
			_ = self.profile.bookmarks.shareItem(shareItem)
			var userData = [QuickActions.TabURLKey: shareItem.url]
			if let title = shareItem.title {
				userData[QuickActions.TabTitleKey] = title
			}
			QuickActions.sharedInstance.addDynamicApplicationShortcutItemOfType(.openLastBookmark,
																				withUserData: userData,
																				toApplication: .shared)
			UnifiedTelemetry.recordEvent(category: .action, method: .add, object: .bookmark, value: .pageActionMenu)
			success(Strings.AppMenuAddBookmarkConfirmMessage)
		}
		
		let removeBookmark = UIAlertAction(title: Strings.AppMenuRemoveBookmarkTitleString, style: .default) { (action) in
			//TODO: can all this logic go somewhere else?
			guard let url = tab.url?.displayURL else { return }
			let absoluteString = url.absoluteString
			self.profile.bookmarks.modelFactory >>== {
				$0.removeByURL(absoluteString).uponQueue(.main) { res in
					if res.isSuccess {
						UnifiedTelemetry.recordEvent(category: .action, method: .delete, object: .bookmark, value: .pageActionMenu)
						success(Strings.AppMenuRemoveBookmarkConfirmMessage)
					}
				}
			}
		}
		
		let pinToTopSites = UIAlertAction(title: Strings.PinTopsiteActionTitle, style: .default) { (action) in
			guard let url = tab.url?.displayURL,
				let sql = self.profile.history as? SQLiteHistory else { return }
			let absoluteString = url.absoluteString
			
			sql.getSitesForURLs([absoluteString]) >>== { result in
				guard let siteOp = result.asArray().first, let site = siteOp else {
					return
				}
				
				_ = self.profile.history.addPinnedTopSite(site).value
			}
		}
		
		/* It might be used in future for Connect functionality to send the tab, that's why I don't remove it completly
		let sendToDevice = UIAlertAction(title: Strings.SendToDeviceTitle, style: .default) { (action) in
			guard let bvc = presentableVC as? PresentableVC & InstructionsViewControllerDelegate & ClientPickerViewControllerDelegate else { return }
			if !self.profile.hasAccount() {
				let instructionsViewController = InstructionsViewController()
				instructionsViewController.delegate = bvc
				let navigationController = UINavigationController(rootViewController: instructionsViewController)
				navigationController.modalPresentationStyle = .formSheet
				bvc.present(navigationController, animated: true, completion: nil)
				return
			}
			
			let clientPickerViewController = ClientPickerViewController()
			clientPickerViewController.clientPickerDelegate = bvc
			clientPickerViewController.profile = self.profile
			clientPickerViewController.profileNeedsShutdown = false
			let navigationController = UINavigationController(rootViewController: clientPickerViewController)
			navigationController.modalPresentationStyle = .formSheet
			bvc.present(navigationController, animated: true, completion: nil)
		}
		*/

		let share = UIAlertAction(title: Strings.AppMenuSharePageTitleString, style: .default) { (action) in
			guard let url = tab.canonicalURL?.displayURL else { return }
			presentShareMenu()
		}

		var mainActions = [UIAlertAction]()
		// Disable bookmarking and reading list if the URL is too long.
		if !tab.urlIsTooLong {
			mainActions.append(isBookmarked ? removeBookmark : bookmarkPage)
			
			/* For now we decided to disable reading list but for future we might need it.
			if tab.readerModeAvailableOrActive {
				mainActions.append(addReadingList)
			}
			*/
		}

		let cancelAction = UIAlertAction(
			title: NSLocalizedString("Cancel", comment: "The cancel button."),
			style: .cancel,
			handler: nil
		)

		mainActions.append(contentsOf: [findInPageAction, toggleDesktopSite, pinToTopSites, share, cancelAction])

		return mainActions
	}
	
}

import SwiftUI
import WebKit
import MessageUI

class EmbedUrlWebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
	let url: URL
	lazy var webView = WKWebView()

	init(url: URL) {
		self.url = url
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		webView.navigationDelegate = self
		webView.uiDelegate = self
		view.addSubview(webView)
		webView.load(.init(url: url))
	}

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		webView.frame = view.bounds
	}

	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
		if let url = navigationAction.request.url, url.scheme?.lowercased() == "mailto" { // mail url from web content
			if MFMessageComposeViewController.canSendText() {
				let composeVC = MFMailComposeViewController()
				composeVC.mailComposeDelegate = self
				composeVC.setToRecipients([url.email ?? ""])
				composeVC.setMessageBody(url.emailBody ?? "", isHTML: false)
				self.present(composeVC, animated: true, completion: nil)
				decisionHandler(.cancel)
				return
			}
		} else if navigationAction.targetFrame == nil, UIApplication.shared.canOpenURL(url) {
			UIApplication.shared.open(url)
			decisionHandler(.cancel)
			return
		}
		decisionHandler(WKNavigationActionPolicy.allow)
	}

	// Handle facebook, twitter share links here
	func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
		if let url = navigationAction.request.url {
			UIApplication.shared.open(url)
		}
		return nil
	}
}

extension EmbedUrlWebViewController: MFMailComposeViewControllerDelegate {
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		// Dismiss the mail compose view controller.
		controller.dismiss(animated: true, completion: nil)
	}
}

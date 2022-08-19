import SwiftUI
import WebKit
import MessageUI

class EmbedWebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
	enum ContentType {
		case url(URL)
		case embedCode(String, URL?)
	}

	let contentType: ContentType
	lazy var webView = WKWebView()

	init(contentType: ContentType) {
		self.contentType = contentType
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
		switch contentType {
		case let .url(url):
			webView.load(.init(url: url))
		case let .embedCode(embedCode, baseUrl):
			webView.loadHTMLString(embedCode, baseURL: baseUrl)
		}
	}

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		webView.frame = view.bounds
	}

	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
		if let url = navigationAction.request.url {
			if  url.scheme?.lowercased() == "mailto" {// mail url from web content
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

extension EmbedWebViewController: MFMailComposeViewControllerDelegate {
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		// Dismiss the mail compose view controller.
		controller.dismiss(animated: true, completion: nil)
	}
}

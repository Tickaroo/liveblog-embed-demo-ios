import MessageUI
import UIKit
import WebKit

struct ScrollRequest {
	let top: CGFloat
	let correction: Bool
	let jumpId: Int
}

class EmbedCell: BaseCell {
	var webView: WKWebView!
	var resizeCallback: ((CGFloat) -> Void)?
	var scrollCallback: ((ScrollRequest) -> Void)?
	var openMailUrl: ((URL) -> Bool)?
	private var handler: ScriptMessageHandler?
	private var observation: NSKeyValueObservation?
	
	override func setupViews() {
		// Any way of listening to js function can work here. ScriptMessageHandler is just one way of doing it.
		let handler = ScriptMessageHandler(callbacks: [
			.init(
				// The embed passes `info` only to a function that declares both parameters (no default values),
				// and older embeds call it with `top` alone.
				script: """
						window.tickarooLiveblogScrollTo = function (top, info) {
							window.webkit.messageHandlers.scrollToSwift.postMessage({
								"top": top,
								"correction": !!(info && info.correction),
								"jumpId": (info && info.jumpId) || 0
							});
						};
					""", 
				functionName: "scrollToSwift",
				callback: { [weak self] dict in
					guard let top = dict["top"] as? CGFloat else { return }
					self?.scrollCallback?(.init(
						top: top,
						correction: dict["correction"] as? Bool ?? false,
						jumpId: dict["jumpId"] as? Int ?? 0
					))
				}
			)
		])
		webView = .init(frame: .zero, configuration: handler.config)
		self.handler = handler
		addSubview(webView)
		
		webView.loadHTMLString(Constants.embedCodeWithAnchors, baseURL: Constants.collectionViewEmbedUrl)
		webView.navigationDelegate = self
		webView.uiDelegate = self
		webView.scrollView.isScrollEnabled = false
		
		var lastHeight = CGFloat.zero
		observation = webView.scrollView.observe(\.contentSize, options: .new) { [weak self] scrollView, change in
			self?.webView.evaluateJavaScript("document.getElementsByClassName('tik4-live')[0].clientHeight") { data, error in
				let padding = CGFloat(140)
				if let newHeight = (data as? CGFloat).map({$0 + padding}), lastHeight != newHeight {
					lastHeight = newHeight
					self?.resizeCallback?(newHeight)
				}
			}
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		webView.frame = bounds
	}
}
extension EmbedCell: WKNavigationDelegate, WKUIDelegate {
	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
		if let url = navigationAction.request.url {
			if  url.scheme?.lowercased() == "mailto" {// mail url from web content
				if openMailUrl?(url) == true {
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

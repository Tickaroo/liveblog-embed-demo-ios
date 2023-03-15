import MessageUI
import UIKit
import WebKit

class EmbedCell: BaseCell {
	lazy var webView = WKWebView()
	var resizeCallback: ((CGFloat) -> Void)?
	var openMailUrl: ((URL) -> Bool)?
	
	private var observation: NSKeyValueObservation?
	
	override func setupViews() {
		addSubview(webView)
		webView.load(.init(url: Constants.collectionViewEmbedUrl))
		webView.navigationDelegate = self
		webView.uiDelegate = self
		
		var lastHeight = CGFloat.zero
		observation = webView.scrollView.observe(\.contentSize, options: .new) { [weak self] scrollView, change in
			if let newHeight = change.newValue?.height, lastHeight != newHeight {
				lastHeight = newHeight
				self?.resizeCallback?(newHeight)
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

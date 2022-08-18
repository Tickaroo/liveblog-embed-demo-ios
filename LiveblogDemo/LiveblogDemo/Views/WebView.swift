import SwiftUI
import UIKit
import WebKit

struct WebView: UIViewRepresentable {
	var url: URL

	func makeUIView(context: Context) -> WKWebView {
		return WKWebView()
	}

	func updateUIView(_ webView: WKWebView, context: Context) {
		let request = URLRequest(url: url)
		webView.load(request)
	}
}

struct EmbedCodeWebView: UIViewRepresentable {
	func makeUIView(context: Context) -> WKWebView {
		return WKWebView()
	}

	func updateUIView(_ webView: WKWebView, context: Context) {
		webView.loadHTMLString(Constants.embedCode, baseURL: URL(string: "https://cdn.tickaroo.com"))
	}
}

struct WebView_Previews: PreviewProvider {
	static var previews: some View {
		WebView(url: Constants.embedUrl)
	}
}

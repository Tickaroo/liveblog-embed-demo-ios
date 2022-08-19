import SwiftUI
import UIKit
import WebKit

struct WebViewController: UIViewControllerRepresentable {
	var url: URL

	func makeUIViewController(context: Self.Context) -> EmbedUrlWebViewController {
		.init(url: url)
	}

	func updateUIViewController(_ uiViewController: EmbedUrlWebViewController, context: Self.Context) {}
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
		WebViewController(url: Constants.embedUrl)
	}
}

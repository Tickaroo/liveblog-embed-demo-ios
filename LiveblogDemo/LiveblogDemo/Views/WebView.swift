import SwiftUI
import UIKit
import WebKit

struct WebViewController: UIViewControllerRepresentable {
	var contentType: EmbedWebViewController.ContentType

	func makeUIViewController(context: Self.Context) -> EmbedWebViewController {
		.init(contentType: contentType)
	}

	func updateUIViewController(_ uiViewController: EmbedWebViewController, context: Self.Context) {}
}

struct WebView_Previews: PreviewProvider {
	static var previews: some View {
		WebViewController(contentType: .url(Constants.embedUrl))
	}
}

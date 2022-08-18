import SwiftUI

struct MainTabView: View {
	var body: some View {
		TabView {
			WebView(url: Constants.embedUrl)
				.edgesIgnoringSafeArea(.top)
				.tabItem {
					VStack {
						Image(systemName: "globe")
						Text("Embed url")
					}
				}
			EmbedCodeWebView()
				.edgesIgnoringSafeArea(.top)
				.tabItem {
					VStack {
						Image(systemName: "externaldrive.fill")
						Text("Embed code")
					}
				}
		}
	}
}

struct MainTabView_Previews: PreviewProvider {
	static var previews: some View {
		MainTabView()
	}
}


import SwiftUI

struct MainTabView: View {
	@State var selectedTab = 1

	var body: some View {
		TabView(selection: $selectedTab) {
			WebViewController(contentType: .url(Constants.embedUrl))
				.edgesIgnoringSafeArea(.top)
				.tabItem {
					VStack {
						Image(systemName: "globe")
						Text("Embed url")
					}
				}
				.tag(1)
			WebViewController(contentType: .embedCode(Constants.embedCode, Constants.embedUrl))
				.edgesIgnoringSafeArea(.top)
				.tabItem {
					VStack {
						Image(systemName: "externaldrive.fill")
						Text("Embed code")
					}
				}
				.tag(2)
			CollectionViewDemo().preview
				.edgesIgnoringSafeArea(.top)
				.tabItem {
					VStack {
						Image(systemName: "list.dash")
						Text("Collection view")
					}
				}
				.tag(3)
		}
	}
}

struct MainTabView_Previews: PreviewProvider {
	static var previews: some View {
		MainTabView()
	}
}

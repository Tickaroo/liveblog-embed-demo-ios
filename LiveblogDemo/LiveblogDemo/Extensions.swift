//
//  Extensions.swift
//  LiveblogDemo
//
//  Created by Vahram Mirzoyan on 19.08.22.
//

import Foundation

extension URL {
	var email: String? {
		return scheme == "mailto" ? URLComponents(url: self, resolvingAgainstBaseURL: false)?.path : nil
	}

	var emailBody: String? {
		guard scheme == "mailto", let components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return nil }
		return components.queryItems?.first(where: { $0.name == "body" })?.value
	}
}

import SwiftUI

extension UIViewController {
	private struct Preview: UIViewControllerRepresentable {
		var viewController: UIViewController
		
		init(_ viewController: UIViewController) {
			self.viewController = viewController
		}
		
		func makeUIViewController(context: Self.Context) -> UIViewController {
			viewController
		}

		func updateUIViewController(_ uiViewController: UIViewController, context: Self.Context) {}
	}

	var preview: some View {
		Preview(self)
	}
}

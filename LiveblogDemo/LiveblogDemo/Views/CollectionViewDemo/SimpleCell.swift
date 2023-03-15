import UIKit

class SimpleCell: BaseCell {
	override func setupViews() {
		backgroundColor = .init(hue: .random(in: 0...1), saturation: 0.5, brightness: 0.7, alpha: 1)
	}
}

import UIKit

class BaseCell: UICollectionViewCell {
	class var reuseIdentifier: String { String(describing: self) }
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupViews()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setupViews() {}
}

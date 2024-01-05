import SwiftUI
import MessageUI

struct ItemDefinition {
	let cellType: BaseCell.Type
}

class CollectionViewDemo: UIViewController {
	var collectionView: UICollectionView!
	let data: [ItemDefinition] = [
		.init(cellType: SimpleCell.self),
		.init(cellType: SimpleCell.self),
		.init(cellType: EmbedCell.self),
		.init(cellType: SimpleCell.self),
		.init(cellType: SimpleCell.self),
		.init(cellType: SimpleCell.self),
	]
	
	// Initial height of embed
	var embedHeight: CGFloat = 0

	override func viewDidLoad() {
		super.viewDidLoad()
		let layout = UICollectionViewFlowLayout()
		collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.register(SimpleCell.self, forCellWithReuseIdentifier: SimpleCell.reuseIdentifier)
		collectionView.register(EmbedCell.self, forCellWithReuseIdentifier: EmbedCell.reuseIdentifier)
		collectionView.dataSource = self
		collectionView.delegate = self
		view.addSubview(collectionView)
	}
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		collectionView.frame = view.bounds
	}
}

extension CollectionViewDemo: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let width = view.bounds.width - 20
		let obj = data[indexPath.item]
		if obj.cellType == EmbedCell.self {
			return .init(width: width, height: embedHeight)
		}
		return .init(width: width, height: 200)
	}
	
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		if let cell = cell as? EmbedCell {
			cell.resizeCallback = { [weak self] newHeight in
				// Keeping the offset on a variable and setting afterwards to keep the scroll position consistent
				let offset = self?.collectionView.contentOffset ?? .zero
				self?.embedHeight = newHeight
				UIView.setAnimationsEnabled(false)
				self?.collectionView.performBatchUpdates(nil, completion: { _ in 
					self?.collectionView.setContentOffset(offset, animated: false)
					UIView.setAnimationsEnabled(true)
				})
			}
			cell.scrollCallback = { [weak self] top in
				self?.collectionView.setContentOffset(
					.init(x: 0, y: cell.frame.minY + top),
					animated: true
				)
			}
			cell.openMailUrl = { [weak self] url in 
				if MFMessageComposeViewController.canSendText() {
					let composeVC = MFMailComposeViewController()
					composeVC.mailComposeDelegate = self
					composeVC.setToRecipients([url.email ?? ""])
					composeVC.setMessageBody(url.emailBody ?? "", isHTML: false)
					self?.present(composeVC, animated: true, completion: nil)
					return true
				}
				return false
			}
		}
	}
}

extension CollectionViewDemo: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		data.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let obj = data[indexPath.item]
		if obj.cellType == EmbedCell.self {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: obj.cellType.reuseIdentifier, for: indexPath) as? EmbedCell
			return cell!
		} else {
			return collectionView.dequeueReusableCell(withReuseIdentifier: SimpleCell.reuseIdentifier, for: indexPath)
		}
	}
}

extension CollectionViewDemo: MFMailComposeViewControllerDelegate {
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		// Dismiss the mail compose view controller.
		controller.dismiss(animated: true, completion: nil)
	}
}

struct CollectionViewDemo_Previews: PreviewProvider {
	static let vc = CollectionViewDemo()
	
	static var previews: some View {
		vc.preview
			.ignoresSafeArea()
	}
}

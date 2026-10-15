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

	private var activeJumpId: Int?
	private var requestedPostY: CGFloat = 0
	private var isJumpAnimating = false
	private var isJumpClamped = false

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

	private func scrollToRequestedPost() {
		// contentSize is not updated yet when performBatchUpdates completes
		collectionView.layoutIfNeeded()
		let inset = collectionView.adjustedContentInset
		let minY = -inset.top
		let maxY = max(minY, collectionView.contentSize.height + inset.bottom - collectionView.bounds.height)
		let desiredY = requestedPostY - inset.top
		let target = CGPoint(x: collectionView.contentOffset.x, y: min(max(desiredY, minY), maxY))
		// A correction can arrive before the embed cell has grown, so the next resize re-applies a clamped target
		isJumpClamped = desiredY > maxY
		// scrollViewDidEndScrollingAnimation is not called for an animation to the current offset,
		// but it is called for the running animation when a new one replaces it, so the flag is set afterwards
		let animated = abs(target.y - collectionView.contentOffset.y) >= 1
		collectionView.setContentOffset(target, animated: animated)
		isJumpAnimating = animated
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
				// Restoring the offset stops a jump mid-animation and keeps a clamped jump short, so the jump is re-aimed afterwards
				let reaimJump = (self?.isJumpAnimating ?? false) || (self?.isJumpClamped ?? false)
				self?.embedHeight = newHeight
				UIView.setAnimationsEnabled(false)
				self?.collectionView.performBatchUpdates(nil, completion: { _ in 
					UIView.setAnimationsEnabled(true)
					self?.collectionView.setContentOffset(offset, animated: false)
					if reaimJump, self?.activeJumpId != nil {
						self?.scrollToRequestedPost()
					}
				})
			}
			cell.scrollCallback = { [weak self, weak cell] request in
				guard let self, let cell else { return }
				// Corrections only belong to the latest jump, and the reader's drag ends them
				let dropped = request.correction && request.jumpId != self.activeJumpId
				NSLog("%@", "tickarooLiveblogScrollTo top=\(request.top) correction=\(request.correction) jumpId=\(request.jumpId) dropped=\(dropped)")
				guard !dropped else { return }
				self.activeJumpId = request.jumpId
				self.requestedPostY = cell.frame.minY + request.top
				self.scrollToRequestedPost()
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

	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		activeJumpId = nil
		isJumpAnimating = false
	}

	func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
		isJumpAnimating = false
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

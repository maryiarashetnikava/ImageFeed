import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    weak var delegate: ImagesListCellDelegate?
    
    private var animationLayers = Set<CALayer>()
    
    @IBAction private func likeButtonClicked(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        pictureImageView.layer.cornerRadius = 16
        pictureImageView.layer.masksToBounds = true
        pictureImageView.kf.indicatorType = .activity
    }
        
    override func prepareForReuse() {
        super.prepareForReuse()
        
        pictureImageView.kf.cancelDownloadTask()
        pictureImageView.image = nil
        removeSkeleton()
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let image = isLiked
        ? UIImage(named: "like_active")
        : UIImage(named: "like_not_active")
        likeButton.setImage(image, for: .normal)
    }
    
    func showSkeleton() {
        guard animationLayers.isEmpty else { return }
        
        contentView.layoutIfNeeded()

        let gradient = CAGradientLayer()
        gradient.frame = pictureImageView.frame.integral

        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]

        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)

        gradient.cornerRadius = 16
        gradient.masksToBounds = true

        pictureImageView.superview?.layer.addSublayer(gradient)
        animationLayers.insert(gradient)

        let animation = CABasicAnimation(keyPath: "locations")
        animation.duration = 1.0
        animation.repeatCount = .infinity
        animation.fromValue = [0, 0.1, 0.3]
        animation.toValue = [0, 0.8, 1]

        gradient.add(animation, forKey: "locationsChange")
    }
    
    func removeSkeleton() {
        animationLayers.forEach { $0.removeFromSuperlayer() }
        animationLayers.removeAll()
    }
}

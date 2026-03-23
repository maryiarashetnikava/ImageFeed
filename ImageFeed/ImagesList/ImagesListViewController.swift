import UIKit
import Kingfisher

protocol ImagesListViewControllerProtocol: AnyObject {
    func updateTableView(oldCount: Int, newCount: Int)
    func updateCell(at indexPath: IndexPath)
    func showError()
    func hideLoading()
}

final class ImagesListViewController: UIViewController {
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Dependencies
    
    private var presenter: ImagesListPresenterProtocol!
    
    func configure(_ presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
    
    // MARK: - Private
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        presenter.viewDidLoad()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            let photo = presenter.photo(at: indexPath)
            viewController.imageURL = photo.largeImageURL
            
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = presenter.photo(at: indexPath)
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        
        let scale = imageViewWidth / photo.size.width
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == presenter.numberOfPhotos() {
            presenter.didReachEnd()
        }
    }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfPhotos()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        )
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        imageListCell.delegate = self
        
        configCell(for: imageListCell, with: indexPath)
        
        return imageListCell
    }
}

// MARK: - Cell Configuration

extension ImagesListViewController {
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = presenter.photo(at: indexPath)
        
        if let date = photo.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: date)
        } else {
            cell.dateLabel.text = ""
        }
        
        let likeImage = photo.isLiked
        ? UIImage(named: "like_active")
        : UIImage(named: "like_not_active")
        
        cell.likeButton.setImage(likeImage, for: .normal)
        
        if photo.isLiked {
            cell.likeButton.accessibilityIdentifier = "like button on"
        } else {
            cell.likeButton.accessibilityIdentifier = "like button off"
        }
        
        if let url = URL(string: photo.thumbImageURL) {
            
            if cell.pictureImageView.image == nil {
                cell.showSkeleton()
            }
            
            cell.pictureImageView.kf.setImage(
                with: url,
                placeholder: UIImage(named: "stub_card")
            ) { _ in
                cell.removeSkeleton()
            }
        }
    }
}

// MARK: - ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate {
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        UIBlockingProgressHUD.show()
        
        presenter.didTapLike(at: indexPath)
    }
}

// MARK: - View Protocol

extension ImagesListViewController: ImagesListViewControllerProtocol {
    
    func updateTableView(oldCount: Int, newCount: Int) {
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map {
                    IndexPath(row: $0, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }
    
    func updateCell(at indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell else { return }
        let photo = presenter.photo(at: indexPath)
        cell.setIsLiked(photo.isLiked)
    }
    
    func showError() {
        let alert = UIAlertController(
            title: "Something went wrong",
            message: "Unable to change the like status.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func hideLoading() {
        UIBlockingProgressHUD.dismiss()
    }
}

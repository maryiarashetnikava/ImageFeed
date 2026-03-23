import UIKit

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    
    func viewDidLoad()
    func didReachEnd()
    func didTapLike(at indexPath: IndexPath)
    
    func numberOfPhotos() -> Int
    func photo(at indexPath: IndexPath) -> Photo
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    weak var view: ImagesListViewControllerProtocol?
    
    private let service: ImagesListServiceProtocol
    private var photos: [Photo] = []
    private var observer: NSObjectProtocol?
    
    init(service: ImagesListServiceProtocol = ImagesListService()) {
        self.service = service
    }
    
    func viewDidLoad() {
        photos = service.photos
        
        observer = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updatePhotos()
        }
        
        service.fetchPhotosNextPage()
    }
    
    private func updatePhotos() {
        let oldCount = photos.count
        let newCount = service.photos.count
        photos = service.photos
        
        view?.updateTableView(oldCount: oldCount, newCount: newCount)
    }
    
    func numberOfPhotos() -> Int {
        photos.count
    }
    
    func photo(at indexPath: IndexPath) -> Photo {
        photos[indexPath.row]
    }
    
    func didReachEnd() {
        service.fetchPhotosNextPage()
    }
    
    func didTapLike(at indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        service.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else { return }
            
            DispatchQueue.main.async {
                self.view?.hideLoading()
                
                switch result {
                case .success:
                    self.photos = self.service.photos
                    self.view?.updateCell(at: indexPath)
                    
                case .failure:
                    self.view?.showError()
                }
            }
        }
    }
    
    deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

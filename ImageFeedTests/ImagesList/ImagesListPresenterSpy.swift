@testable import ImageFeed
import Foundation

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    
    weak var view: ImagesListViewControllerProtocol?
    
    var viewDidLoadCalled = false
    var didReachEndCalled = false
    var didTapLikeCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didReachEnd() {
        didReachEndCalled = true
    }
    
    func didTapLike(at indexPath: IndexPath) {
        didTapLikeCalled = true
    }
    
    func numberOfPhotos() -> Int { 0 }
    
    func photo(at indexPath: IndexPath) -> Photo {
        fatalError("Not needed in this test")
    }
}

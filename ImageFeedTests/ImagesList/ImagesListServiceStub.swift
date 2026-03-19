@testable import ImageFeed
import Foundation

final class ImagesListServiceStub: ImagesListServiceProtocol {
    
    var photos: [Photo] = []
    
    var fetchPhotosNextPageCalled = false
    var changeLikeCalled = false
    
    func fetchPhotosNextPage() {
        fetchPhotosNextPageCalled = true
    }
    
    func changeLike(
        photoId: String,
        isLike: Bool,
        _ completion: @escaping (Result<Void, Error>) -> Void
    ) {
        changeLikeCalled = true
        completion(.success(()))
    }
}

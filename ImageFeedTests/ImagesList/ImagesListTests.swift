@testable import ImageFeed
import XCTest

final class ImagesListTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController
        
        let presenter = ImagesListPresenterSpy()
        viewController.configure(presenter)
        
        // when
        _ = viewController.view
        
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsFetchPhotos() {
        // given
        let service = ImagesListServiceStub()
        let presenter = ImagesListPresenter(service: service)
        
        // when
        presenter.viewDidLoad()
        
        // then
        XCTAssertTrue(service.fetchPhotosNextPageCalled)
    }
    
    func testPresenterUpdatesTableView() {
        // given
        let view = ImagesListViewControllerSpy()
        let service = ImagesListServiceStub()
        
        service.photos = [
            Photo(
                id: "1",
                size: .zero,
                createdAt: nil,
                welcomeDescription: nil,
                thumbImageURL: "",
                largeImageURL: "",
                isLiked: false
            )
        ]
        
        let presenter = ImagesListPresenter(service: service)
        presenter.view = view
        
        // when
        presenter.viewDidLoad()
        
        NotificationCenter.default.post(
            name: ImagesListService.didChangeNotification,
            object: nil
        )
        
        // then
        XCTAssertTrue(view.updateTableViewCalled)
    }
    
    func testPresenterCallsUpdateCellOnLike() {
        // given
        let view = ImagesListViewControllerSpy()
        let service = ImagesListServiceStub()
        
        service.photos = [
            Photo(
                id: "1",
                size: .zero,
                createdAt: nil,
                welcomeDescription: nil,
                thumbImageURL: "",
                largeImageURL: "",
                isLiked: false
            )
        ]
        
        let presenter = ImagesListPresenter(service: service)
        presenter.view = view
        presenter.viewDidLoad()
        
        let expectation = XCTestExpectation(description: "updateCell called")
        
        // when
        presenter.didTapLike(at: IndexPath(row: 0, section: 0))
        
        DispatchQueue.main.async {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        // then
        XCTAssertTrue(view.updateCellCalled)
    }
    
    func testPresenterHidesLoadingAfterLike() {
        // given
        let view = ImagesListViewControllerSpy()
        let service = ImagesListServiceStub()
        
        service.photos = [
            Photo(
                id: "1",
                size: .zero,
                createdAt: nil,
                welcomeDescription: nil,
                thumbImageURL: "",
                largeImageURL: "",
                isLiked: false
            )
        ]
        
        let presenter = ImagesListPresenter(service: service)
        presenter.view = view
        presenter.viewDidLoad()
        
        let expectation = XCTestExpectation(description: "hideLoading called")
        
        // when
        presenter.didTapLike(at: IndexPath(row: 0, section: 0))
        
        DispatchQueue.main.async {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        // then
        XCTAssertTrue(view.hideLoadingCalled)
    }
}

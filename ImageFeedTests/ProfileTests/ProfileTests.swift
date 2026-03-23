@testable import ImageFeed
import XCTest

final class ProfileTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        // given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        
        viewController.configure(presenter)
        
        // when
        _ = viewController.view
        
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testPresenterCallsShowLogoutAlert() {
        // given
        let viewController = ProfileViewControllerSpy()
        let service = ProfileServiceStub()
        let presenter = ProfilePresenter(profileService: service)
        
        presenter.view = viewController
        
        // when
        presenter.didTapLogout()
        
        // then
        XCTAssertTrue(viewController.showLogoutAlertCalled)
    }
    
    func testPresenterCallsShowSkeleton() {
        // given
        let viewController = ProfileViewControllerSpy()
        let service = ProfileServiceStub()
        let presenter = ProfilePresenter(profileService: service)
        
        presenter.view = viewController
        
        // when
        presenter.viewDidLayoutSubviews()
        
        // then
        XCTAssertTrue(viewController.showSkeletonCalled)
    }
    
    func testViewControllerCallsViewDidLayoutSubviews() {
        // given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        
        viewController.configure(presenter)
        
        // when
        _ = viewController.view
        viewController.viewDidLayoutSubviews()
        
        // then
        XCTAssertTrue(presenter.viewDidLayoutSubviewsCalled)
    }
    
    func testViewControllerCallsDidTapLogout() {
        // given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        
        viewController.configure(presenter)
        _ = viewController.view
        
        // when
        viewController.perform(#selector(ProfileViewController.didTapLogoutButton))
        
        // then
        XCTAssertTrue(presenter.didTapLogoutCalled)
    }
}

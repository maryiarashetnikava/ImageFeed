@testable import ImageFeed
import Foundation

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    
    weak var view: ProfileViewControllerProtocol?
    
    var viewDidLoadCalled = false
    var viewDidLayoutSubviewsCalled = false
    var didTapLogoutCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func viewDidLayoutSubviews() {
        viewDidLayoutSubviewsCalled = true
    }
    
    func didTapLogout() {
        didTapLogoutCalled = true
    }
}

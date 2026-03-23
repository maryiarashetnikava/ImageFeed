@testable import ImageFeed
import Foundation

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    
    var updateProfileDetailsCalled = false
    var showSkeletonCalled = false
    var showLogoutAlertCalled = false
    
    func updateProfileDetails(name: String, login: String, bio: String) {
        updateProfileDetailsCalled = true
    }
    
    func updateAvatar(url: URL?) {}
    
    func showSkeleton() {
        showSkeletonCalled = true
    }
    
    func hideSkeleton() {}
    
    func showLogoutAlert() {
        showLogoutAlertCalled = true
    }
}

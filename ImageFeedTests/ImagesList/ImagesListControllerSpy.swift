@testable import ImageFeed
import Foundation

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    
    var updateTableViewCalled = false
    var updateCellCalled = false
    var showErrorCalled = false
    var hideLoadingCalled = false
    
    func updateTableView(oldCount: Int, newCount: Int) {
        updateTableViewCalled = true
    }
    
    func updateCell(at indexPath: IndexPath) {
        updateCellCalled = true
    }
    
    func showError() {
        showErrorCalled = true
    }
    
    func hideLoading() {
        hideLoadingCalled = true
    }
}

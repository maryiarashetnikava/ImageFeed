import Foundation

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    
    func viewDidLoad()
    func viewDidLayoutSubviews()
    func didTapLogout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    
    weak var view: ProfileViewControllerProtocol?
    
    private let profileService: ProfileServiceProtocol

    init(profileService: ProfileServiceProtocol = ProfileService.shared) {
        self.profileService = profileService
    }
    
    deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private var observer: NSObjectProtocol?

    func viewDidLoad() {
        if let profile = profileService.profile {
            updateProfile(profile)
        }
        
        observer = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAvatar()
            self?.view?.hideSkeleton()
        }
        
        updateAvatar()
    }
    
    func viewDidLayoutSubviews() {
        if profileService.profile == nil {
            view?.showSkeleton()
        }
    }
    
    func didTapLogout() {
        view?.showLogoutAlert()
    }
    
    private func updateProfile(_ profile: Profile) {
        let name = profile.name.isEmpty ? "Имя не указано" : profile.name
        let login = profile.loginName.isEmpty ? "@неизвестный_пользователь" : profile.loginName
        let bio = (profile.bio?.isEmpty ?? true) ? "Профиль не заполнен" : profile.bio ?? ""
        
        view?.updateProfileDetails(name: name, login: login, bio: bio)
    }
    
    private func updateAvatar() {
        guard
            let urlString = ProfileImageService.shared.avatarURL,
            let url = URL(string: urlString)
        else {
            view?.updateAvatar(url: nil)
            return
        }
        
        view?.updateAvatar(url: url)
    }
}

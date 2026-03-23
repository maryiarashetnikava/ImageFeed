import UIKit
import Kingfisher

protocol ProfileViewControllerProtocol: AnyObject {
    func updateProfileDetails(name: String, login: String, bio: String)
    func updateAvatar(url: URL?)
    func showSkeleton()
    func hideSkeleton()
    func showLogoutAlert()
}

final class ProfileViewController: UIViewController {
    
    
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let loginNameLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    private let logoutButton = UIButton(type: .system)
    
    private var animationLayers = Set<CALayer>()
    
    
    // MARK: - Dependencies
    
    private var presenter: ProfilePresenterProtocol!
    
    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        presenter.viewDidLayoutSubviews()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor(resource: .ypBlack)
        setupAvatarView()
        setupNameLabel()
        setupDescriptionLabel()
        setupLogoutButton()
    }
    
    private func setupAvatarView() {
        let profileImage = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70))
        
        avatarImageView.image = profileImage
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatarImageView)
        
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func setupNameLabel() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor)
        ])
    }
    
    private func setupDescriptionLabel() {
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor)
        ])
    }
    
    private func setupLogoutButton() {
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        
        logoutButton.accessibilityIdentifier = "logout button"
        
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    // MARK: - Skeleton (оставили во View)
    
    private func displaySkeleton() {
        addGradientLayer(to: avatarImageView)
        addGradientLayer(to: nameLabel)
        addGradientLayer(to: loginNameLabel)
        addGradientLayer(to: descriptionLabel)
    }
    
    private func addGradientLayer(to view: UIView) {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        view.layer.addSublayer(gradient)
        animationLayers.insert(gradient)
    }
    
    private func removeGradientLayers() {
        animationLayers.forEach { $0.removeFromSuperlayer() }
        animationLayers.removeAll()
    }
    
    // MARK: - Actions
    
    @objc
    func didTapLogoutButton() {
        presenter.didTapLogout()
    }
    
    private func logout() {
        ProfileLogoutService.shared.logout()
        
        guard let window = UIApplication.shared.windows.first else { return }
        window.rootViewController = SplashViewController()
    }
}

extension ProfileViewController: ProfileViewControllerProtocol {
    
    func updateProfileDetails(name: String, login: String, bio: String) {
        nameLabel.text = name
        loginNameLabel.text = login
        descriptionLabel.text = bio
    }
    
    func updateAvatar(url: URL?) {
        guard let url = url else { return }
        
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        avatarImageView.kf.setImage(with: url, options: [.processor(processor)])
    }
    
    func showSkeleton() {
        displaySkeleton()
    }
    
    func hideSkeleton() {
        removeGradientLayers()
    }
    
    func showLogoutAlert() {
        let alert = UIAlertController(
            title: "Goodbye!",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )
        
        let yes = UIAlertAction(title: "Log Out", style: .destructive) { [weak self] _ in
            self?.logout()
        }
        
        alert.addAction(yes)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
}


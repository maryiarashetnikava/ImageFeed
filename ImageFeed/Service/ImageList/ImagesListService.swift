import Foundation
import CoreGraphics

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String?
    let width: Int
    let height: Int
    let description: String?
    let likedByUser: Bool
    let urls: UrlsResult
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case description
        case likedByUser = "liked_by_user"
        case urls
    }
}

struct UrlsResult: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

final class ImagesListService {
    private(set) var photos: [Photo] = []
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    private let tokenStorage = OAuth2TokenStorage.shared
    
    func fetchPhotosNextPage() {
        guard task == nil else { return }
        
        guard let token = tokenStorage.token else {
              print("No token")
              return
          }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let request = makePhotosRequest(page: nextPage, token: token) else {
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let photoResults):
                
                let newPhotos = photoResults.map { self.convert(result: $0) }
                
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                }
                
            case .failure(let error):
                print("[ImagesListService]: error \(error.localizedDescription)")
            }
            
            self.task = nil
        }
        
        self.task = task
        task.resume()
    }
    
    private func makePhotosRequest(page: Int, token: String) -> URLRequest? {
        var components = URLComponents(string: "https://api.unsplash.com/photos")
        components?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        guard let url = components?.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    private func convert(result: PhotoResult) -> Photo {
        let date: Date?
        
        if let createdAtString = result.createdAt {
            let formatter = ISO8601DateFormatter()
            date = formatter.date(from: createdAtString)
        } else {
            date = nil
        }
        
        return Photo(
            id: result.id,
            size: CGSize(width: result.width, height: result.height),
            createdAt: date,
            welcomeDescription: result.description,
            thumbImageURL: result.urls.thumb,
            largeImageURL: result.urls.full,
            isLiked: result.likedByUser
        )
    }
}

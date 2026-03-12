import Foundation
import CoreGraphics

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String?
    let width: Int
    let height: Int
    let description: String?
    let likedByUser: Bool?
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
    
    private let isoFormatter = ISO8601DateFormatter()
    
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    private let tokenStorage = OAuth2TokenStorage.shared
    
    func fetchPhotosNextPage() {
        guard task == nil else { return }
        
        guard let token = tokenStorage.token else {
            print("[ImagesListService]: token is missing")
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
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = tokenStorage.token else {
            print("[ImagesListService]: token is missing")
            return
        }
        
        let urlString = "https://api.unsplash.com/photos/\(photoId)/like"
        
        guard let url = URL(string: urlString) else {
            print("[ImagesListService]: invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.data(for: request) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success:

                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {

                        let photo = self.photos[index]

                        let newPhoto = Photo(
                            id: photo.id,
                            size: photo.size,
                            createdAt: photo.createdAt,
                            welcomeDescription: photo.welcomeDescription,
                            thumbImageURL: photo.thumbImageURL,
                            largeImageURL: photo.largeImageURL,
                            isLiked: !photo.isLiked
                        )

                        self.photos = self.photos.withReplaced(
                            itemAt: index,
                            newValue: newPhoto
                        )
                    }

                    completion(.success(()))

                case .failure(let error):
                    print("[ImagesListService]: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }

            task.resume()
        }
    
    
    private func convert(result: PhotoResult) -> Photo {
        let date: Date?
        
        if let createdAtString = result.createdAt {
            date = isoFormatter.date(from: createdAtString)
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
            isLiked: result.likedByUser ?? false
        )
    }
    
}

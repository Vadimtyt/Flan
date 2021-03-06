//
//  NetworkManager.swift
//  Flan
//
//  Created by Вадим on 09.08.2021.
//

import UIKit
import FirebaseStorage

class NetworkManager {
    static let downloadRef = Storage.storage()
    
    class func fetchList<T: Decodable>(from path: FileNameFor, completion: @escaping (T?, Data?) -> ()) {
        
        downloadRef.reference(withPath: path.rawValue).getData(maxSize: 1000000000) { (data, error) in
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .useDefaultKeys
                guard let data = data else {
                    print("ERROR for \(path.rawValue). Data = nil")
                    completion(nil, nil)
                    return
                }
                let listJSON = try decoder.decode(T.self, from: data)

                DispatchQueue.main.async {
                    completion(listJSON, data)
                }
            } catch let error {
                print("ERROR \(path.rawValue)\n", error)
                completion(nil, nil)
            }
        }.resume()
    }
    
    class func fetchImage(_ folder: PhotoFolder,_ imageName: String, completion: @escaping (UIImage) -> ()) {
        guard DataManager.shared.isOnlineMode else {
            let standartImage = ImageModel.standartImage
            completion(standartImage)
            return
        }
        
        downloadRef.reference(withPath: folder.rawValue + "/" + imageName).getData(maxSize: 1000000000) { (data, error) in
            
            if let error = error {
                print(error.localizedDescription, folder.rawValue, imageName)
                let standartImage = ImageModel.standartImage
                completion(standartImage)
                return
            }
            
            DispatchQueue.main.async {
                guard let data = data, let image = UIImage(data: data) else { return }
                completion(image)
            }
        }
    }
}

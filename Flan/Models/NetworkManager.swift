//
//  NetworkManager.swift
//  Flan
//
//  Created by Вадим on 09.08.2021.
//

import UIKit
import FirebaseStorage

enum FileNameFor: String {
    case items = "Beta.json"
    case cakes = "Cakes.json"
    case bakeries = "Bakeries.json"
}

enum PhotoFolder: String {
    case item = "ItemsPhoto"
    case cake = "CakesPhoto"
}

class NetworkManager {
    static let downloadRef = Storage.storage()
    
    class func fetchList<T: Decodable>(from path: FileNameFor, completion: @escaping ((T)?) -> ()) {
        
        downloadRef.reference(withPath: path.rawValue).getData(maxSize: 1000000000) { (data, error) in
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .useDefaultKeys
                guard data != nil else { completion(nil); return }
                let listJSON = try decoder.decode(T.self, from: data!)

                DispatchQueue.main.async {
                    completion(listJSON)
                }
            } catch let error {
                print("ERROR", error)
            }
        }.resume()
    }
    
    class func fetchImage(_ folder: PhotoFolder,_ imageName: String, completion: @escaping (UIImage) -> ()) {
        downloadRef.reference(withPath: folder.rawValue + "/" + imageName).getData(maxSize: 10000000) { (data, error) in
            
            if let error = error {
                print(error.localizedDescription)
                let standartImage = UIImage(named: "Standart image.jpg")!
                completion(standartImage)
                return
            }
            
            DispatchQueue.main.async {
                guard let image = UIImage(data: data!) else { return }
                completion(image)
            }
        }
    }
}

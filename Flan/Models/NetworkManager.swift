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
    
    static let listName = "Beta.json"
    static let picturesFolderName = "Pictures"
    
    
    class func fetchList(completion: @escaping ([MenuItemJSON]) -> ()) {
        downloadRef.reference(withPath: listName).getData(maxSize: 1000000000) { (data, error) in
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .useDefaultKeys
                let listOfItemsJSON = try decoder.decode([MenuItemJSON].self, from: data!)

                DispatchQueue.main.async {
                    completion(listOfItemsJSON)
                }
            } catch let error {
                print("ERROR", error)
            }
        }.resume()
    }
    
    class func fetchImage(_ imageName: String, completion: @escaping (UIImage) -> ()) {
        downloadRef.reference(withPath: picturesFolderName + "/" + imageName).getData(maxSize: 10000000) { (data, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            DispatchQueue.main.async {
                guard let image = UIImage(data: data!) else { return }
                completion(image)
            }
        }
    }
}

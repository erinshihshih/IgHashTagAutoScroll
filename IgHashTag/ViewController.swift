//
//  ViewController.swift
//  IgHashTag
//
//  Created by Erin Shih on 2018/5/17.
//  Copyright © 2018年 Erin Shih. All rights reserved.
//

import UIKit


struct IgPost: Decodable {
    let content: String
    let imgUrl: String
}

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var igPosts = [IgPost]()
    var scrollingTimer = Timer()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        
        fetchJSON()
        
    }
    
    
    private func fetchJSON() {
        
        let jsonUrlString = "https://da1245e1.ngrok.io/?hash_tag=%E5%8F%B0%E5%8C%97%E7%BE%8E%E6%99%AF"

        guard let url = URL(string: jsonUrlString) else { return }

        URLSession.shared.dataTask(with: url) { (data, response, err) in

            guard let data = data else { return }

            do {

                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase

                self.igPosts = try decoder.decode([IgPost].self, from: data)
//                print(self.igPosts)

            } catch let jsonErr {

                print("Error serializing json:", jsonErr)

            }

            DispatchQueue.main.async {

                self.collectionView.reloadData()

            }

            }.resume()
        
        
    }
    
    // CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //        return dataArrary.count
        return igPosts.count
    }
    
    // CollectionView
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CustomCollectionViewCell
    
        cell.postImage.contentMode = .scaleAspectFill
        let imgUrl = igPosts[indexPath.row].imgUrl
        cell.postImage.downloadedFrom(link: imgUrl)
        
        cell.postContent.text = igPosts[indexPath.row].content

    //////////////////CollectionView AutoScroll with NSTimer//////////////////
        
                var rowIndex = indexPath.row
                let numberOfRecords: Int = self.igPosts.count - 1
        
                if (rowIndex < numberOfRecords){
                    rowIndex = (rowIndex + 1)
        
                }else {
        
                    rowIndex = 0
        
                }
        
                scrollingTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(ViewController.startTimer(theTimer:)), userInfo: rowIndex, repeats: true)
        
                return cell
    }
    
    @objc func startTimer(theTimer: Timer) {
        
        UIView.animate(withDuration: 2.0, delay: 0, options: .curveEaseOut, animations: {
            
            self.collectionView.scrollToItem(at: IndexPath(row: theTimer.userInfo! as! Int, section: 0),
                                             at: .centeredHorizontally, animated: false)
            
        }, completion: nil)
        
    }
    
}

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}

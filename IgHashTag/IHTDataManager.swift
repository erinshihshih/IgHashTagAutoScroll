//
//  IHTDataManager.swift
//  IgHashTag
//
//  Created by Jia on 2018/5/18.
//  Copyright © 2018年 Erin Shih. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire

class IHTDataManager {
    //Server 網址 (不用加後面參數哦～)
    let endPoint = "https://97a3f9db.ngrok.io"
    var hashTag = "erinelvis"
    //幾秒鐘抓一次新資料
    var updateInterval = 30
    
    var realm: Realm!
    var timer = Timer()
    var fetching = false
    var nextFetchTime: Double = 0.0
    static let sharedInstance = IHTDataManager()
//    private init() {
//        realm = try! Realm()
//        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(self.fetchPosts)), userInfo: nil, repeats: true)
//    }
    
    private init() {
        realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(self.fetchPosts)), userInfo: nil, repeats: true)
    }
    
    @objc func fetchPosts() {
        if fetching || Date().timeIntervalSince1970 < nextFetchTime { return }
        print("讀取資料中...")
        fetching = true
        Alamofire.request(endPoint, parameters: ["hash_tag": hashTag]).responseData { [unowned self](resData) -> Void in
            do {
                let data = resData.result.value!
                let decoder = JSONDecoder()
                let posts = try decoder.decode([IgPost].self, from: data)
                self.savePosts(igPosts: posts)
                self.nextFetchTime = Calendar.current.date(byAdding: .second, value: self.updateInterval, to: Date())!.timeIntervalSince1970
                print("資料讀取成功")
            } catch {
                self.nextFetchTime = Calendar.current.date(byAdding: .second, value: 5, to: Date())!.timeIntervalSince1970
                print("哎呀讀取 Posts 出錯了～五秒後重試")
            }
            self.fetching = false
        }
    }
    
    private func savePosts(igPosts: [IgPost]) {
        if igPosts.count == 0 { return }
        try! realm.write {
            for igPost in igPosts {
                if realm.objects(IgPost.self).filter("id = '\(igPost.id)'").count == 0 {
                    realm.add(igPosts, update: true)
                }
            }
        }
    }
}

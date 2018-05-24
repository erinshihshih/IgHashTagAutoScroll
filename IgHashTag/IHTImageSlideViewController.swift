//
//  IHTImageSlideViewController.swift
//  IgHashTag
//
//  Created by Jia on 2018/5/18.
//  Copyright © 2018年 Erin Shih. All rights reserved.
//

import UIKit
import RealmSwift
import FSPagerView
import SDWebImage
import Alamofire

class IHTImageSlideViewController: UIViewController {
    //輪播間隔秒數
    let automaticSlidingIntervalSec: CGFloat = 3.0
    
    var igPosts = [IgPost]()
    var realm: Realm!
    var realmNotificationToken: NotificationToken?
//    var needToReloadData = false
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var imagePagerView: FSPagerView!{
        didSet {
            self.imagePagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        setUpPagerView()
    }
    
    private func initData() {
        realm = try! Realm()
        _ = IHTDataManager.sharedInstance
        realmNotificationToken = realm.observe { [weak self] note, realm in
            self?.loadDataFormDb()
            self?.imagePagerView.reloadData()
            self?.realmNotificationToken?.invalidate()
        }
    }
    
    private func setUpPagerView() {
        imagePagerView.transformer = FSPagerViewTransformer(type: .crossFading)
        imagePagerView.automaticSlidingInterval = automaticSlidingIntervalSec
        imagePagerView.isInfinite = true
    }
    
    private func loadDataFormDb() {
        igPosts = Array(realm.objects(IgPost.self).sorted(byKeyPath: "fetchTime", ascending: false))
        if igPosts.count > 0 {
            contentLabel.text = igPosts[0].content
        }
    }
    
    deinit{
        realmNotificationToken?.invalidate()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension IHTImageSlideViewController: FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return igPosts.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        cell.imageView?.sd_setImage(with: URL(string: igPosts[index].imgUrl), placeholderImage: UIImage(named: "placeholder.png"))
        cell.imageView?.contentMode = .scaleAspectFit
        return cell
    }
}


extension IHTImageSlideViewController: FSPagerViewDelegate {
//    func pagerView(_ pagerView: FSPagerView, didEndDisplaying cell: FSPagerViewCell, forItemAt index: Int) {
//        needToReloadData = index == igPosts.count - 1
//    }

    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        contentLabel.text = igPosts[pagerView.currentIndex].content
    }
    
    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        if pagerView.currentIndex == 0 {
            print("展示完了一輪 重新從資料庫抓資料")
            loadDataFormDb()
            imagePagerView.reloadData()
            pagerView.scrollToItem(at: 0, animated: false)
        }
    }
}

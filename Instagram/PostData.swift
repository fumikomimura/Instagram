//
//  PostData.swift
//  Instagram
//
//  Created by 三村文子 on 2020/03/03.
//  Copyright © 2020 三村文子. All rights reserved.
//

//import Foundation
import UIKit
import Firebase

class PostData: NSObject {
    var id: String
    var name: String?
    var caption: String?
    var date: Date?
    var likes: [String] = []
    var isLiked: Bool = false
    var commentTextField: String? //⭐️追加
//  コメント者の名前を保存したい
    
    init(document: QueryDocumentSnapshot) {
        self.id = document.documentID
        
        let postDic = document.data()
        
        self.name = postDic["name"] as? String
        
        self.caption = postDic["caption"] as? String
        
        self.commentTextField = postDic["commentText"] as? String //❤️追加
        
        let timestamp = postDic["date"] as? Timestamp
        self.date = timestamp?.dateValue()
        
        if let likes = postDic["likes"] as? [String] {
            self.likes = likes
        }
        if let myid = Auth.auth().currentUser?.uid {
            //likesの配列の中にmyidがふくまれているかチェックすることで、自分が言い値を押しているかを判断
            if self.likes.firstIndex(of: myid) != nil {
                //myidがあれば、いいねを押していると認識する
                self.isLiked = true
            }
        }
    }
}

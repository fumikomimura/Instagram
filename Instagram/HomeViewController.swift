//3/1start
//  HomeViewController.swift
//  Instagram
//
//  Created by 三村文子 on 2020/03/01.
//  Copyright © 2020 三村文子. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    //投稿データを格納する配列
    var postArray: [PostData] = []
    
    //Firestoreのリスナー。データ更新されたことを自動的に実行してくれるためのメソッド
    var listener: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //カスタムセルを登録する
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        
        if Auth.auth().currentUser != nil {
            //ログイン済み
            if listener == nil {
                //listener未登録なら登録してスナップショットを受信する
                let postsRef = Firestore.firestore().collection(Const.PostPath).order(by: "date", descending: true)
                listener = postsRef.addSnapshotListener() { (querySnapshot, error) in
                    if let error = error {
                        print("DEBUG_PRINT: snapshotの取得が失敗しました　\(error)")
                        return
                    }
                    //取得したdocumentをもとにPostDataを作成し、postArrayの配列にする
                    self.postArray = querySnapshot!.documents.map { document in
                        print("DEBUG_PRINT: document取得　\(document.documentID)")
                        let postData = PostData(document: document)
                        return postData
                    }
                    //TableViewの表示を更新する
                    self.tableView.reloadData()
                }
            }
        } else {
            //ログイン未（またはログアウト済）
            if listener != nil {
                //listener登録済なら削除してpostArrayをクリアする
                listener.remove()
                listener = nil
                postArray = []
                tableView.reloadData()
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        cell.setPostData(postArray[indexPath.row])
        
        //セル内のいいねボタンのアクションをソースコードで設定する
        cell.likeButton.addTarget(self, action:#selector(handleButton(_:forEvent:)), for: .touchUpInside)
        //セル内のコメントボタンのアクションコードを設定　addTargetが青い線を引っ張って設定するのと同じ
        cell.commentButton.addTarget(self, action:#selector(commentButton(_:forEvent:)), for: .touchUpInside)
        return cell
    }
    //セル内のボタンがタップされた時に呼ばれるメソッド
    @objc func handleButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました")
        
        //タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in:self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        //配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
        //likesを更新する
        if let myid = Auth.auth().currentUser?.uid {
            //更新データを作成する
            var updateValue: FieldValue
            if postData.isLiked {
                //すでにいいねをしている場合はいいね解除のためmyidを取り除く更新データを作成
                updateValue = FieldValue.arrayRemove([myid])
            } else {
                //今回新たにいいねを押した場合は、myidを追加する更新データを作成
                updateValue = FieldValue.arrayUnion([myid])
            }
            //likesに更新データを書き込む
            let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
            postRef.updateData(["likes": updateValue])
        }
    }
    //コメントボタンがタップされた時に呼ばれるメソッド（Actionの実装）　　コメント欄への画面遷移
    @objc func commentButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: コメントボタンがタップされました")
        
        //タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in:self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        //配列（postArray)からタップされたindexPathのpostDataを取り出す（取得）
        let postData = postArray[indexPath!.row]
        
        //storyboardIDを書いた方がいい
        let commentTextField = self.storyboard?.instantiateViewController(withIdentifier: "commentTextField")as! CommentViewController
        
        //値受け渡し
        commentTextField.postArray = postData
        self.present(commentTextField, animated: true, completion: nil)
    }
    
    //⭐️コメントを受け取る
  
    
    //    //❤️違う？コメント投稿ボタンをタップした時の処理を追加する
    //       @objc func sendCommentButton(_ sender: UIButton, forEvent event: UIEvent) {
    //       print("DEBUG_PRINT: コメント投稿ボタンがタップされました。")
    //
    //        //タップされたセルのインデックスを求める
    //        let touch = event.allTouches?.first
    //        let point = touch!.location(in:self.tableView)
    //        let indexPath = tableView.indexPathForRow(at: point)
    //
    //        //取り出したい情報はpostData配列(Array)の中に入っている
    //        let commentText = postArray
    //
    //        let commentLabel = self.storyboard? . instantiateViewController(withIdentifier: "commentText") as! CommentViewController
    
    //　commentViewControllerのcaption表示のためのコード　（サンプルとして）
    //        //    postDataの内容をセルに表示
    //          func setPostData(_ postData: PostData) {
    //
    //              //画像の表示
    //              postImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
    //              let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postData.id + ".jpg")
    //              postImageView.sd_setImage(with: imageRef)
    //
    //              //キャプションの表示
    //              self.captionLabel.text = "\(postData.name!) : \(postData.caption!)"
    //              print("DEBUG_PRINT: 画像、キャプションが表示されました")
    //          }
    
    //commentLabelを表示させるためのコード
    
    
    
}



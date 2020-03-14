//
//  CommentViewController.swift
//  Instagram
//
//  Created by 三村文子 on 2020/03/05.
//  Copyright © 2020 三村文子. All rights reserved.
//
//HomeViewController.swiftのコードを参考にする！？セルを取得？

//PostViewCellに投稿したものを反映させる処理を書く
//データを渡す
//データの内容を表示
//コメント入力してsend

//3/12
//・このエラーの対処
//・コメントと名前の保存
//・homeViewControllerに値を渡す
//・homeViewControllerで値を受け取る

//3.13~コメントの表示をhomeviewControllerにする
//


import UIKit
import Firebase
import FirebaseUI
import SVProgressHUD

class CommentViewController: UIViewController ,UITextFieldDelegate {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var commentTextField: UITextField!
    
    //投稿データを格納する配列 対象データが一つだからこのコードになる
    //var postArray: PostData?
    var postArray: PostData!
    //Firestoreのリスナー?
    var listener: ListenerRegistration!
    
    //    postDataの内容をセルに表示
    func setPostData(_ postData: PostData) {
        
        //画像の表示
        postImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postData.id + ".jpg")
        postImageView.sd_setImage(with: imageRef)
        
        //キャプションの表示
        self.captionLabel.text = "\(postData.name!) : \(postData.caption!)"
        print("DEBUG_PRINT: 画像、キャプションが表示されました")
    }
    
    //コメントを入力
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    //キーボードを閉じる
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    //画面を更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    //❤️ボタンをタップした時に呼ばれるメソッド　コメントをホーム画面に送る
    //postViewController投稿ボタンをタップした時captionをうつすのを参考にした
    //    いいねボタンと同じ要領でよいので、いいねボタンがどうやっていいねされた数を
    //    firebaseに保存しているか考えながら実装に挑戦してみてください
    //    ちゃんとfirebase上にコメントデータが保存されれば、
    //    そのあとはcell.swiftのその67行目のコメントアウトはもとに戻してみてください
    @IBAction func sendCommentButton(_ sender: Any) {
        print("DEBUG_PRITN: コメント投稿ボタンがタップされました")
        
        //投稿データの保存場所を定義する
        if let comment = commentTextField.text, !comment.isEmpty {
            SVProgressHUD.show()   //追加
            
            //どこにの部分が新規作成になっている
            let postRef = Firestore.firestore().collection(Const.PostPath).document(postArray.id)
            //HUDで投稿処理中の表示を開始
            //SVProgressHUD.show()
            postRef.updateData(["commentText": comment])
            
            //❤️❤️❤️3/12 メンターさんに教えてもらったコードを記載　追加とコメントアウト
            //これは１行のみの表示なので複数行表示しようとしたらまた内容が変わってくる。
            SVProgressHUD.showSuccess(withStatus: "投稿しました")
            dismiss(animated:true, completion:  nil) //追加
        } else {   //追加
            SVProgressHUD.showError(withStatus: "コメントを入力してください") //追加
        }   //追加
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setPostData(postArray)
        
        //データを受け取る
        let postData = postImageView.image
        
        // Do any additional setup after loading the view.
    }
    //    //コメントを入力
    //    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    //        self.view.endEditing(true)
    //        return true
    //    }
    //    //キーボードを閉じる
    //    @objc func dismissKeyboard() {
    //        view.endEditing(true)
    //    }
    //    //画面を更新させる
    //    override func viewWillAppear(_ animated: Bool) {
    //        super.viewWillAppear(animated)
    //    }
    //8.3を参照
    //⭐️コメント投稿ボタンをタップした時の処理を追加する
    //違うかも↓　Actionが正しい？
    //    //いいねボタンが動作するようにどこかコードを追記が必要かも
    //    @objc func sendCommentButton(_ sender: UIButton, forEvent event: UIEvent) {
    //        print("DEBUG_PRINT: コメント投稿ボタンがタップされました。")
    //
    //        //⭐️コメント保存場所を定義する　名前はまだ
    //        let postRef = Firestore.firestore().collection(Const.PostPath).document()
    //
    //        //⭐️FireStoreに投稿データを保存する  いいねボタンを参考に、保存のコードを修正する
    //        //commentTextFieldの変数に入るものは、ユーザー名
    //        //islikeの場合には、ユーザーIDを保存するようになっています。
    //        //これだと、commentというキーの中に、ユーザー名しか格納できないようなコードになっている
    //
    //        let commentTextField = Auth.auth().currentUser?.displayName
    //        let postDic = ["comment": self.commentTextField.text] as [String: Any]
    //        postRef.setData(postDic)
    //        uid（ユーザーID)
    //
    //        let nameLabel = Auth.auth().currentUser?.uid
    //        //更新データを作成する
    //        //             postData.nameLabel
    //        //commentText？
    //
    //        //         let commentLabel = Auth.auth().commentTextField.text
    //
    //
    //        //HUDで投稿完了を表示する
    //        SVProgressHUD.showSuccess(withStatus: "コメント投稿しました")
    //
    //        //値を渡す
    //        let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "homeViewController")as! HomeViewController
    //
    //        // 渡す先のViewController.受取用変数 = 渡す値
    //        homeViewController = commentTextField
    //        self.present(homeViewController, animated:true, completion:nil )
    //
    //    }
    //
    //}
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
}

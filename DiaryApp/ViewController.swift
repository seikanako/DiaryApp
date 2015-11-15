//
//  ViewController.swift
//  DiaryApp
//
//  Created by kana on 2015/11/04.
//  Copyright © 2015年 kana. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var TABLE_NAME = "Diary"
    var objects : Array<NCMBObject>= []
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // データを取得する
        self.getItems()
        
    }

    //
    // データベースよりデータを取得する
    //
    func getItems(){
        
        let query = NCMBQuery(className: TABLE_NAME)
        
        query.findObjectsInBackgroundWithBlock({(NSArray items, NSError error) in
            
            query.whereKeyExists("title")
            query.orderByDescending("createDate")
            
            if error == nil{
                print("登録件数：\(items.count)")
                
                if items.count > 0 {
                    self.objects = (items as? Array)!
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    //
    // Segueの設定
    //
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "edit" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                if let dvc = segue.destinationViewController as? DetailViewController {
                    dvc.savedObj = self.objects[indexPath.row]
                    dvc.updateButton.title = "Update"
                }
            }
        } else if segue.identifier == "add" {
            (segue.destinationViewController as! DetailViewController).updateButton.title = "Add"
        } else {
            // 遷移先が定義されていない
        }
    }
    
    /// 登録／編集画面から戻ってきた時の処理を行います。
    /// 今回はUnwind Identifierは必要ないので定義してません。
    @IBAction func unwindromEdit(segue:UIStoryboardSegue) {
        let dvc = segue.sourceViewController as! DetailViewController
        if dvc.titleText.text!.characters.count < 3 {
            return
        }
        
        if dvc.savedObj == nil {
            print("オブジェクトが存在しないので、新規とみなします。")
            self.addWithItem(dvc)
        } else {
            print("更新処理")
            self.setNCMBObj(dvc, obj: dvc.savedObj!)
            dvc.savedObj?.saveInBackgroundWithBlock({ (error: NSError!) -> Void in
                self.tableView.reloadData()
            })
        }
    }
    
    /// 新規にitemを追加します
    ///
    /// - parameter DetailViewController
    /// - returns: None
    func addWithItem(dvc : DetailViewController) {
 
        let obj = NCMBObject(className: TABLE_NAME)
        self.setNCMBObj(dvc, obj: obj)
        
        // 非同期で保存
        obj.saveInBackgroundWithBlock { (error: NSError!) -> Void in
            if(error == nil){
                print("新規Itemの保存成功。表示の更新などを行う。")

                // ItemをDataSourceに追加して、表示を更新します
                self.objects.append(obj)
                let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                self.tableView.reloadData()
            } else {
                print("新規Itemの保存に失敗しました: \(error)")
            }
        }
    }
    
    //
    // NCMBObjectにDetailViewControllerのデータを設定する。
    //
    func setNCMBObj(dvc : DetailViewController ,obj : NCMBObject){
        
        obj.setObject(dvc.titleText.text, forKey: "title") // タイトル
        obj.setObject(dvc.dateText.text, forKey: "date") // 日付
        obj.setObject(dvc.comment.text, forKey: "comment") // コメント
    }
    
    func setNCMBFile(){
        
    }
    
    // ------------------------------------------------------------------------
    // TableView
    // ------------------------------------------------------------------------

    //
    // Cellが選択された際に呼び出されるデリゲートメソッド.
    //
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("Num: \(indexPath.row)")
        print("Value: \(objects[indexPath.row])")
    }
    
    //
    // Cellの総数を返すデータソースメソッド.
    // (実装必須)
    //
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    //
    // Cellに値を設定するデータソースメソッド.
    // (実装必須)
    //
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // 再利用するCellを取得する.
        let cell = tableView.dequeueReusableCellWithIdentifier("tableCell", forIndexPath: indexPath)
        
        // Cellに値を設定する.
        let data = objects[indexPath.row]
        cell.textLabel?.text = data.objectForKey("title") as? String
        
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let item = objects[indexPath.row] as NCMBObject
            let objectID = item.objectId
            let query =  NCMBQuery(className: TABLE_NAME)
            
            query.getObjectInBackgroundWithId(objectID, block: { (object: NCMBObject!, fetchError: NSError?) -> Void in
                if fetchError == nil {
                    // NCMBから非同期で対象オブジェクトを削除します
                    object.deleteInBackgroundWithBlock({ (deleteError: NSError!) -> Void in
                        if (deleteError == nil) {
                            self.objects.removeAtIndex(indexPath.row)
                            // データソースから削除
                            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                        } else {
                            print("削除失敗: \(deleteError)")
                        }
                    })
                } else {
                    print("オブジェクト取得失敗: \(fetchError)")
                }
            })
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}


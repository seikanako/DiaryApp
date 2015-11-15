//
//  DetailViewController.swift
//  DiaryApp
//
//  Created by kana on 2015/11/04.
//  Copyright © 2015年 kana. All rights reserved.
//

import UIKit

protocol DetailViewControllerDelegate{
    func didDatePickerOKClicked()
}

class DetailViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet var updateButton : UIBarButtonItem!
    
    @IBOutlet var dateText : UITextField!

    @IBOutlet var titleText : UITextField!

    @IBOutlet var comment : UITextView!
    
    @IBOutlet var imageView : UIImageView!
    
    
    var toolBar : UIToolbar!
    
    var image : UIImage! // 画像
    
    var savedObj : NCMBObject?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // テキストフィールドにDatePickerを表示する。
        let datePicker = UIDatePicker()
        datePicker.addTarget(self, action: "onDidChangeDate:", forControlEvents: .ValueChanged)
        dateText.inputView = datePicker
        
        // 日本の日付で表示する。
        datePicker.locale = NSLocale(localeIdentifier: "ja_JP")

        // コメントのTextViewに枠をつける
        comment.layer.borderWidth = 0.5
        comment.layer.borderColor = UIColor.lightGrayColor().CGColor
        comment.layer.cornerRadius = 8
        
        
        // UIToolBarの設定
        toolBar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height/6, self.view.frame.size.width, 40.0))
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        toolBar.backgroundColor = UIColor.whiteColor()
        
        let toolBarBtn = UIBarButtonItem(title: "Done", style: .Done, target: self, action: "tappedToolBarBtn:")
        toolBarBtn.tag = 1
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        toolBar.items = [spacer, toolBarBtn]
        
        // タイトル、日付、コメントにツールバーを設定
        titleText.inputAccessoryView = toolBar
        dateText.inputAccessoryView = toolBar
        comment.inputAccessoryView = toolBar
        
        
        if updateButton.title == "Add"{
            
            // 追加の時のみ今日の日付を設定
            let dateFormatter: NSDateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd hh:mm"
            dateText.text = dateFormatter.stringFromDate(NSDate())
            
        }else{
            self.titleText.text = savedObj!.objectForKey("title") as? String
            self.dateText.text = savedObj!.objectForKey("date") as? String
            self.comment.text = savedObj!.objectForKey("comment") as? String
        }
    }
    
    //
    // DatePickerが選ばれた際に呼ばれる.
    //
    internal func onDidChangeDate(sender: UIDatePicker){
        
        // フォーマットを生成.
        let myDateFormatter: NSDateFormatter = NSDateFormatter()
        myDateFormatter.dateFormat = "yyyy/MM/dd hh:mm"
        
        // 日付をフォーマットに則って取得.
        let mySelectedDate: NSString = myDateFormatter.stringFromDate(sender.date)
        dateText.text = mySelectedDate as String
    }
    
    // 「完了」を押すと閉じる
    func tappedToolBarBtn(sender: UIBarButtonItem) {
        titleText.resignFirstResponder()
        dateText.resignFirstResponder()
        comment.resignFirstResponder()
    }
        
    //
    // 追加/更新共用ボタンがタップされた時に呼び出されます。
    //
    @IBAction func tappedUpdateButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

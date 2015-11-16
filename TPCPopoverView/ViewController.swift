//
//  ViewController.swift
//  TPCPopoverView
//
//  Created by tripleCC on 15/11/16.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

import UIKit

class ViewController: UIViewController, TPCPopoverViewDataSource, TPCPopoverViewDelegate {

    var view1: UIView?
    let messages = ["小组通知", "加入的小组", "发表的话题", "收藏的话题"]
    var count = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        let v = UIView(frame: CGRect(x: UIScreen.mainScreen().bounds.width / 2, y: 100, width: 20, height: 20))
        v.backgroundColor = UIColor.redColor()
        self.view.addSubview(v)
        view1 = v
        
        view.backgroundColor = UIColor.orangeColor()
    }
    
    func popoverView(popoverView: TPCPopoverView, numberOfRowsInSection: Int) -> Int {
        return messages.count
    }
    
    func popoverView(popoverView: TPCPopoverView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        cell.textLabel!.text = messages[indexPath.row];
        cell.textLabel!.font = UIFont.systemFontOfSize(12.0);
        cell.imageView!.image = UIImage(named: "1")
        
        return cell
    }
    
    func popoverView(popoverView: TPCPopoverView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(indexPath.row)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        count++
        if count % 3 == 0 {
            TPCPopView.showMessages(messages, withContainerSize: CGSize(width: 110, height: 140), fromView: view1, fadeDirection: TPCPopViewFadeDirection.LeftTop) { (row) -> Void in
                print(row)
            }
        } else if count % 3 == 1 {
            TPCPopoverView.showWithContainerSize(CGSize(width: 110, height: 140), fromView: view1!, fadeDirection: TPCPopoverViewFadeDirection.Center, dataSource: self, delegate: self)
        } else if count % 3 == 2 {
            TPCPopoverView.showMessages(messages, containerSize: CGSize(width: 110, height: 140), fromView: view1!, fadeDirection: TPCPopoverViewFadeDirection.RightTop) { (row) -> () in
                print(row)
            }
        }
    }
}


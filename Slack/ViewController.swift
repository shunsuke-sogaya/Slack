//
//  FirstViewController.swift
//  Slack

//  Created by Shunsuke Sogaya on 2017/09/07.
//  Copyright © 2017年 Shunsuke Sogaya. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AlamofireImage


class ViewController: UIViewController {
    
    @IBOutlet weak var tableVIew: UITableView!
   
    var channels : [Channel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let token = "xoxb-237355961810-VBAN68KWAkR2zNw0UefMVDlR"
        
        SessionManager.default.request(
            "https://slack.com/api/channels.list",
            method: .get,
            parameters: ["token" : token, "pretty" : "1"],
            encoding: URLEncoding(),
            headers: nil
            )
            .responseData { (response) in
                
                switch response.result {
                case .success(let data):
                    
                    let json = JSON(data)
                    let channelIDs = json["channels"].arrayValue.map{ $0["id"].stringValue}
                    print(channelIDs)
                    
                case .failure(let error):
                    break
                }
            }
    }
}


    extension ViewController : UITableViewDataSource {
        
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return channels.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChannelCell
            
            let channel = channels[indexPath.item]
            
            cell.channelNameLabel.text = channel.name
            
            return cell
        }
    }
    
    extension ViewController : UITableViewDelegate {
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            
            return 100
        }
    }
    
    class ChannelCell : UITableViewCell {
        @IBOutlet weak var channelNameLabel: UILabel!
    }


struct Channel {
    
    let name: String
    let identifier: String
    
    init(json: JSON) {
        
        name = json["name"].stringValue
        identifier = json["id"].stringValue
    }
}

class SlackAPI {
    
    let token = "xoxb-237355961810-VBAN68KWAkR2zNw0UefMVDlR"
    
    var userListContent: JSON = []
    var channelListContent: JSON = []
    var userImageContent: JSON = []
    
    
    func getUserList() -> JSON {
        
        if userListContent.isEmpty {
            //userlistの取得
            //ロックの取得
            var keepAlive = true
            
            Alamofire.request("https://slack.com/api/users.list?token=" + token).responseJSON { response in
                
                guard let object = response.result.value else {
                    return
                }
                
                let json = JSON(object)
                //    print("//---SlackAPI getUserList--"")
                //    print(json)
                
                self.userListContent = json
                
                //ロックの解除
                keepAlive = false
                
                
                //ロックが解除されるまで待つ
                let runLoop = RunLoop.current
                while keepAlive &&
                    runLoop.run(mode: RunLoopMode.defaultRunLoopMode, before: NSDate(timeIntervalSinceNow: 0.1) as Date) {
                        // 0.1秒毎の処理なので、処理が止まらない
                }
            }
            
        }
        
        return self.userListContent
    }
    
    
    
    func getChannelList() -> JSON {
        
        if userListContent.isEmpty {
            //ロックの取得
            var keepAlive = true
            
            //channelListの取得
            Alamofire.request("https://slack.com/api/channels.list?token=" + token + "&pretty=1").responseJSON { response in
                
                guard let object = response.result.value else {
                    return
                }
                
                let json = JSON(object)
                // print("//----SlackAPI getChannelList--//"
                //print(json)
                
                self.channelListContent = json
                //                print(self.channelListContent)
                //ロックの解除
                keepAlive = false
                
                //ロックが解除されるまで待つ
                let runLoop = RunLoop.current
                while keepAlive &&
                    runLoop.run(mode: RunLoopMode.defaultRunLoopMode, before: NSDate(timeIntervalSinceNow: 0.1) as Date) {
                        // 0.1秒毎の処理なので、処理が止まらない
                }
            }
            
        }
        
        return self.channelListContent
    }

    
    func postMassege(channel: String, text: String, as_user: String) {
        
        let url = "https://slack.com/api/chat.postMessage"
        //token=xoxp-235445599280-237350709762-237531810837-07aefdd3c26343b695c95007646659fa&channel=@\(channel)&text=\(text)&as_user=\(as_user)&pretty=1"
        
        let parameters :Parameters = [
            "token" : token,
            "channel" : "C6Y0L4SRH",
            "text" : text,
            "pretty" : "1"
        ]
        
        Alamofire.request(url, method: .post, parameters:parameters, encoding: URLEncoding(), headers: nil).responseJSON {
            response in
        }
    }
    
}


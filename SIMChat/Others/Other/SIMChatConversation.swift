//
//  SIMChatConversation.swift
//  SIMChat
//
//  Created by sagesse on 9/21/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

///
/// 聊天会话
///
class SIMChatConversation: NSObject {
    /// 初始化
    init(recver: SIMChatUser, sender: SIMChatUser) {
        
        self.sender = sender
        self.recver = recver
        
        super.init()
    }
    
    /// 管理器(保留联系)
    weak var manager: SIMChatManager!
    /// 代理
    weak var delegate: SIMChatConversationDelegate?
    
    /// 发送者
    private(set) var sender: SIMChatUser
    /// 接收者
    private(set) var recver: SIMChatUser
    
    /// 消息
    internal lazy var messages = [SIMChatMessage]()
}

// MARK: - Public Method
extension SIMChatConversation {
    ///
    /// 发送一条消息
    ///
    func send(content: AnyObject, finish: ((SIMChatMessage?, NSError?) -> ())? = nil) {
        
        let m = SIMChatMessage(content)
        
        // 填写发送信息
        m.sender = self.sender
        m.sentTime = .now
        m.sentStatus = .Sending
        // 填写接收者信息
        m.recver = self.recver
        m.recvTime = .now
        m.recvStatus = .Unknow
        
        // 真的需要追加?
        if !self.messages.contains(m) {
            // 真正的发送出去
            self.messages.insert(m, atIndex: 0)
            // TODO: 如果是重发需要删除了再发送 
            delegate?.chatConversation?(self, didSendMessage: m)
        }
        
        // 完成
        finish?(m, nil)
        
        // TODO: 测试环境!
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1000 * NSEC_PER_MSEC)), dispatch_get_main_queue()) {
            
            m.sentStatus = .Sent
            m.statusChanged()
            
            let rm = SIMChatMessage()
            
            rm.sender = m.recver
            rm.recver = m.sender
            rm.sentTime = .now
            rm.sentStatus = .Sent
            rm.recvTime = .now
            rm.recvStatus = .Unread
            rm.content = m.content
            
            self.recvice(rm)
        }
    }
    ///
    /// 接收消息
    ///
    func recvice(m: SIMChatMessage) {
        // 需要避免重复添加?
        self.messages.insert(m, atIndex: 0)
        // 通知
        self.delegate?.chatConversation?(self, didReceiveMessage: m)
    }
    ///
    /// 删除消息
    ///
    func remove(m: SIMChatMessage) {
        // 真的需要删除?
        if let idx = messages.indexOf(m) {
            messages.removeAtIndex(idx)
        }
        // 通知
        delegate?.chatConversation?(self, didRemoveMessage: m)
    }
    ///
    /// 标记消息为己读
    ///
    func read(m: SIMChatMessage) {
        SIMLog.trace()
    }
    ///
    /// 查询多条消息
    ///
    func query(count: Int, latest: SIMChatMessage?, finish: ((NSArray?, NSError?) -> ())?) {
        SIMLog.trace()
    }
}


// MARK: - Helper
extension SIMChatConversation {
    ///
    /// 第一条, 这是最新的
    ///
    var latest: SIMChatMessage? { return messages.first }
    ///
    /// 最后一条, 这是最旧的
    ///
    var last: SIMChatMessage? { return messages.last }
    ///
    /// 总数
    ///
    var count: Int { return messages.count }
    ///
    /// 未读总数
    ///
    var unread: Int {
        // TODO: 未读记数
        return 0
    }
}

///
/// 消息插入
/// 消息删除
/// 消息更新
///
@objc protocol SIMChatConversationDelegate : NSObjectProtocol {
   
    optional func chatConversation(conversation: SIMChatConversation, didSendMessage message: SIMChatMessage)
    optional func chatConversation(conversation: SIMChatConversation, didReceiveMessage message: SIMChatMessage)
    optional func chatConversation(conversation: SIMChatConversation, didRemoveMessage message: SIMChatMessage)
    optional func chatConversation(conversation: SIMChatConversation, didUpdateMessage message: SIMChatMessage)
}

//
//  MessagesViewController.swift
//  MessagesExtension
//
//  Created by Pedro Cacique on 07/05/17.
//  Copyright © 2017 Pedro Cacique. All rights reserved.
//

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController {
    
    @IBOutlet weak var gameoverlbl: UILabel!
    @IBOutlet weak var myView: UIView!
    @IBOutlet weak var bot0: UIImageView!
    @IBOutlet weak var bot1: UIImageView!
    @IBOutlet weak var bot2: UIImageView!
    
    @IBOutlet weak var bot3: UIImageView!
    @IBOutlet weak var bot4: UIImageView!
    @IBOutlet weak var bot5: UIImageView!
    
    @IBOutlet weak var bot6: UIImageView!
    @IBOutlet weak var bot7: UIImageView!
    @IBOutlet weak var bot8: UIImageView!
    
    public var player:Int = 0
    public var selectedPositions:[Int] = [-1,-1,-1,-1,-1,-1,-1,-1,-1]
    public var bots:[UIImageView] = []
    public var lastSelected:Int = -1;
    public var taps = [UITapGestureRecognizer]()
    public var gameOver:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bots = [bot0,bot1,bot2,bot3,bot4,bot5,bot6,bot7,bot8]
        
        
        for _ in 0...8{
            taps.append(UITapGestureRecognizer(target: self, action: #selector(selectPos)))
        }
        
        for i in 0...bots.count-1{
            bots[i].addGestureRecognizer(taps[i])
            bots[i].isUserInteractionEnabled = true
        }
    }
    
    func selectPos(sender: UITapGestureRecognizer)
    {
        if !gameOver && !isSenderSameAsRecipient(){
            if self.lastSelected == -1{
                doSelect(sender)
            } else {
                self.selectedPositions[self.lastSelected] = -1
                doSelect(sender)
            }
        }
    }
    
    func doSelect(_ sender: UITapGestureRecognizer){
        self.selectedPositions[sender.view!.tag] = self.player
        self.lastSelected = sender.view!.tag
        
        let conversation = activeConversation
        let session = conversation?.selectedMessage?.session ?? MSSession()
        
        
        if(checkGameOver() != -1){
            //GAME OVER
            gameOver = true
        }
        gameoverlbl.alpha = gameOver ? 0.5 : 0.0
        
        
        let layout = MSMessageTemplateLayout()
        layout.image = drawBoard()
        
        var components = URLComponents()
        let pos = URLQueryItem(name: "lastPlayer", value: String(self.player))
        let selpos = URLQueryItem(name: "selectedPositions", value: self.selectedPositions.description)
        components.queryItems = [pos, selpos]
        
        let message = MSMessage(session: session)
        message.layout = layout
        message.url = components.url

        conversation?.insert(message)
        requestPresentationStyle(.compact)
    }
    
    func checkGameOver() -> Int{
        var winner:Int = -1
        // 0 1 2    3 4 5   6 7 8
        if self.selectedPositions[0] != -1 && ((self.selectedPositions[0] == self.selectedPositions[1]) && (self.selectedPositions[1] == self.selectedPositions[2])){
            winner = self.selectedPositions[0]
        } else if self.selectedPositions[3] != -1 && ((self.selectedPositions[3] == self.selectedPositions[4]) && (self.selectedPositions[4] == self.selectedPositions[5])){
            winner = self.selectedPositions[3]
        } else if self.selectedPositions[6] != -1 && ((self.selectedPositions[6] == self.selectedPositions[7]) && (self.selectedPositions[7] == self.selectedPositions[8])){
            winner = self.selectedPositions[6]
        } else if self.selectedPositions[0] != -1 && ((self.selectedPositions[0] == self.selectedPositions[3]) && (self.selectedPositions[3] == self.selectedPositions[6])){
            winner = self.selectedPositions[0]
        } else if self.selectedPositions[1] != -1 && ((self.selectedPositions[1] == self.selectedPositions[4]) && (self.selectedPositions[4] == self.selectedPositions[7])){
            winner = self.selectedPositions[1]
        } else if self.selectedPositions[2] != -1 && ((self.selectedPositions[2] == self.selectedPositions[5]) && (self.selectedPositions[5] == self.selectedPositions[8])){
            winner = self.selectedPositions[2]
        } else if self.selectedPositions[0] != -1 && ((self.selectedPositions[0] == self.selectedPositions[4]) && (self.selectedPositions[4] == self.selectedPositions[8])){
            winner = self.selectedPositions[0]
        } else if self.selectedPositions[2] != -1 && ((self.selectedPositions[2] == self.selectedPositions[4]) && (self.selectedPositions[4] == self.selectedPositions[6])){
            winner = self.selectedPositions[2]
        }
        
        return winner
    }
    
    
    private func isSenderSameAsRecipient() -> Bool {
        guard let conversation = activeConversation else { return false }
        guard let message = conversation.selectedMessage else { return false }
        
        return message.senderParticipantIdentifier == conversation.localParticipantIdentifier
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        
        // Use this method to configure the extension and restore previously stored state.
        
        if let messageURL = conversation.selectedMessage?.url {
            decodeURL(messageURL)
            drawBoard()
        }
        if(checkGameOver() != -1){
            //GAME OVER
            gameOver = true
        }
        gameoverlbl.alpha = gameOver ? 0.5 : 0.0
    }
    
    func drawBoard() -> UIImage{
        for i in 0...bots.count-1{
            if selectedPositions[i] == -1{
                bots[i].image = UIImage(named:"space")
            }
            else if selectedPositions[i] == 0{
                bots[i].image = UIImage(named:"blue")
            }
            else{
                bots[i].image = UIImage(named:"red")
            }
        }
        return UIImage.init(view: self.myView)
    }
    
    public func decodeURL(_ messageURL:URL){
        guard let urlComponents = NSURLComponents(url: messageURL, resolvingAgainstBaseURL: false), let queryItems = urlComponents.queryItems else { return }
        
        for item in queryItems {
            if item.name == "lastPlayer"{
                self.player = item.value == "0" ? 1 : 0
            }
            if item.name == "selectedPositions"{
                var str = item.value ?? "";
                
                str = str.chopPrefix()
                str = str.chopSuffix()
                
                let b = str.components(separatedBy: ", ");
                
                for i in 0...b.count-1{
                    self.selectedPositions[i] = Int(b[i])!
                }
            }
        }
        
    }
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dissmises the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
        self.dismiss()
    }
   
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
        drawBoard()
        self.dismiss()
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
    
        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.
    
        // Use this method to prepare for the change in presentation style.
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
    }

}

extension UIImage{
    convenience init(view: UIView) {
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage)!)
    }
}

extension String {
    func chopPrefix(_ count: Int = 1) -> String {
        return substring(from: index(startIndex, offsetBy: count))
    }
    
    func chopSuffix(_ count: Int = 1) -> String {
        return substring(to: index(endIndex, offsetBy: -count))
    }
}


import UIKit
import MessageKit
import InputBarAccessoryView
import Firebase

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

struct Sender: SenderType {
    var photoUrl: String
    var senderId: String
    var displayName: String
}

class DialogViewController: MessagesViewController {
    
    deinit {
        print("out")
    }
    
    private var messages = [Message]() {
        didSet {
            messages.sort { (one, two) -> Bool in
                one.sentDate < two.sentDate
            }
            messagesCollectionView.reloadData()
            messagesCollectionView.scrollToLastItem()
        }
    }
    
    var selfSenderPhotoUrl: String!
    var selfSenderId: String!
    var selfSenderName: String!
    
    var conversationId: String!
    
    private var selfSender: Sender!
    
    var sendersImageUrl = Set<String>()
    
    let referenceUsers = Database.database().reference().child("users")
    let referenceConversation = Database.database().reference().child("conversations")
    var currentUserId: String!
    
    var downloadedPhoto = [String : UIImage]() {
        didSet {
            messagesCollectionView.reloadData()
        }
    }
    
    let group = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        userRegister(email: "magamed@gmail.com", password: "123456", name: "Magamed")
        //        userLogin(email: "ashot@gmail.com", password: "123456")
        showMessageTimestampOnSwipeLeft = true
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        selfSender = createSender(userId: selfSenderId, name: selfSenderName, photoUrl: selfSenderPhotoUrl)
        messagesFromConversations(conversationId: conversationId) { [weak self] (downloadedMessages) in
            self?.messages = downloadedMessages
        }
    }
    
    func createStringFromDate() -> String {
        let date = Date()
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yy-MM-dd H:m:ss.SSSS Z"
        return dateFormater.string(from: date)
    }
    
    //    func convertStringToDate(stringDate: String) -> Date {
    //        let dateFormater = DateFormatter()
    //        dateFormater.locale = Locale(identifier: "en_US_POSIX")
    //        dateFormater.dateFormat = "yy-MM-dd H:m:ss.SSSS Z"
    //        let date = dateFormater.date(from: stringDate)!
    //        return date
    //    }
    
    func createSender(userId: String, name: String, photoUrl: String) -> Sender {
        Sender(photoUrl: photoUrl, senderId: userId, displayName: name)
    }
    
    func createMessage(convId: String, text: String) {
        let id = UUID()
        
        let date = createStringFromDate()
        
        referenceConversation.child(convId).child("messages").child(id.uuidString).updateChildValues(["date" : date, "messageId" : id.uuidString, "sender" : selfSender.senderId, "text": text])
        referenceConversation.child(convId).child("lastMessage").setValue(id.uuidString)
    }
    
    func messagesFromConversations(conversationId: String, completion: @escaping ([Message]) -> ()) {
        Database.database().reference().observe(.value) { [unowned self] (snapshot) in
            guard let value = snapshot.value, snapshot.exists() else { return }
            var arr = [Message]()
            
            let internetMessages = snapshot.childSnapshot(forPath: "conversations").childSnapshot(forPath: conversationId).childSnapshot(forPath: "messages")
            for message in internetMessages.children.allObjects as! [DataSnapshot] {
                let senderData = snapshot.childSnapshot(forPath: "users").childSnapshot(forPath: message.childSnapshot(forPath: "sender").value as! String).childSnapshot(forPath: "data")
                
                let senderName = senderData.childSnapshot(forPath: "name").value as! String
                let senderPhotoUrl = senderData.childSnapshot(forPath: "photoUrl").value as! String
                let senderId = message.childSnapshot(forPath: "sender").value as! String
                
                let sender = Sender(photoUrl: senderPhotoUrl, senderId: senderId, displayName: senderName)
                
                let id = message.childSnapshot(forPath: "messageId").value as! String
                let text = message.childSnapshot(forPath: "text").value as! String
                let stringDate = message.childSnapshot(forPath: "date").value as! String
                
                let dateFormater = DateFormatter()
                dateFormater.locale = Locale(identifier: "en_US_POSIX")
                dateFormater.dateFormat = "yy-MM-dd H:m:ss.SSSS Z"
                let date = dateFormater.date(from: stringDate)!
                
                let currentMessage = Message(sender: sender, messageId: id, sentDate: date, kind: .text(text))
                arr.append(currentMessage)
                
                completion(arr)
            }
        }
    }
    

}

// login/logout
extension DialogViewController {
    
    func userRegister(email: String, password: String, name: String) {
        DispatchQueue.main.async {
            Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                print(error)
                print(result)
                guard let id = result?.user.uid else { return }
                self.selfSenderId = id
                self.addUserInDatabase(email: email, id: id, name: name)
            }
        }
    }
    
    func userLogin(email: String, password: String) {
        group.enter()
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
            print("result \(result?.user.uid)")
            print("error = \(error)")
            
            self.selfSenderId = result?.user.uid
            self.getUserData(id: String((result?.user.uid)!))
            
            self.group.leave()
        }
    }
    
    func addUserInDatabase(email: String, id: String, name: String) {
        let usersReference = Database.database().reference().child("users")
        usersReference.child(id).child("data").updateChildValues(["email" : email, "name" : name])
    }
    
    func getUserData(id: String) {
        group.enter()
        referenceUsers.getData { (error, snapshot) in
            let userDataSnap = snapshot.childSnapshot(forPath: id).childSnapshot(forPath: "data")
            
            let name = userDataSnap.childSnapshot(forPath: "name").value as? String
            let photoUrl = userDataSnap.childSnapshot(forPath: "photoUrl").value as? String
            
            self.selfSenderName = name!
            self.selfSenderPhotoUrl = photoUrl ?? ""
            
            self.group.leave()
        }
    }
    
    func isPreviousMessageSameSender(indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return false}
        return messages[indexPath.section].sender.senderId == messages[indexPath.section - 1].sender.senderId
    }
    
    func isNextMessageSameSender(indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < messages.count else { return false}
        return messages[indexPath.section].sender.senderId == messages[indexPath.section + 1].sender.senderId
    }
}

extension DialogViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        
        let message = messages[indexPath.section]
        let sender = message.sender as? Sender
        guard let url = sender?.photoUrl, !sendersImageUrl.contains(url) else { return message }
        sendersImageUrl.insert(url)

        return message
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messages.count
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return .bubble
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isPreviousMessageSameSender(indexPath: indexPath) { return 0 }
        return 15
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(string: message.sender.displayName, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
    }
}

extension DialogViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        createMessage(convId: conversationId, text: text)
        messageInputBar.inputTextView.text = ""
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = isNextMessageSameSender(indexPath: indexPath)
        let sender = message.sender as! Sender
        let id = sender.senderId
 
        avatarView.image = downloadedPhoto[id]
    }
}

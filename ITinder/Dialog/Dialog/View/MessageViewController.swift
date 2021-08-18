import UIKit
import MessageKit
import InputBarAccessoryView

class MessageViewController: MessagesViewController {
    
    deinit {
        print("out")
    }

    var model: DialogFromFirebase!
    
    var selfSenderPhotoUrl: String!
    var selfSenderId: String!
    var selfSenderName: String!
    
    var companionId: String!
    
    var conversationId: String!
    
    private var selfSender: Sender!
    
    var downloadedPhoto = [String: UIImage]() {
        didSet {
//            messagesCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        model = DialogFromFirebase(conversationId: conversationId)
        model.delegate = self
        
        showMessageTimestampOnSwipeLeft = true
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        
        selfSender = Sender(photoUrl: selfSenderPhotoUrl, senderId: selfSenderId, displayName: selfSenderName)
    }
}

extension MessageViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return model.messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        model.messages.count
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return .bubble
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if model.isPreviousMessageSameSender(indexPath: indexPath) { return 0 }
        return 15
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(string: message.sender.displayName, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
    }
}

extension MessageViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        FirebaseService.createMessage(convId: conversationId, text: text, selfSender: selfSender, companionId: companionId)
        messageInputBar.inputTextView.text = ""
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = model.isNextMessageSameSender(indexPath: indexPath)
        let sender = message.sender as! Sender
        let senderId = sender.senderId
 
        avatarView.image = downloadedPhoto[senderId]
    }
}

extension MessageViewController: DialogDelegate {
    func getCompanionsId() -> [String : String] {
        return ["currentUserId": selfSenderId,
                "companionId": companionId]
    }
    
    func reloadMessages() {
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem()
    }
}

extension MessageViewController: MessageCellDelegate {
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        guard let messagesDataSourse = messagesCollectionView.messagesDataSource else { return }
        let message = messagesDataSourse.messageForItem(at: indexPath, in: messagesCollectionView)
        print(message.sender.senderId)
    }
}

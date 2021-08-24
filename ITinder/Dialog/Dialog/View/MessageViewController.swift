import UIKit
import MessageKit
import InputBarAccessoryView

class MessageViewController: MessagesViewController {
    
    deinit {
        print("out")
    }
    
    var model: DialogFromFirebase!
    
    var companionId: String!
    
    var currentUser: User!
    
    var conversationId: String!
    
    private var selfSender: Sender {
        Sender(photoUrl: currentUser.imageUrl, senderId: currentUser.identifier, displayName: currentUser.name)
    }
    
    var downloadedPhoto = [String: UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        model = DialogFromFirebase(conversationId: conversationId)
        model.delegate = self
        
        showMessageTimestampOnSwipeLeft = true
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        
        messageInputBar = CameraInputBarAccessoryView()
        messageInputBar.delegate = self
        messageInputBar.inputTextView.isUserInteractionEnabled = true
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
        ConversationService.createMessage(convId: conversationId, text: text, selfSender: selfSender, companionId: companionId)
        messageInputBar.inputTextView.text = ""
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = model.isNextMessageSameSender(indexPath: indexPath)
        guard let sender = message.sender as? Sender else { return }
        let senderId = sender.senderId
 
        avatarView.image = downloadedPhoto[senderId]
    }
}

extension MessageViewController: DialogDelegate {
    func getCompanionsId() -> [String : String] {
        return ["currentUserId": currentUser.identifier,
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
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if message.sender.senderId == selfSender.senderId {
            return Colors.blue
        } else {
            return .systemGray5
        }
    }
}

extension MessageViewController: CameraInputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith attachments: [AttachmentManager.Attachment]) {
        var images = [UIImage]()
        
        for item in attachments {
            
            if case .image(let image) = item {
                images.append(image)
            }
        }
        self.sendImageMessage(photo: images)
        inputBar.invalidatePlugins()
    }
    
    func sendImageMessage(photo: [UIImage]) {
        print(photo)
        ConversationService.createMessage(convId: conversationId, images: photo, selfSender: selfSender, companionId: companionId)
        messageInputBar.inputTextView.text = ""
    }
}

extension MessageViewController {
    func getSelf() -> UIViewController {
        return self
    }
    
    func showAlert(alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }
}

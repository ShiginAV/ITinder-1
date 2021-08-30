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
        
        configureViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func configureViews() {
        showMessageTimestampOnSwipeLeft = true
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        
        messageInputBar = CameraInputBarAccessoryView()
        messageInputBar.delegate = self
        
        scrollsToLastItemOnKeyboardBeginsEditing = true
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
        model.sendTextMessage(conversationId: conversationId, text: text, selfSender: selfSender, companionId: companionId)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = model.isNextMessageSameSender(indexPath: indexPath)
        guard let sender = message.sender as? Sender else { return }
        let senderId = sender.senderId
 
        avatarView.image = downloadedPhoto[senderId]
    }
}

extension MessageViewController: DialogDelegate {
    
    func popToRootViewController() {
        DispatchQueue.main.async {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func resetMessageInputBarText() {
        messageInputBar.inputTextView.text = ""
    }
    
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
            return Colors.primary
        } else {
            return .systemGray5
        }
    }
}

extension MessageViewController: CameraInputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith attachments: [AttachmentManager.Attachment]) {
        
        if inputBar.inputTextView.text != "" {
            model.sendTextMessage(conversationId: conversationId, text: inputBar.inputTextView.text, selfSender: selfSender, companionId: companionId)
        }
        
        for item in attachments {
            if case .image(let image) = item {
                model.sendImageMessage(conversationId: conversationId, selfSender: selfSender, photo: image, companionId: companionId)
            }
        }
        
        inputBar.invalidatePlugins()
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

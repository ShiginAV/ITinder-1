
import UIKit
import Firebase

struct CompanionStruct {
    var userName: String?
    var userId: String
    var conversationId: String
    var imageUrl: String?
}

class MatchesTableViewController: UITableViewController {
    
    let currentUserId = "QY9pgcIFrMc4FiQRqyzrEaWayQ53"
    let currentUserName = "Alex"
    let currentUserPhotoUrl = "https://firebasestorage.googleapis.com/v0/b/itinder-d319f.appspot.com/o/Avatars%2Fbrad1.jpg?alt=media&token=66eb65d3-a8a8-4ca5-8874-6f085ebd7f0d"
    
    var companions = [CompanionStruct]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var downloadedPhoto = [String : UIImage]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadPhoto(stringUrl: currentUserPhotoUrl, userId: currentUserId) { (id, data) in
            self.downloadedPhoto[id] = UIImage(data: data)
        }
        getConversations(userId: currentUserId) { [weak self] (conversations) in
            var conv = conversations
            for index in 0..<conv.count {
                self?.getUserData(id: conv[index].userId) { (name, photoUrl) in
                    conv[index].userName = name
                    conv[index].imageUrl = photoUrl
                    self?.companions.append(conv[index])
                    self?.downloadPhoto(stringUrl: photoUrl!, userId: conv[index].userId) { (id, data) in
                        self?.downloadedPhoto[id] = UIImage(data: data)
                    }
                }
            }
        }
    }
    
    func downloadPhoto(stringUrl: String, userId: String, completion: @escaping (String, Data) -> ()) {
        let reference = Storage.storage().reference(forURL: stringUrl)
        let megaBytes = Int64(1024 * 1024 * 10)
        reference.getData(maxSize: megaBytes) { (data, error) in
            guard let data = data else { return }
            completion(userId, data)
        }
    }
    
    func getConversations(userId: String, completion: @escaping ([CompanionStruct]) -> ()) {
        Database.database().reference().child("users").child(userId).child("conversations").observe(.value) { (snapshot) in
            var conversations = [CompanionStruct]()
            for conversation in snapshot.children.allObjects as! [DataSnapshot] {
                let userId = conversation.key
                let convId = conversation.value as! String
                conversations.append(CompanionStruct(userId: userId, conversationId: convId))
            }
            completion(conversations)
        }
    }
    
    func getUserData(id: String, completion: @escaping (_ name: String?, _ photoUrl: String?) -> ()) {
        Database.database().reference().child("users").getData { (error, snapshot) in
            let userDataSnap = snapshot.childSnapshot(forPath: id).childSnapshot(forPath: "data")
            
            let name = userDataSnap.childSnapshot(forPath: "name").value as? String
            let photoUrl = userDataSnap.childSnapshot(forPath: "photoUrl").value as? String
            completion(name, photoUrl)
        }
    }
    
    func getLastMessage(conversationId: String, completion: @escaping (String) -> ()) {
        Database.database().reference().child("conversations").child(conversationId).observe(.value) { (snapshot) in
            guard let lastMessageId = snapshot.childSnapshot(forPath: "lastMessage").value as? String else { return }
            guard let lastMessageText = snapshot.childSnapshot(forPath: "messages").childSnapshot(forPath: lastMessageId).childSnapshot(forPath: "text").value as? String else  { return }
            completion(lastMessageText)
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return companions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        let currentCompamion = companions[indexPath.row]
        cell.nameLable.text = currentCompamion.userName
        cell.avatarImage.image = downloadedPhoto[currentCompamion.userId]
        getLastMessage(conversationId: currentCompamion.conversationId) { (lastMessageText) in
            cell.lastMessage.text = lastMessageText
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dialogViewController = self.storyboard?.instantiateViewController(withIdentifier: "Dialog") as! DialogViewController
        
        let id = companions[indexPath.row].conversationId
        dialogViewController.title = companions[indexPath.row].userName
        dialogViewController.selfSenderId = self.currentUserId
        dialogViewController.selfSenderName = self.currentUserName
        dialogViewController.conversationId = id
        dialogViewController.selfSenderPhotoUrl = self.currentUserPhotoUrl
        
        dialogViewController.downloadedPhoto[currentUserId] = downloadedPhoto[currentUserId]
        dialogViewController.downloadedPhoto[id] = downloadedPhoto[id]
        
        self.navigationController?.pushViewController(dialogViewController, animated: true)
    }
}

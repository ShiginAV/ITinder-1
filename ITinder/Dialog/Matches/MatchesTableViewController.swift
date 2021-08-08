import UIKit

class MatchesTableViewController: UITableViewController {
    
    var model: MatchesFromFirebase!
    
    let currentUserId = "QY9pgcIFrMc4FiQRqyzrEaWayQ53"
    let currentUserName = "Alex"
    let currentUserPhotoUrl = "https://firebasestorage.googleapis.com/v0/b/itinder-d319f.appspot.com/o/Avatars%2Fbrad1.jpg?alt=media&token=66eb65d3-a8a8-4ca5-8874-6f085ebd7f0d"
    var lastMessage = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model = MatchesFromFirebase(currentUserPhotoUrl: currentUserPhotoUrl, currentUserId: currentUserId)
        model.delegate = self
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  model.companions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        let currentCompamion = model.companions[indexPath.row]
        
        cell.nameLable.text = currentCompamion.userName
        cell.avatarImage.image = model.downloadedPhoto[currentCompamion.userId]
        cell.lastMessage.text = model.lastMessages[currentCompamion.conversationId]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dialogViewController = self.storyboard?.instantiateViewController(withIdentifier: "Dialog") as! DialogViewController
        
        let convId = model.companions[indexPath.row].conversationId
        dialogViewController.title = model.companions[indexPath.row].userName
        dialogViewController.selfSenderId = self.currentUserId
        dialogViewController.selfSenderName = self.currentUserName
        dialogViewController.conversationId = convId
        dialogViewController.selfSenderPhotoUrl = self.currentUserPhotoUrl
        
        dialogViewController.downloadedPhoto[currentUserId] = model.downloadedPhoto[currentUserId]
        dialogViewController.downloadedPhoto[convId] = model.downloadedPhoto[convId]
        
        self.navigationController?.pushViewController(dialogViewController, animated: true)
    }
}

extension MatchesTableViewController: MatchesDelegate {
    func sendLastMessage(lastMessage: String) {
        self.lastMessage = lastMessage
    }
    
    func reloadTable() {
        tableView.reloadData()
    }
}

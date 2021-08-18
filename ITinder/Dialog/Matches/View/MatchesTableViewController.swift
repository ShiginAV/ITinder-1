import UIKit

class MatchesViewController: UIViewController {
    
    var model: MatchesFromFirebase!

    var currentUserId: String!
    var currentUserName: String!
    var currentUserPhotoUrl: String!
    
    @IBOutlet weak var matchesCollectionView: UICollectionView!
    @IBOutlet weak var matchesTableView: UITableView!
    
    @IBOutlet weak var newMatchesLable: UILabel!
    @IBOutlet weak var messagesLable: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAllHidden()
        
        let user = 3
        
        switch user {
        case 1:
            currentUserId = "QY9pgcIFrMc4FiQRqyzrEaWayQ53"
            currentUserName = "Alex"
            currentUserPhotoUrl = "https://firebasestorage.googleapis.com/v0/b/itinder-d319f.appspot.com/o/Avatars%2Fbrad1.jpg?alt=media&token=66eb65d3-a8a8-4ca5-8874-6f085ebd7f0d"
        case 2:
            currentUserId = "2VXr50Su49fSS13VdF6cqBHAMVq2"
            currentUserName = "Andrey"
            currentUserPhotoUrl = "https://firebasestorage.googleapis.com/v0/b/itinder-d319f.appspot.com/o/Avatars%2FgsjHaM2Wqz0.jpg?alt=media&token=c669e780-2558-4b54-b571-f30a29f26ab9"
        case 3:
            currentUserId = "userTestId3"
            currentUserName = "Andrey"
            currentUserPhotoUrl = "https://firebasestorage.googleapis.com/v0/b/itinder-d319f.appspot.com/o/Avatars%2FJYo_0l-Uhlo.jpg?alt=media&token=da994315-5a1e-4c14-b9b2-60def878dc7a"
        default:
            return
        }
        
        model = MatchesFromFirebase(currentUserPhotoUrl: currentUserPhotoUrl, currentUserId: currentUserId)
        model.delegate = self
        
        navigationController?.navigationBar.isHidden = true

        matchesTableView.delegate = self
        matchesTableView.dataSource = self
        
        matchesCollectionView.delegate = self
        matchesCollectionView.dataSource = self
        
        configureEmptyLines()
        configureNotificationCenter()
    }
    
    func setAllHidden() {
        activityIndicator.startAnimating()
        let status = true
        matchesTableView.isHidden = status
        matchesCollectionView.isHidden = status
        newMatchesLable.isHidden = status
        messagesLable.isHidden = status
    }
    
    func configureNotificationCenter() {
        notificationCenter.delegate = self
        
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            guard granted else { return }
            self.notificationCenter.getNotificationSettings { (settings) in
                print(settings)
                guard settings.authorizationStatus == .authorized else { return }
            }
        }
    }
    
    func configureEmptyLines() {
        let buttomView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 100))
        matchesTableView.tableFooterView = buttomView
    }
    
    func configereNonEmptyLines() {
        let buttomView = createLineView()
        matchesTableView.tableFooterView = buttomView
        
        let topView = createLineView()
        matchesTableView.tableHeaderView = topView
    }
    
    func createLineView() -> UIView {
        let newView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 0.5))
        newView.backgroundColor = .lightGray
        return newView
    }
}
    // MARK: - Table view data source
extension MatchesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if model.oldCompanions.count != 0 {
            return model.oldCompanions.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        if model.oldCompanions.count != 0 {
            matchesTableView.allowsSelection = true
            let currentCompamion = model.oldCompanions[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
            
            cell.fill(avatarImage: model.downloadedPhoto[currentCompamion.userId], name: currentCompamion.userName, lastMessage: model.lastMessages[currentCompamion.conversationId], lastMessageWasRead: currentCompamion.lastMessageWasRead)
            return cell
        } else {
            matchesTableView.allowsSelection = false
            let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if model.oldCompanions.count != 0 {
            matchesTableView.deselectRow(at: indexPath, animated: true)
            createDialog(companion: model.oldCompanions[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let companionId = model.oldCompanions[indexPath.row].userId
            let conversationId = model.oldCompanions[indexPath.row].conversationId
            model.deleteMatch(currentUserId: currentUserId, companionId: companionId, conversationId: conversationId)
            
        }
    }
    
    func createDialog (companion: CompanionStruct) {
        let dialogViewController = self.storyboard?.instantiateViewController(withIdentifier: "Dialog") as! DialogViewController
        
        let companionId = companion.userId
        let convId = companion.conversationId
        
        dialogViewController.companion = companion
        dialogViewController.companionPhoto = model.downloadedPhoto[companionId]
        
        dialogViewController.messageViewController.selfSenderId = self.currentUserId
        dialogViewController.messageViewController.selfSenderName = self.currentUserName
        dialogViewController.messageViewController.selfSenderPhotoUrl = self.currentUserPhotoUrl
        dialogViewController.messageViewController.conversationId = convId
        
        dialogViewController.messageViewController.downloadedPhoto[currentUserId] = model.downloadedPhoto[currentUserId]
        dialogViewController.messageViewController.downloadedPhoto[companionId] = model.downloadedPhoto[companionId]
        
        dialogViewController.messageViewController.companionId = companionId
        
        self.navigationController?.pushViewController(dialogViewController, animated: true)
    }
}

extension MatchesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if model.newCompanions.count != 0 {
            return model.newCompanions.count
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if model.newCompanions.count != 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! CollectionViewCell
            
            let currentCompamion = model.newCompanions[indexPath.row]
            
            cell.fill(avatarImage: model.downloadedPhoto[currentCompamion.userId], name: currentCompamion.userName)
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptyCollectionCell", for: indexPath)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if model.newCompanions.count != 0 {
            createDialog(companion: model.newCompanions[indexPath.row])
        }
    }
}

extension MatchesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: matchesCollectionView.bounds.width / 4, height: matchesCollectionView.bounds.height - 10)
            }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
}

extension MatchesViewController: MatchesDelegate {
    func setAllVisible() {
        let status = false
        matchesTableView.isHidden = status
        matchesCollectionView.isHidden = status
        newMatchesLable.isHidden = status
        messagesLable.isHidden = status
        
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    func sendNotification(request: UNNotificationRequest) {
        notificationCenter.add(request) { (error) in
            print(error)
        }
    }
    
    func reloadTable() {
        matchesTableView.reloadData()
        matchesCollectionView.reloadData()
        configereNonEmptyLines()
    }
}

extension MatchesViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
        print(#function)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(#function)
    }
}

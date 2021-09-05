//
//  EditСharacteristicView.swift
//  ITinder
//
//  Created by Alexander on 08.08.2021.
//

import UIKit

protocol EditСharacteristicDelegate: AnyObject {
    func textDidChange(type: СharacteristicType, text: String?)
    func textDidEndEditing(type: СharacteristicType, text: String?)
}

final class EditСharacteristicView: UIView {
    
    weak var delegate: EditСharacteristicDelegate?
    
    var text: String? {
        didSet { textField.text = text }
    }
    
    init(type: СharacteristicType) {
        self.type = type
        super.init(frame: .zero)
        configure()
        configureDatePicker()
        fill()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let type: СharacteristicType
    
    private let imageIcon = UIImageView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .darkGray
        return label
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textField.textColor = .black
        textField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        textField.addTarget(self, action: #selector(textDidEndEditing(_:)), for: .editingDidEnd)
        return textField
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        if #available(iOS 14, *) {
            picker.preferredDatePickerStyle = .wheels
        }
        let year: Double = 60 * 60 * 24 * 365
        let years98 = year * 98.0
        let years12 = year * 12.0
        picker.minimumDate = Date(timeInterval: -years98, since: Date())
        picker.maximumDate = Date(timeInterval: -years12, since: Date())
        picker.backgroundColor = .white
        return picker
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    
    private func configure() {
        [imageIcon, titleLabel, textField].forEach { subview in
            subview.translatesAutoresizingMaskIntoConstraints = false
            addSubview(subview)
        }
        NSLayoutConstraint.activate([
            imageIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageIcon.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageIcon.widthAnchor.constraint(equalToConstant: 40),
            imageIcon.heightAnchor.constraint(equalTo: imageIcon.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: imageIcon.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            textField.leadingAnchor.constraint(equalTo: imageIcon.trailingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func fill() {
        imageIcon.image = type.imageIcon
        titleLabel.text = type.text
        textField.placeholder = type.placeholder
    }
    
    private func configureDatePicker() {
        guard type == .birthDate else { return }
        
        textField.inputView = datePicker
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44.0))
        let emptyItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(datePickerDoneButtonDidTap))
        doneButton.tintColor = Colors.primary
        toolBar.setItems([emptyItem, doneButton], animated: true)
        textField.inputAccessoryView = toolBar
    }
    
    @objc private func textDidChange(_ sender: UITextField) {
        delegate?.textDidChange(type: type, text: sender.text)
    }
    
    @objc private func textDidEndEditing(_ sender: UITextField) {
        delegate?.textDidEndEditing(type: type, text: sender.text)
    }
    
    @objc func datePickerDoneButtonDidTap() {
        textField.text = dateFormatter.string(from: datePicker.date)
        endEditing(true)
    }
}

enum СharacteristicType: CaseIterable {
    case name
    case position
    case birthDate
    case company
    case education
    case city
    case employment
    
    var text: String {
        switch self {
        case .name: return "Имя"
        case .position: return "Должность"
        case .birthDate: return "Дата рождения"
        case .company: return "Компания"
        case .education: return "Образование"
        case .city: return "Город"
        case .employment: return "Занятость"
        }
    }
    
    var imageIcon: UIImage? {
        switch self {
        case .name: return UserProfileIcons.nameIcon.image
        case .position: return UserProfileIcons.positionIcon.image
        case .birthDate: return UserProfileIcons.birthDateIcon.image
        case .company: return UserProfileIcons.companyIcon.image
        case .education: return UserProfileIcons.educationIcon.image
        case .city: return UserProfileIcons.cityIcon.image
        case .employment: return UserProfileIcons.employmentIcon.image
        }
    }
    
    var placeholder: String {
        switch self {
        case .name: return "Добавить имя"
        case .position: return "Добавить должность"
        case .birthDate: return "Добавить дату рождения"
        case .company: return "Добавить компанию"
        case .education: return "Добавить информацию об образовании"
        case .city: return "Добавить город"
        case .employment: return "Добавить занятость"
        }
    }
}

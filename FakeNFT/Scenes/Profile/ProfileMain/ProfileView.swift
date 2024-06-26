//
//  ProfileView.swift
//  FakeNFT
//
//  Created by Ann Goncharova on 05.11.2023.
//

import Kingfisher
import UIKit

final class ProfileView: UIView {
    private var viewModel: ProfileViewModelProtocol
    private var viewController: ProfileViewController
    
    private let assetNameLabel: [String] = [
        L10n.Profile.myNFT,
        L10n.Profile.nftFavorites,
        L10n.Profile.aboutDeveloper
    ]
    
    private lazy var assetValue: [String?] = [
        "\(viewModel.nfts?.count ?? 0)",
        "\(viewModel.likes?.count ?? 0)",
        nil
    ]
    
    private lazy var avatarImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Asset.profile.image
        imageView.layer.cornerRadius = 35
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .headline22
        label.textColor = .textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .caption13
        label.textColor = .textPrimary
        label.numberOfLines = 0
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 18
        label.attributedText = NSAttributedString(
            string: "",
            attributes: [.kern: 0.08, NSAttributedString.Key.paragraphStyle: paragraphStyle]
        )
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var websiteLabel: UILabel = {
        let label = UILabel()
        label.font = .caption15
        label.textColor = .blue
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(websiteDidTap))
        label.attributedText = NSAttributedString(string: "", attributes: [.kern: 0.24])
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tapAction)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var profileAssetsTable: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.allowsMultipleSelection = false
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.register(ProfileAssetsCell.self)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    init(frame: CGRect, viewModel: ProfileViewModelProtocol, viewController: ProfileViewController) {
        self.viewModel = viewModel
        self.viewController = viewController
        super.init(frame: .zero)
        
        self.backgroundColor = .screenBackground
        setupConstraints()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(likesUpdated),
            name: NSNotification.Name(rawValue: "likesUpdated"),
            object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func websiteDidTap(_ sender: UITapGestureRecognizer) {
        viewController.present(WebsiteViewController(websiteURL: websiteLabel.text), animated: true)
    }
    
    @objc private func likesUpdated(notification: Notification) {
        guard let likesUpdated = notification.object as? Int else { return }
        let cell = profileAssetsTable.cellForRow(at: [0, 1]) as? ProfileAssetsCell
        cell?.setAssets(label: nil, value: "(\(likesUpdated))")
    }
    
    func updateViews(
        avatarURL: URL?,
        userName: String?,
        description: String?,
        website: String?,
        nftCount: String?,
        likesCount: String?
    ) {
        avatarImage.kf.setImage(
            with: avatarURL,
            placeholder: Asset.profile.image,
            options: [.processor(RoundCornerImageProcessor(cornerRadius: 35))])
        nameLabel.text = userName
        descriptionLabel.text = description
        websiteLabel.text = website
        
        let myNFTCell = profileAssetsTable.cellForRow(at: [0, 0]) as? ProfileAssetsCell
        myNFTCell?.setAssets(label: nil, value: nftCount)
        
        let likesCell = profileAssetsTable.cellForRow(at: [0, 1]) as? ProfileAssetsCell
        likesCell?.setAssets(label: nil, value: likesCount)
    }
    
    private func setupConstraints() {
        [
            avatarImage,
            nameLabel,
            descriptionLabel,
            websiteLabel,
            profileAssetsTable
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            avatarImage.heightAnchor.constraint(equalToConstant: 70),
            avatarImage.widthAnchor.constraint(equalToConstant: 70),
            avatarImage.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            avatarImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            nameLabel.topAnchor.constraint(equalTo: avatarImage.topAnchor, constant: 21),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImage.trailingAnchor, constant: 16),
            
            descriptionLabel.topAnchor.constraint(equalTo: avatarImage.bottomAnchor, constant: 20),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 72),
            descriptionLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            websiteLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            websiteLabel.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),
            
            profileAssetsTable.topAnchor.constraint(equalTo: websiteLabel.bottomAnchor, constant: 40),
            profileAssetsTable.heightAnchor.constraint(equalToConstant: 54 * 3),
            profileAssetsTable.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            profileAssetsTable.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
}

extension ProfileView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assetNameLabel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ProfileAssetsCell = tableView.dequeueReusableCell()
        cell.backgroundColor = .screenBackground
        cell.setAssets(label: assetNameLabel[indexPath.row], value: assetValue[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
}

extension ProfileView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let controller = MyNFTViewController(nftIDs: viewModel.nfts ?? [], likedIDs: viewModel.likes ?? [])
            viewController.navigationController?.pushViewController(controller, animated: true)
        case 1:
            let controller = FavoritesViewController(likedIDs: viewModel.likes ?? [])
            viewController.navigationController?.pushViewController(controller, animated: true)
        case 2:
            let controller = DevelopersViewController()
            viewController.navigationController?.pushViewController(controller, animated: true)
        default:
            break
        }
    }
}

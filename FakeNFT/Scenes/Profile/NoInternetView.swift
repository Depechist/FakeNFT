//
//  NoInternetView.swift
//  FakeNFT
//
//  Created by Ann Goncharova on 19.11.2023.
//

import UIKit

final class NoInternetView: UIView {
    // лейбл показывается при отсутствии интернета
    private lazy var noInternetLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Нет интернета"
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = .black
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        self.backgroundColor = .white
        addEmptyLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addEmptyLabel() {
        addSubview(noInternetLabel)
        
        NSLayoutConstraint.activate([
            noInternetLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            noInternetLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])

    }
}

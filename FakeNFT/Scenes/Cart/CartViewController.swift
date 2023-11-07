//
//  ShoppingCartViewController.swift
//  FakeNFT
//
//  Created by Вадим Шишков on 04.11.2023.
//
import Combine
import SnapKit
import UIKit

final class CartViewController: UIViewController {
    private let cartView = CartView()
    private let viewModel: CartViewModel
    private var cancellables: Set<AnyCancellable> = []
    private var rightBarItem: UIBarButtonItem?
    
    init(servicesAssembly: ServicesAssembly) {
        viewModel = CartViewModel(servicesAssembly: servicesAssembly)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = cartView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        viewModel.loadOrder()
        showLoading()
    }
    
    private func setupUI() {
        let rightBarItem = UIBarButtonItem(
            image: Asset.sortButton.image,
            style: .plain,
            target: self,
            action: #selector(sortNFT)
        )
        rightBarItem.tintColor = .textPrimaryInvert
        navigationItem.rightBarButtonItem = rightBarItem
        self.rightBarItem = rightBarItem
        
        cartView.tableView.dataSource = self
    }
    
    private func bind() {
        viewModel.$nfts.sink { [weak self] nfts in
            guard let self = self else { return }
            hideLoading()
            
            DispatchQueue.main.async { [weak self] in
                self?.cartView.tableView.reloadData()
                self?.cartView.countLabel.text = "\(nfts.count) NFT"
                let price = nfts.reduce(0) { partialResult, nft in
                    partialResult + nft.price
                }
                self?.cartView.priceLabel.text = String(format: "%.2f", price) + " ETH"
                
                self?.rightBarItem?.tintColor = nfts.isEmpty
                ? .textPrimaryInvert
                : .borderColor
                
                self?.cartView.bottomView.isHidden = nfts.isEmpty ? true : false
            }
        }
        .store(in: &cancellables)
        
        viewModel.$error.sink { [weak self] error in
            self?.hideLoading()
            
            if let error = error {
                let model = ErrorModel(
                    message: L10n.Error.network,
                    actionText: L10n.Error.repeat
                ) { [weak self] in
                    self?.viewModel.loadOrder()
                }
                self?.showError(model)
                print(error.localizedDescription)
            }
        }
        .store(in: &cancellables)
        
        viewModel.$emptyState.sink { [weak self] emptyState in
            guard let self = self, let emptyState = emptyState else { return }
            if emptyState {
                cartView.emptyStateLabel.isHidden = false
                rightBarItem?.tintColor = .textPrimaryInvert
                hideLoading()
            } else {
                cartView.emptyStateLabel.isHidden = true
                
            }
        }
        .store(in: &cancellables)
    }

    @objc private func sortNFT() {}
}

extension CartViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        viewModel.nfts.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = cartView.tableView.dequeueReusableCell() as CartCell
        cell.setup(with: viewModel.nfts[indexPath.row])
        return cell
    }
}

extension CartViewController: ErrorView {}
extension CartViewController: LoadingView {}

import Foundation

// MARK: - Protocol

protocol NftDetailPresenter {
    func viewDidLoad()
}

// MARK: - State

enum NftDetailState {
    case initial, loading, failed(Error), data(Nft)
}

final class NftDetailPresenterImpl: NftDetailPresenter {
    // MARK: - Properties

    weak var view: NftDetailView?
    private let input: NftDetailInput
    private let service: NftService
    private var state = NftDetailState.initial {
        didSet {
            stateDidChanged()
        }
    }

    // MARK: - Init

    init(input: NftDetailInput, service: NftService) {
        self.input = input
        self.service = service
    }

    // MARK: - Functions

    func viewDidLoad() {
        state = .loading
    }

    private func stateDidChanged() {
        switch state {
        case .initial:
            assertionFailure("can't move to initial state")
        case .loading:
            UIBlockingProgressHUD.show()
            loadNft()
        case .data(let nft):
            UIBlockingProgressHUD.dismiss()
            let cellModels = nft.images.map { NftDetailCellModel(url: $0) }
            view?.displayCells(cellModels)
        case .failed(let error):
            let errorModel = makeErrorModel(error)
            UIBlockingProgressHUD.dismiss()
            view?.showError(errorModel)
        }
    }

    private func loadNft() {
        service.loadNft(id: input.id) { [weak self] result in
            switch result {
            case .success(let nft):
                self?.state = .data(nft)
            case .failure(let error):
                self?.state = .failed(error)
            }
        }
    }

    private func makeErrorModel(_ error: Error) -> ErrorModel {
        let message: String
        switch error {
        case is NetworkClientError:
            message = L10n.Error.network
        default:
            message = L10n.Error.unknown
        }

        let actionText = L10n.Error.repeat
        return ErrorModel(message: message, actionText: actionText) { [weak self] in
            self?.state = .loading
        }
    }
}

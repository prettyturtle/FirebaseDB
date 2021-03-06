//
//  ItemListViewController.swift
//  FirebaseDB
//
//  Created by yc on 2022/03/13.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ItemListViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    private let itemTableView = UITableView()
    private let refreshControl = UIRefreshControl()
    let deleteItem = PublishSubject<Item>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupAttribute()
    }
    
    func bind(viewModel: ItemListViewModel) {
        refreshControl.rx.controlEvent(.valueChanged)
            .bind(to: viewModel.refreshBegin)
            .disposed(by: disposeBag)
        itemTableView.rx.itemSelected
            .map { $0.row }
            .bind(to: viewModel.selectedRow)
            .disposed(by: disposeBag)
        deleteItem        
            .map(viewModel.FIRManager.deleteItem(item:))
            .bind(to: viewModel.refreshBegin)
            .disposed(by: disposeBag)
        
        viewModel.fetchUploadedItems()
        viewModel.itemList
            .bind(to: itemTableView.rx.items) { tv, row, data in
                guard let cell = tv.dequeueReusableCell(
                    withIdentifier: ItemListTableViewCell.identifier,
                    for: IndexPath(row: row, section: 0)
                ) as? ItemListTableViewCell else { return UITableViewCell() }
                
                cell.delegate = self
                cell.item = data
                cell.setupView()
                cell.selectionStyle = .none
                
                return cell
            }
            .disposed(by: disposeBag)
        viewModel.refreshEnd
            .subscribe(onNext: { [weak self] _ in
                self?.refreshControl.endRefreshing()
            })
            .disposed(by: disposeBag)
        viewModel.moveToDetailVC
            .subscribe(onNext: { [weak self] item in
                let itemDetailVC = ItemDetailViewController(item: item)
                itemDetailVC.bind(viewModel: viewModel.itemDetailViewModel)
                self?.show(itemDetailVC, sender: nil)
            })
            .disposed(by: disposeBag)
    }
}

extension ItemListViewController: ItemListTableViewCellDelegate {
    func didLongPress(item: Item) {
        let alertController = UIAlertController(
            title: "???????",
            message: nil,
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(
            title: "CANCEL",
            style: .cancel
        )
        let okAction = UIAlertAction(
            title: "OK",
            style: .default
        ) { [weak self] action in
            self?.deleteItem.onNext(item)
        }
        [
            cancelAction,
            okAction
        ].forEach { alertController.addAction($0) }
        present(alertController, animated: true)
    }
}

private extension ItemListViewController {
    func setupAttribute() {
        title = "?????? ??????"
        itemTableView.refreshControl = refreshControl
        itemTableView.rowHeight = 150.0
        itemTableView.register(
            ItemListTableViewCell.self,
            forCellReuseIdentifier: ItemListTableViewCell.identifier
        )
    }
    func setupLayout() {
        view.addSubview(itemTableView)
        itemTableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

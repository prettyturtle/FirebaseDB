//
//  ItemListViewController.swift
//  FirebaseDB
//
//  Created by yc on 2022/03/13.
//

import UIKit
import SnapKit
import RxSwift

class ItemListViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    let itemListViewModel = ItemListViewModel()
    
    private let itemTableView = UITableView()
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupAttribute()
        bind(viewModel: itemListViewModel)
    }
    
    func bind(viewModel: ItemListViewModel) {
        refreshControl.rx.controlEvent(.valueChanged)
            .bind(to: viewModel.refreshBegin)
            .disposed(by: disposeBag)
        itemTableView.rx.itemSelected
            .map { $0.row }
            .bind(to: viewModel.selectedRow)
            .disposed(by: disposeBag)
        
        viewModel.itemList
            .bind(to: itemTableView.rx.items) { tv, row, data in
                guard let cell = tv.dequeueReusableCell(
                    withIdentifier: ItemListTableViewCell.identifier,
                    for: IndexPath(row: row, section: 0)
                ) as? ItemListTableViewCell else { return UITableViewCell() }
                
                cell.setupView(item: data)
                
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
                self?.show(itemDetailVC, sender: nil)
            })
            .disposed(by: disposeBag)
    }
}

private extension ItemListViewController {
    func setupAttribute() {
        title = "상품 목록"
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

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
import Firebase

class ItemListViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    let itemListViewModel = ItemListViewModel()
    
    private let itemTableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupAttribute()
        bind(viewModel: itemListViewModel)
    }
    
    func bind(viewModel: ItemListViewModel) {
        viewModel.itemList
            .bind(to: itemTableView.rx.items) { tv, row, data in
                let cell = tv.dequeueReusableCell(
                    withIdentifier: "ItemListTableViewCell",
                    for: IndexPath(row: row, section: 0)
                )
                cell.textLabel?.text = data.id
                return cell
            }
            .disposed(by: disposeBag)
    }
}

private extension ItemListViewController {
    func setupAttribute() {
        itemTableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "ItemListTableViewCell"
        )
    }
    func setupLayout() {
        view.addSubview(itemTableView)
        itemTableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

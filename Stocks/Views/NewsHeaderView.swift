//
//  NewsHeaderView.swift
//  Stocks
//
//  Created by Nodirbek on 01/06/22.
//

import UIKit

protocol NewsHeaderViewDelegate: AnyObject {
    func newsHeaderViewDidTapAddButton(_ headerView: NewsHeaderView)
}

class NewsHeaderView: UITableViewHeaderFooterView {

    static let identifier = "NewsHeaderView"
    static let prefferedHeight: CGFloat = 70
    weak var delegate: NewsHeaderViewDelegate?
    
    struct ViewModel {
        let title: String
        let shouldShowAddButton: Bool
    }
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .boldSystemFont(ofSize: 32)
        return label
    }()
    
    lazy var button: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.setTitle("+ Watchlist", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()
    
    //MARK: -Init
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubviews(label, button)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 14,
                             y: 0,
                             width: contentView.width - 28,
                             height: contentView.height)
        button.sizeToFit()
        button.frame = CGRect(x: contentView.width - button.width - 16,
                              y: (contentView.height - button.height)/2,
                              width: button.width + 8,
                              height: button.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }
        
    public func configure(with viewModel: ViewModel){
        label.text = viewModel.title
        button.isHidden = !viewModel.shouldShowAddButton
    }
    
    @objc private func didTapButton(){
        //call delegate
        delegate?.newsHeaderViewDidTapAddButton(self)
    }
}

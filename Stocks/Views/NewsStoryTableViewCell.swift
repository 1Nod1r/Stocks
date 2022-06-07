//
//  NewsStoryTableViewCell.swift
//  Stocks
//
//  Created by Nodirbek on 03/06/22.
//

import UIKit
import SnapKit
import SDWebImage

class NewsStoryTableViewCell: UITableViewCell {
    static let id = "NewsStoryTableViewCell"
    static let prefferedHeight:CGFloat = 140
    
    struct ViewModel {
        let source: String
        let headline: String
        let dateString: String
        let imageUrl: URL?
        
        init(model: NewsStory){
            self.source = model.source
            self.headline = model.headline
            self.dateString = .string(from: model.datetime)
            self.imageUrl = URL(string: model.image)
        }
    }
    
    // Source
    private let sourceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    // Headline
    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .medium)
        label.numberOfLines = 0
        return label
    }()
    // Date
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    // Image
    
    private let storyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .tertiarySystemBackground
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .secondarySystemBackground
        addSubviews(sourceLabel, headlineLabel, dateLabel, storyImageView)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        sourceLabel.text = nil
        headlineLabel.text = nil
        dateLabel.text = nil
        storyImageView.image = nil
    }
    
    private func setupUI(){
        storyImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.width.equalTo(contentView.snp.height)
        }
        
        sourceLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(14)
            make.right.equalTo(storyImageView.snp.left)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-15)
            make.left.equalToSuperview().offset(10)
            make.right.equalTo(storyImageView.snp.left)
            make.height.equalTo(17)
        }
        
        headlineLabel.snp.makeConstraints { make in
            make.top.equalTo(sourceLabel.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(10)
            make.right.equalTo(storyImageView.snp.left)
            make.bottom.equalTo(dateLabel.snp.top).offset(-5)
        }
        
    }
    
    public func configure(with viewModel: ViewModel){
        headlineLabel.text = viewModel.headline
        sourceLabel.text = viewModel.source
        dateLabel.text = viewModel.dateString
        storyImageView.sd_setImage(with: viewModel.imageUrl)
        
        // Manually set image
        //storyImageView.setImage(with: viewModel.imageUrl)
    }
    
}

//
//  WatchListTableViewCell.swift
//  Stocks
//
//  Created by Nodirbek on 03/06/22.
//

import UIKit
import SnapKit

class WatchListTableViewCell: UITableViewCell {
    
    static let id = "WatchListTableViewCell"
    
    static let prefferedHeight: CGFloat = 60
    
    struct ViewModel {
        let symbol: String
        let companyName: String
        let price: String //formatted
        let changeColor: UIColor // red or green
        let changePercentage: String // formatted
        let chartViewModel: StockChartView.ViewModel
    }
    
    // Symbol label
    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .medium)
        return label
    }()
    
    // Company label
    
    private let companyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .regular)
        return label
    }()
    
    // Price label
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    // Change in price label
    
    private let changeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.layer.cornerRadius = 5
        label.clipsToBounds = true
        return label
    }()
    
    // Minichart view
    
    private let miniChartView: StockChartView = {
        let chart = StockChartView()
        chart.clipsToBounds = true
        chart.isUserInteractionEnabled = false
        return chart
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
         
        addSubviews(symbolLabel, companyLabel, priceLabel, changeLabel, miniChartView)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        symbolLabel.text = nil
        companyLabel.text = nil
        priceLabel.text = nil
        changeLabel.text = nil
        miniChartView.reset()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        symbolLabel.sizeToFit()
        companyLabel.sizeToFit()
        priceLabel.sizeToFit()
        changeLabel.sizeToFit()
    }
    
    public func configure(with viewModel: ViewModel){
        symbolLabel.text = viewModel.symbol
        companyLabel.text = viewModel.companyName
        priceLabel.text = viewModel.price
        changeLabel.text = viewModel.changePercentage
        changeLabel.backgroundColor = viewModel.changeColor
        miniChartView.configure(with: viewModel.chartViewModel)
    }
    
    private func setupUI(){
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(15)
            make.width.equalTo(50)
        }
        
        miniChartView.snp.makeConstraints { make in
            make.right.equalTo(priceLabel.snp.left).offset(-20)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.width.equalTo(140)
        }
        
        changeLabel.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(15)
            make.left.equalTo(miniChartView.snp.right).offset(20)
        }
        
        symbolLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(10)
            make.height.equalTo(20)
            make.right.equalTo(miniChartView.snp.left).offset(-5)
        }
        
        companyLabel.snp.makeConstraints { make in
            make.top.equalTo(symbolLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.right.equalTo(miniChartView.snp.left).offset(-5)
        }
    }
}

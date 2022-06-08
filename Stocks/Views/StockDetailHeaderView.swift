//
//  StockDetailHeaderView.swift
//  Stocks
//
//  Created by Nodirbek on 08/06/22.
//

import UIKit

class StockDetailHeaderView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private var metricViewModels: [MetricCollectionViewCell.ViewModel] = []
    
    // Subviews
    
    // ChartView
    
    private let chartView = StockChartView()
    
    // CollectionView
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(MetricCollectionViewCell.self, forCellWithReuseIdentifier: MetricCollectionViewCell.id)
        collection.backgroundColor = .secondarySystemBackground
        return collection
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubviews(chartView, collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        chartView.frame = CGRect(x: 0, y: 0, width: width, height: height-100)
        collectionView.frame = CGRect(x: 0, y: height-100, width: width, height: 100)
    }
    
    public func configure(chartViewModel: StockChartView.ViewModel, metricViewModels: [MetricCollectionViewCell.ViewModel]){
        self.metricViewModels = metricViewModels
        collectionView.reloadData()
    }
    
    // MARK: CollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return metricViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let viewMoel = metricViewModels[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MetricCollectionViewCell.id, for: indexPath) as? MetricCollectionViewCell else { return UICollectionViewCell() }
        cell.configure(with: viewMoel)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: width/2, height: 100/3)
    }
}

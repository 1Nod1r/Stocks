//
//  StockChartView.swift
//  Stocks
//
//  Created by Nodirbek on 04/06/22.
//

import UIKit

class StockChartView: UIView {
    
    struct ViewModel {
        let data: [Double]
        let showLegend: Bool
        let showAxis: Bool
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    public func reset(){
        
    }
    
    public func configure(with viewModel: ViewModel){
        
    }
}

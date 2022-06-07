//
//  StockDetailsViewController.swift
//  Stocks
//
//  Created by Nodirbek on 23/05/22.
//

import UIKit

class StockDetailsViewController: UIViewController {
    //Symbol, company name, any chart data we may have
    
    // MARK: Properties
    
    private let symbol: String
    private let companyName: String
    private var candleStickData: [CandleStick]
    
    // MARK: Init
    
    init(symbol: String, companyName: String, candleStickData: [CandleStick] = []){
        self.symbol = symbol
        self.companyName = companyName
        self.candleStickData = candleStickData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }

}

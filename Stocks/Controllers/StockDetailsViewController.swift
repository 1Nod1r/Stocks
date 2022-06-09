//
//  StockDetailsViewController.swift
//  Stocks
//
//  Created by Nodirbek on 23/05/22.
//

import UIKit
import SafariServices

class StockDetailsViewController: UIViewController {
    
    // MARK: Properties
    
    private let symbol: String
    private let companyName: String
    private var candleStickData: [CandleStick]
    private var stories: [NewsStory] = []
    private var metrics: Metrics?
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(NewsStoryTableViewCell.self, forCellReuseIdentifier: NewsStoryTableViewCell.id)
        table.register(NewsHeaderView.self, forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier)
        return table
    }()
    
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
        title = companyName
        view.backgroundColor = .systemBackground
        setupCloseButton()
        setupTable()
        fetchFinancialData()
        fetchNews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    // MARK: Private
    
    private func setupCloseButton(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                            target: self,
                                                            action: #selector(didTapClose))
    }
    
    @objc private func didTapClose(){
        dismiss(animated: true)
    }
    
    private func setupTable(){
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: (view.width * 0.7) + 100))
    }
    
    private func fetchFinancialData(){
        let group = DispatchGroup()
        // Fetch candle sticks if needed
        if candleStickData.isEmpty {
            group.enter()
            APICaller.shared.marketData(for: symbol) { [weak self] result in
                defer {
                    group.leave()
                }
                switch result {
                case .success(let response):
                    self?.candleStickData = response.candleStick
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        // Fetch financial metrics
        group.enter()
        APICaller.shared.financialMetrics(for: symbol) {[weak self] result in
            defer {
                group.leave()
            }
            switch result {
            case .success(let respone):
                let metrics = respone.metric
                self?.metrics = metrics
            case .failure(let error):
                print(error)
            }
        }
        group.notify(queue: .main) {[weak self] in
            self?.renderData()
        }
    }
    
    private func renderData(){
        // Chart VM | FinancialMetricsViewModels
        
        let headerView = StockDetailHeaderView(frame: CGRect(
            x: 0,
            y: 0,
            width: view.width,
            height: (view.width * 0.7) + 100))
        var viewModels = [MetricCollectionViewCell.ViewModel]()
        if let metrics = metrics {
            viewModels.append(.init(name: "52W High", value: "\(metrics.AnnualWeekHigh)"))
            viewModels.append(.init(name: "52L Low", value: "\(metrics.AnnualWeekLow)"))
            viewModels.append(.init(name: "52W Return", value: "\(metrics.AnnualWeekPriceReturnDaily)"))
            viewModels.append(.init(name: "Beta", value: "\(metrics.beta)"))
            viewModels.append(.init(name: "10D Vol", value: "\(metrics.TenDayAverageTradingVolume)"))
        }
        tableView.tableHeaderView = headerView
        let change = getChangePercentage(symbol: symbol, data: candleStickData)
        headerView.configure(chartViewModel: .init(
            data: candleStickData.reversed().map{ $0.close },
            showLegend: true,
            showAxis: true,
            fillColor: change < 0 ? .systemRed : .systemGreen),
            metricViewModels: viewModels)
    }
    
    private func getChangePercentage(symbol: String, data: [CandleStick]) -> Double {
        let latestDate = data[0].date
        guard let latestClose = data.first?.close,
              let priorClose = data.first(where: {
                  !Calendar.current.isDate($0.date, inSameDayAs: latestDate)
              })?.close else { return 0.0 }
        return 1 - (priorClose/latestClose)
    }
    
    private func fetchNews(){
        APICaller.shared.news(for: .compan(symbol: symbol)) { [weak self] result in
            switch result {
            case .success(let stories):
                DispatchQueue.main.async {
                    self?.stories = stories
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

extension StockDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsStoryTableViewCell.id, for: indexPath) as? NewsStoryTableViewCell else { return UITableViewCell() }
        cell.configure(with: .init(model: stories[indexPath.row]))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NewsStoryTableViewCell.prefferedHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewsHeaderView.identifier) as? NewsHeaderView else { return UIView() }
        header.delegate = self
        header.configure(with: .init(title: symbol.uppercased(),
                                     shouldShowAddButton: !PersistanceManager.shared.watchlistContains(symbol: symbol)))
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return NewsHeaderView.prefferedHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let url = URL(string: stories[indexPath.row].url) else { return }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
}

extension StockDetailsViewController: NewsHeaderViewDelegate {
    // Add to watchlist
    func newsHeaderViewDidTapAddButton(_ headerView: NewsHeaderView) {
        headerView.button.isHidden = true
        PersistanceManager.shared.addToWatchList(symbol: symbol, companyName: companyName)
        let alert = UIAlertController(title: "Added to Watchlist", message: "We added \(companyName) to watchlist", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    
    
}

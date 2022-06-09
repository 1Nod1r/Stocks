//
//  ViewController.swift
//  Stocks
//
//  Created by Nodirbek on 23/05/22.
//

import UIKit
import FloatingPanel

class WatchListViewController: UIViewController {
    
    private var searchTimer: Timer?
    
    private var watchlist: [String: [CandleStick]] = [:]
    
    private var viewModels: [WatchListTableViewCell.ViewModel] = []
    
    private var panel: FloatingPanelController?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(WatchListTableViewCell.self, forCellReuseIdentifier: WatchListTableViewCell.id)
        return tableView
    }()
    
    private var observer: NSObjectProtocol?
    
    // MARK: - ViewLifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupSearchController()
        setupTableView()
        setupWatchlistData()
        setupTitleView()
        setupFloatinPanel()
        setUpObserver()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    // MARK: - Private
    
    private func setupTableView(){
        view.addSubviews(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setUpObserver(){
        observer = NotificationCenter.default.addObserver(
            forName: .didAddWatchlist,
            object: nil,
            queue: .main,
            using: {[weak self] _ in
                self?.viewModels.removeAll()
                self?.setupWatchlistData()
            })
    }
    
    private func setupWatchlistData(){
        let symbols = PersistanceManager.shared.watchList
        let group = DispatchGroup()
        for symbol in symbols where watchlist[symbol] == nil {
            group.enter()
            APICaller.shared.marketData(for: symbol) {[weak self] result in
                defer {
                    group.leave()
                }
                switch result {
                case .success(let result):
                    let candleSticks = result.candleStick
                    self?.watchlist[symbol] = candleSticks
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        group.notify(queue: .main) {[weak self] in
            self?.createViewModels()
            self?.tableView.reloadData()
        }
    }
    
    private func createViewModels() {
        var viewModels = [WatchListTableViewCell.ViewModel]()
        for (symbol, candleSticks) in watchlist {
            let changePercentage = getChangePercentage(symbol: symbol, data: candleSticks)
            viewModels.append(.init(
                symbol: symbol,
                companyName: UserDefaults.standard.string(forKey: symbol) ?? "company",
                price: getLatestClosingPrice(from: candleSticks),
                changeColor: changePercentage < 0 ? .systemRed : .systemGreen,
                changePercentage: String.percentage(from: changePercentage),
                chartViewModel: .init(data: candleSticks.reversed().map{ $0.close },
                                      showLegend: false,
                                      showAxis: false,
                                      fillColor: changePercentage < 0 ? .systemRed : .systemGreen)
            ))
        }
        
        self.viewModels = viewModels
    }
    
    private func getChangePercentage(symbol: String, data: [CandleStick]) -> Double {
        let latestDate = data[0].date
        guard let latestClose = data.first?.close,
              let priorClose = data.first(where: {
                  !Calendar.current.isDate($0.date, inSameDayAs: latestDate)
              })?.close else { return 0.0 }
        return 1 - (priorClose/latestClose)
    }
    
    private func getLatestClosingPrice(from data: [CandleStick]) -> String {
        guard let closingPrice = data.first?.close else { return "" }
        return String.formatted(number: closingPrice)
    }
    
    private func setupFloatinPanel(){
        let vc = NewsViewController(type: .topStories)
        let panel = FloatingPanelController(delegate: self)
        panel.set(contentViewController: vc)
        panel.track(scrollView: vc.tableView)
        panel.addPanel(toParent: self)
    }
    
    
    private func setupTitleView(){
        let titleView = UIView(frame: CGRect(x: 0,
                                             y: 0,
                                             width: view.width,
                                             height: navigationController?.navigationBar.height ?? 100))
        let title = UILabel(frame: CGRect(x: 10, y: 0, width: titleView.width - 20, height: titleView.height))
        title.font = .systemFont(ofSize: 40, weight: .medium)
        title.text = "Stocks"
        titleView.addSubview(title)
        navigationItem.titleView = titleView
    }
    
    
    private func setupSearchController(){
        let resultVC = SearchResultsViewController()
        let searchVC = UISearchController(searchResultsController: resultVC)
        resultVC.delegate = self
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
    }
    
}

extension WatchListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              let resultsVC = searchController.searchResultsController as? SearchResultsViewController,
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        // Optimize to reduce number of searches for when user stops
        searchTimer?.invalidate()
        // Make API to search
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { _ in
            APICaller.shared.search(query: query) { result in
                switch result {
                case .success(let response):
                    DispatchQueue.main.async {
                        resultsVC.update(with: response.result)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        resultsVC.update(with: [])
                    }
                    print(error.localizedDescription)
                }
            }
        })
        //update results controller
        
        
        
        print(query)
    }
}


extension WatchListViewController: SearchResultsViewControllerDelegate {
    func searchResultsViewControllerDidSelect(searchResult: SearchResult) {
        navigationItem.searchController?.searchBar.resignFirstResponder()
        let vc = StockDetailsViewController(symbol: searchResult.displaySymbol,
                                            companyName: searchResult.description
        )
        let navVc = UINavigationController(rootViewController: vc)
        vc.title = searchResult.description
        present(navVc, animated: true)
        
    }
}

extension WatchListViewController: FloatingPanelControllerDelegate {
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        navigationItem.titleView?.isHidden = fpc.state == .full
    }
}

extension WatchListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WatchListTableViewCell.id, for: indexPath) as? WatchListTableViewCell else { return UITableViewCell()}
        cell.configure(with: viewModels[indexPath.row  ])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return WatchListTableViewCell.prefferedHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let viewModel = viewModels[indexPath.row]
        let vc = StockDetailsViewController(symbol: viewModel.symbol,
                                            companyName: viewModel.companyName,
                                            candleStickData: watchlist[viewModel.symbol] ?? [])
        let navVc = UINavigationController(rootViewController: vc)
        present(navVc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            
            // Update Persistance
            PersistanceManager.shared.removeToWatchList(symbol: viewModels[indexPath.row].symbol)
            
            // Update ViewModels
            viewModels.remove(at: indexPath.row)
            
            // Delete Row
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }
}

// MARK: - Example of child ViewController

//    private func setUpChild(){
//        let vc = PanelViewController()
//        addChild(vc)
//        view.addSubview(vc.view)
//        vc.view.frame = CGRect(x: 0, y: view.height / 2, width: view.width, height: view.height)
//        vc.didMove(toParent: self)
//    }

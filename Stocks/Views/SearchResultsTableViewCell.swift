//
//  SearchResultsTableViewCell.swift
//  Stocks
//
//  Created by Nodirbek on 24/05/22.
//

import UIKit

class SearchResultsTableViewCell: UITableViewCell {

   static let id = "SearchResultsTableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError()
    }
}

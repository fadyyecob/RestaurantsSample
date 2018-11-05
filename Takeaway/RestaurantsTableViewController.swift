//
//  RestaurantsTableViewController.swift
//  Takeaway
//
//  Created by Fady Yecob on 22/10/2018.
//  Copyright © 2018 Fady Yecob. All rights reserved.
//

import UIKit

class RestaurantsTableViewController: UITableViewController, UISearchResultsUpdating {
    @IBOutlet var sortButton: UIBarButtonItem!
    
    var restaurants = [Restaurant]()
    var favouriteRestaurants = UserDefaults.standard.array(forKey: "favouriteResaurants") as? [String]
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var selectedSortingOption: SortingOptions = .bestMatch {
        didSet {
            sortButton.title = selectedSortingOption.rawValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sortButton.title = selectedSortingOption.rawValue

        setupNavigationBar()
        loadData()
        sortData()
    }
    
    /// Puts the search bar in the navigation item and sets the delegate.
    func setupNavigationBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
    }
    
    /// Load the data from the json file.
    func loadData() {
        guard   let jsonFile = Bundle.main.path(forResource: "sample", ofType: "json"),
                let jsonData = try? Data(contentsOf: .init(fileURLWithPath: jsonFile)),
                let restaurants = try? JSONDecoder().decode([Restaurant].self, from: jsonData) else { return }
        
        self.restaurants = restaurants
    }
    
    
    /// Sorts the data in the restaurants array.
    ///
    /// - Parameter reload: Set to true to reload the tableview.
    func sortData(reload: Bool = false) {
        
        // Sort everything by sort option
        restaurants.sort { (first, second) -> Bool in
            switch selectedSortingOption {
            case .averageProductPrice:
                return first.sortingValues.averageProductPrice < second.sortingValues.averageProductPrice
            case .bestMatch:
                return first.sortingValues.bestMatch < second.sortingValues.bestMatch
            case .deliveryCosts:
                return first.sortingValues.deliveryCosts < second.sortingValues.deliveryCosts
            case .distance:
                return first.sortingValues.distance < second.sortingValues.distance
            case .minCost:
                return first.sortingValues.minCost < second.sortingValues.minCost
            case .newest:
                return first.sortingValues.newest < second.sortingValues.newest
            case .popularity:
                return first.sortingValues.popularity < second.sortingValues.popularity
            case .ratingAverage:
                return first.sortingValues.ratingAverage < second.sortingValues.ratingAverage
            }
        }
        
        // Sort everything by status
        restaurants.sort { (first, second) -> Bool in
            if first.status == "open" {
                return true
            } else if first.status == "order ahead" && second.status != "open" {
                return true
            } else if first.status == "closed" && second.status == "closed" {
                return true
            }
            
            return false
        }
        
        // Sort everything by favourites
        restaurants.sort { (first, second) -> Bool in
            guard let favouriteRestaurants = favouriteRestaurants else { return false }

            return favouriteRestaurants.contains(first.name)
        }

        // Sort the favourites by status
        restaurants.sort { (first, second) -> Bool in
            guard let favouriteRestaurants = favouriteRestaurants, favouriteRestaurants.contains(first.name) else { return false }

            if first.status == "open" {
                return true
            } else if first.status == "order ahead" && second.status != "open" {
                return true
            } else if first.status == "closed" && second.status == "closed" {
                return true
            }
            
            return false
        }
        
        if reload {
            tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }
    
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            loadData()
            sortData(reload: true)
            return
        }
        
        loadData()
        sortData()
        
        restaurants = restaurants.filter { (restaurant) -> Bool in
            restaurant.name.localizedCaseInsensitiveContains(searchText)
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Actions
    
    @objc func favouriteAction(sender: UIButton) {
        guard let cell = sender.superview?.superview as? UITableViewCell else { return }
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        let restaurant = restaurants[indexPath.row]
        
        guard var favouriteRestaurants = UserDefaults.standard.array(forKey: "favouriteResaurants") as? [String] else {
            UserDefaults.standard.set([restaurant.name], forKey: "favouriteResaurants")
            self.favouriteRestaurants = [restaurant.name]
            sortData(reload: true)
            return
        }
        
        if favouriteRestaurants.contains(restaurant.name) {
            favouriteRestaurants.removeAll{ $0 == restaurant.name }
        } else {
            favouriteRestaurants.append(restaurant.name)
        }
        
        UserDefaults.standard.set(favouriteRestaurants, forKey: "favouriteResaurants")
        self.favouriteRestaurants = favouriteRestaurants
        
        sortData(reload: true)
    }
    
    @IBAction func sortAction(_ sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: "Choose a sorting option", message: nil, preferredStyle: .actionSheet)
        
        for sortingOption in SortingOptions.allCases {
            actionSheet.addAction(UIAlertAction(title: sortingOption.rawValue, style: .default, handler: { [weak self] (action) in
                self?.selectedSortingOption = sortingOption
                self?.sortData(reload: true)
            }))
        }
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurants.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let restaurant = restaurants[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantCell", for: indexPath) as? RestaurantTableViewCell else { return UITableViewCell(style: .default, reuseIdentifier: "restaurantCell") }
        
        cell.favouriteButton.setImage(#imageLiteral(resourceName: "heart").withRenderingMode(.alwaysTemplate), for: .normal)

        cell.nameLabel.text = restaurant.name
        cell.statusLabel?.text = restaurant.status?.capitalized
        
        switch restaurant.status {
        case "open":
            cell.statusLabel.textColor = #colorLiteral(red: 0.1176470588, green: 0.7647058824, blue: 0.2156862745, alpha: 1)
            break
        case "order ahead":
            cell.statusLabel.textColor = #colorLiteral(red: 0.9607843137, green: 0.7607843137, blue: 0, alpha: 1)
            break
        case "closed":
            cell.statusLabel.textColor = #colorLiteral(red: 0.9607843137, green: 0.1921568627, blue: 0.1490196078, alpha: 1)
            break
        case .none:
            break
        case .some(_):
            break
        }
        
        switch selectedSortingOption {
        case .averageProductPrice:
            cell.sortLabel.text = "\(selectedSortingOption.rawValue): \(restaurant.sortingValues.averageProductPrice)"
            break
        case .bestMatch:
            cell.sortLabel.text = "\(selectedSortingOption.rawValue): \(restaurant.sortingValues.bestMatch)"
            break
        case .deliveryCosts:
            cell.sortLabel.text = "\(selectedSortingOption.rawValue): \(restaurant.sortingValues.deliveryCosts)"
            break
        case .distance:
            cell.sortLabel.text = "\(selectedSortingOption.rawValue): \(restaurant.sortingValues.distance)"
            break
        case .minCost:
            cell.sortLabel.text = "\(selectedSortingOption.rawValue): \(restaurant.sortingValues.minCost)"
            break
        case .newest:
            cell.sortLabel.text = "\(selectedSortingOption.rawValue): \(restaurant.sortingValues.newest)"
            break
        case .popularity:
            cell.sortLabel.text = "\(selectedSortingOption.rawValue): \(restaurant.sortingValues.popularity)"
            break
        case .ratingAverage:
            cell.sortLabel.text = "\(selectedSortingOption.rawValue): \(restaurant.sortingValues.ratingAverage)"
            break
        }
        
        cell.favouriteButton.addTarget(self, action: #selector(favouriteAction(sender:)), for: .touchUpInside)
        
        if favouriteRestaurants?.contains(restaurant.name) ?? false {
            cell.favouriteButton.setImage(#imageLiteral(resourceName: "heartFilled").withRenderingMode(.alwaysTemplate), for: .normal)
        }
        
        return cell
    }
    
    enum SortingOptions: String, CaseIterable {
        case bestMatch = "Best Match"
        case newest = "Newest"
        case ratingAverage = "Rating Average"
        case distance = "Distance"
        case popularity = "Popularity"
        case averageProductPrice = "Average Product Price"
        case deliveryCosts = "Delivery Costs"
        case minCost = "Min Cost"
    }
}

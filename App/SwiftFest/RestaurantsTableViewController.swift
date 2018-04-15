//
//  RestaurantsTableViewController.swift
//  SwiftFest
//
//  Created by Matthew Dias on 10/28/17.
//  Copyright © 2017 Matt Dias. All rights reserved.
//

import UIKit

class RestaurantsTableViewController: UITableViewController {

    var restaurants: [Restaurant]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.refreshControl?.addTarget(self, action: #selector(fetchRestaurants), for: .valueChanged)

        fetchRestaurants()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return restaurants?.count ?? 0 }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "restCell", for: indexPath)

        if let restaurants = restaurants {
            cell.textLabel?.text = restaurants[indexPath.row].name
        }

        return cell
    }

    @objc private func fetchRestaurants() {
        var request = URLRequest(url: URL(string: "http://localhost:8080/restaurants")!)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data,
                  let responseJson = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]] else { return }

            var restaurants: [Restaurant] = []
            for json in responseJson! {
                if let restuarant = Restaurant(json: json) {
                    restaurants.append(restuarant)
                }
            }

            self.restaurants = restaurants
        }

        task.resume()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailVC = segue.destination as? RestaurantDetailViewController,
           let row = tableView.indexPathForSelectedRow?.row,
           let restaurant = restaurants?[row] {
            detailVC.restaurant = restaurant
        }
    }

}

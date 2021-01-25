//
//  TMDBAlert.swift
//  TMDB
//
//  Created by Preetam Jadakar on 25/01/21.
//

import Foundation
import UIKit

protocol Alertable { }
extension Alertable where Self: UIViewController {
    func displayAlert(title: String, message: String, buttonTitles: [String] = ["okay"], completion: @escaping ((Int) -> Void) = { index in }) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for index in 0..<buttonTitles.count {
            alert.addAction(UIAlertAction.init(title: buttonTitles[index], style: .default, handler: { (action) in
                completion(index)
            }))
        }
        self.present(alert, animated: true, completion: nil)
    }
}

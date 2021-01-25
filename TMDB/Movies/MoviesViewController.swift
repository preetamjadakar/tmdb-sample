//
//  MoviesViewController.swift
//  TMDB
//
//  Created by Preetam Jadakar on 24/01/21.
//

import UIKit
import CoreData

class MoviesViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    let viewModel = MoviesViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(UINib.init(nibName: "MovieCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)

        self.fetchAndLoadFirstPageData()
        
        let refresher = UIRefreshControl()
        self.collectionView!.alwaysBounceVertical = true
        refresher.tintColor = UIColor.red
        refresher.addTarget(self, action: #selector(fetchAndLoadFirstPageData), for: .valueChanged)
        self.collectionView.refreshControl = refresher
    }
    
    @objc func fetchAndLoadFirstPageData() {
        self.collectionView.refreshControl?.beginRefreshing()
        viewModel.fetchFirstPageData { _ in
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.collectionView.refreshControl?.endRefreshing()                
            }
        }
    }
}

extension MoviesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.identifier, for: indexPath) as? MovieCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.delegate = self
        cell.configure(using: viewModel.dataSource[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = (collectionView.frame.size.width - 10) / 2
        let itemHeight = itemWidth*1.8
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == viewModel.dataSource.count - 2 {  //check for next page
            viewModel.fetchNextPageData { (success) in
                if success {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else {return}
                        self.collectionView.reloadData()
                    }
                } else {
                    print("fetch failed")
                }
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footerViewIdentifier", for: indexPath as IndexPath)
            return footerView
        }
        return UIView() as! UICollectionReusableView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: self.collectionView.frame.width, height: 110)
    }
}

extension MoviesViewController: MovieCollectionViewCellDelegate {
    func favoritesButtonClicked(cell: MovieCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let movieModel = viewModel.dataSource[indexPath.item]
        //update coreData
        movieModel.setValue(!movieModel.isFavorited, forKey: favoritesKey)
        movieModel.setValue(Date(), forKey: favoritedDateKey)
        Database.shared.saveContext()
        collectionView.reloadItems(at: [indexPath])
    }
}

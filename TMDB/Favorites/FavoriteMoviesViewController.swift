//
//  FavoriteMoviesViewController.swift
//  TMDB
//
//  Created by Preetam Jadakar on 24/01/21.
//

import UIKit
import CoreData

class FavoriteMoviesViewController: UIViewController {
    
    let viewModel = FavoriteMoviesViewModel()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(UINib.init(nibName: "MovieCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadFavorites { _ in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                self.collectionView.reloadData()
                self.collectionView.isHidden = self.viewModel.dataSource.count == 0
            }
        }
    }
}

extension FavoriteMoviesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.identifier, for: indexPath) as? MovieCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.delegate = self
        let movieModel = viewModel.dataSource[indexPath.item]
        cell.configure(using: movieModel)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = (collectionView.frame.size.width - 10) / 2
        let itemHeight = itemWidth*1.8
        return CGSize(width: itemWidth, height: itemHeight)
    }
}

extension FavoriteMoviesViewController: MovieCollectionViewCellDelegate {
    func favoritesButtonClicked(cell: MovieCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let movieModel = viewModel.dataSource[indexPath.item]
        //update coreData
        movieModel.setValue(!movieModel.isFavorited, forKey: favoritesKey)
        Database.shared.saveContext()
        viewModel.dataSource.remove(at: indexPath.item)
        self.collectionView.isHidden = self.viewModel.dataSource.count == 0
        collectionView.deleteItems(at: [indexPath])
    }
}

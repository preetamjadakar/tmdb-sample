//
//  MovieCollectionViewCell.swift
//  TMDB
//
//  Created by Preetam Jadakar on 24/01/21.
//

import UIKit
import Kingfisher
protocol MovieCollectionViewCellDelegate: class {
    func favoritesButtonClicked(cell: MovieCollectionViewCell)
}

class MovieCollectionViewCell: UICollectionViewCell {
    static let identifier = "MovieCollectionViewCell"
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var ratingsLabel: UILabel!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var gradientViewRightCorner: UIImageView!
    @IBOutlet weak var favoritesButton: UIButton!
    weak var delegate: MovieCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addShadow()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyGradient()
    }
    
    func configure(using data: Movie) {
        ratingsLabel.text = "\(data.vote_average)"
        movieTitleLabel.text = data.title
        favoritesButton.setImage(data.isFavorited ? #imageLiteral(resourceName: "heart-filled") : #imageLiteral(resourceName: "heart"), for: .normal)
        setPosterImage(urlString: data.poster_path ?? "")
    }
    
    func setPosterImage(urlString: String) {
        let url = URL(string: "https://image.tmdb.org/t/p/w185\(urlString)")
        posterImageView.kf.indicatorType = .activity
        posterImageView.kf.setImage(
            with: url,
            placeholder: #imageLiteral(resourceName: "movie_icon"),
            options: [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
    }
    
    @IBAction func favoritesButtonAction(_ sender: Any) {
        delegate?.favoritesButtonClicked(cell: self)
    }
    
    func addShadow() {
        containerView.layer.backgroundColor = UIColor.white.cgColor
        containerView.layer.shadowColor = UIColor.lightGray.cgColor
        containerView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        containerView.layer.shadowRadius = 2.0
        containerView.layer.shadowOpacity = 1.0
        containerView.layer.masksToBounds = false
    }
    
    func applyGradient() {
        gradientViewRightCorner.layoutIfNeeded()
        self.gradientViewRightCorner.layer.sublayers = nil
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradient.locations = [0.5 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.gradientViewRightCorner.frame.size.width, height: self.gradientViewRightCorner.frame.size.height)
        self.gradientViewRightCorner.layer.insertSublayer(gradient, at: 0)
    }
}

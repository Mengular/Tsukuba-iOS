//
//  SelectCategoryViewController.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 07/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import UIKit

class SelectCategoryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var categoriesCollectionView: UICollectionView!
    
    let dao = DaoManager.sharedInstance
    
    var categories: [Category]!
    var selectedCategory: Category!
    var lastSelectedCell: CategoryCollectionViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        categories = dao.categoryDao.findEnable()
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let category = categories[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryIdentifier",
                                                      for: indexPath) as! CategoryCollectionViewCell
        cell.nameLabel.text = category.identifier
        cell.iconImageView.kf.setImage(with: URL(string: createUrl(category.icon!)))
        return cell
    }

    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if lastSelectedCell != nil {
            lastSelectedCell?.iconImageView.kf.setImage(with: URL(string: createUrl(selectedCategory.icon!)))
        }
        lastSelectedCell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell
        lastSelectedCell?.iconImageView.image = UIImage(named: "category_selected")
        selectedCategory = categories[indexPath.row]
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createMessageSegue" {
            segue.destination.setValue(selectedCategory, forKey: "category")
        }
    }

    // MARK: - Action
    @IBAction func choosed(_ sender: Any) {
        if lastSelectedCell == nil {
            return
        }
        self.performSegue(withIdentifier: "createMessageSegue", sender: self)
    }
}
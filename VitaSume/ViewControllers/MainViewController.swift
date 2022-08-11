//
//  MainViewController.swift
//  RussMyers
//
//  Created by Jeffrey Burt on 2/3/16.
//  Copyright © 2016 Seven Even. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var containerView: UIView!
    
    var mainPageViewController: MainPageViewController? {
        didSet {
            mainPageViewController?.mainDelegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageControl.addTarget(self, action: #selector(self.didChangePageControlValue), for: .valueChanged)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mainPageViewController = segue.destination as? MainPageViewController {
            self.mainPageViewController = mainPageViewController
        }
    }

    @IBAction func didTapNextButton(_ sender: Any) {
        mainPageViewController?.scrollToNextViewController()
    }
    
    /**
     Fired when the user taps on the pageControl to change its current page.
     */
    @objc func didChangePageControlValue() {
        mainPageViewController?.scrollToViewController(index: pageControl.currentPage)
    }
}

extension MainViewController: MainPageViewControllerDelegate {
    func MainPageViewController(mainPageViewController: MainPageViewController, didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
    }
    
    func MainPageViewController(mainPageViewController: MainPageViewController, didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
    }
}

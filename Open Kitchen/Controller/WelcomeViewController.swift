//
//  WelcomeViewController.swift
//  Open Kitchen
//
//  Created by Brandon Kan  on 2020-07-03.
//  Copyright © 2020 Brandon Kan . All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    @IBOutlet weak var holderView: UIView!
    
    let scrollView = UIScrollView()
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.9058823529, blue: 0.7960784314, alpha: 1)
        configure()
    }
    
    private func configure() {
        // set up scrollview
        
        scrollView.frame = holderView.bounds
        holderView.addSubview(scrollView)
        holderView.backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.9058823529, blue: 0.7960784314, alpha: 1)
        
        let titles = ["Welcome to the Kitchen", "Add your Recipe", "Your All Set!"]
        for x in 0..<3 {
            let pageView = UIView(frame: CGRect(x: CGFloat(x) * (holderView.frame.size.width), y: 0, width: holderView.frame.size.width, height: holderView.frame.size.height ))
            scrollView.addSubview(pageView)
            
            // Title, Image, Button
            let label = UILabel(frame: CGRect(x: 10, y: 10, width: pageView.frame.size.width - 20, height: 120))
            
            let imageView = UIImageView(frame: CGRect(x: 10, y: 10 + 120, width: pageView.frame.size.width - 20, height: pageView.frame.size.height - 60 - 130 - 15))
            
            let button = UIButton(frame: CGRect(x: 10, y: pageView.frame.size.height - 60, width: pageView.frame.size.width - 20, height: 50))
            
            label.textAlignment = .center
            label.font = UIFont(name: "Thonburi-Bold", size : 32)
            pageView.addSubview(label)
            label.text = titles[x]
            
            imageView.contentMode = .scaleAspectFit
            imageView.image = UIImage(named: "welcome_\(x + 1)")
            pageView.addSubview(imageView)
            
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .black
            button.setTitle("Continue", for: .normal)
            if x == 2 {
                button.setTitle("Get Started", for: .normal)
            }
            button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
            button.tag = x + 1
            pageView.addSubview(button)
        }
        
        scrollView.contentSize = CGSize(width: holderView.frame.size.width * 3, height : 0)
        scrollView.isPagingEnabled = true
        
    }
    
    @objc func didTapButton(_ button: UIButton) {
        guard button.tag < 3 else {
            Core.shared.setIsNotNewUser()
            dismiss(animated: true, completion: nil)
        return
    }
        scrollView.setContentOffset(CGPoint(x: holderView.frame.size.width * CGFloat(button.tag), y: 0), animated: true)
        
    }


}

//
//  ViewController.swift
//  shaker_full
//
//  Created by Andrey Egorov on 6/2/16.
//  Copyright © 2016 Andrey Egorov. All rights reserved.
//

import UIKit
import Moya
import RxSwift
import RxCocoa
import Action

class ViewController: UIViewController {
    
//    var provider: Networking!
    var provider: RxMoyaProvider<ShakerAPI>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        provider = RxMoyaProvider<ShakerAPI>()
        let endpoint: ShakerAPI = ShakerAPI.Feedback
        
        provider.request(endpoint)
            .filterSuccessfulStatusCodes()
            .subscribeNext { _ in
                print("YES!")
            }
//            .addDisposableTo(rx_disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


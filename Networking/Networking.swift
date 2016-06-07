//
//  Networking.swift
//  shaker_full
//
//  Created by Andrey Egorov on 6/7/16.
//  Copyright © 2016 Andrey Egorov. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import Alamofire

class OnlineProvider<Target where Target: TargetType>: RxMoyaProvider<Target> {
    init(endpointClosure: MoyaProvider<Target>.EndpointClosure = MoyaProvider.DefaultEndpointMapping,
         requestClosure: MoyaProvider<Target>.RequestClosure = MoyaProvider.DefaultRequestMapping,
         manager: Manager = Alamofire.Manager.sharedInstance) {
        super.init(endpointClosure: endpointClosure, requestClosure: requestClosure, manager: manager)
    }
}

protocol NetworkingType {
    associatedtype T: TargetType
    var provider: OnlineProvider<T> { get }
}

struct Networking: NetworkingType {
    typealias T = ShakerAPI
    let provider: OnlineProvider<ShakerAPI>
}

private extension Networking {
    // функция для проверки, разлогинен ли юзер, может фетчить новые токены для авторизации(?)
    
    
}

extension Networking {
    func request(token: ShakerAPI, defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()) -> Observable<Moya.Response> {
        // проверять не разлогинен ли
        return self.provider.request(token)
    }
}

extension NetworkingType {
    static func newDefaultNetworking() -> Networking {
        return Networking(provider: OnlineProvider())
//        return Networking(provider: newProvider)
    }
}

//private func newProvider<T where T: TargetType>(xAccessToken: String? = nil) -> OnlineProvider<T> {
//    return OnlineProvider(endpointClosure: Networking.endpointsClosure(xAccessToken),
//                          requestClosure: Networking.endpointResolver())
//}
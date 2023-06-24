//
//  AppDetailModel.swift
//  iAppStore
//
//  Created by HTC on 2021/12/18.
//  Copyright © 2021 37 Mobile Games. All rights reserved.
//

import Foundation


class AppDetailModel: ObservableObject {
    
    @Published var app: AppDetail? = nil
    @Published var results: [AppDetail] = []
    
    @Published var isLoading: Bool = false
    
    func searchAppData(_ appId: String?, _ keyWord: String?, _ regionName: String) {
        
        let regionId = TSMGConstants.regionTypeListIds[regionName] ?? "cn"
        var endpoint: APIService.Endpoint = APIService.Endpoint.lookupApp(appid: "", country: "")
        if let appid = appId {
            endpoint = APIService.Endpoint.lookupApp(appid: appid, country: regionId)
        }
        if let word = keyWord, let encodeword = word.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            endpoint = APIService.Endpoint.searchApp(word: encodeword, country: regionId, limit: 200)
        }
        
        isLoading = true
        APIService.shared.POST(endpoint: endpoint, params: nil) { (result: Result<AppDetailM, APIService.APIError>) in
            self.isLoading = false
            switch result {
            case let .success(response):
                self.results = response.results
                if appId != nil {
                    self.app = response.results.first
                }
                if let word = keyWord {
                    self.lookupBundleId(word: word, regionId: regionId)
                }
            case .failure(_):
                break
            }
        }
    }
    
    /// search bundleId
    func lookupBundleId(word: String, regionId: String) {
        guard let bundleId = word.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        
        let endpoint = APIService.Endpoint.lookupBundleId(appid: bundleId, country: regionId)
        APIService.shared.POST(endpoint: endpoint, params: nil) { (result: Result<AppDetailM, APIService.APIError>) in
            switch result {
            case let .success(response):
                if let app = response.results.first {
                    self.results.insert(app, at: 0)
                }
            case .failure(_):
                break
            }
        }
    }
    
    /// looup app id
    func lookupAppId(_ appId: String, _ regionName: String) {
        let regionId = TSMGConstants.regionTypeListIds[regionName] ?? "cn"
        let endpoint = APIService.Endpoint.lookupApp(appid: appId, country: regionId)
        
        APIService.shared.POST(endpoint: endpoint, params: nil) { (result: Result<AppDetailM, APIService.APIError>) in
            switch result {
            case let .success(response):
                if let app = response.results.first {
                    self.results.append(app)
                }
            case .failure(_):
                break
            }
        }
    }
}

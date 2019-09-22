//
//  AuthorizeAccount.swift
//  Flare
//
//  Created by Chris on 4/9/19.
//  Copyright © 2019 Splinter. All rights reserved.
//

import Foundation

/// https://www.backblaze.com/b2/docs/b2_authorize_account.html
enum AuthorizeAccount {
    static func send(accountId: String, applicationKey: String, completion: @escaping (Result<AuthorizeAccountResponse, Error>) -> ()) {
        let url = URL(string: "https://api.backblazeb2.com/b2api/v1/b2_authorize_account")!
        var request = URLRequest(url: url)
        let auth = (accountId + ":" + applicationKey).asData.base64EncodedString()
        request.addValue("Basic " + auth, forHTTPHeaderField: "Authorization")
        Service.shared.make(request: request, completion: { result in
            switch result {
            case .success(let json, _):
                if let response = AuthorizeAccountResponse.from(json: json) {
                    completion(.success(response))
                } else {
                    completion(.failure(Service.Errors.invalidResponse))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
}

struct AuthorizeAccountResponse {
    let authorizationToken: String
    let accountId: String
    let apiUrl: String // Eg "https://apiNNN.backblazeb2.com"
    let downloadUrl: String // eg "https://f002.backblazeb2.com"
    let absoluteMinimumPartSize: Int
    let recommendedPartSize: Int
}

extension AuthorizeAccountResponse {
    static func from(json: [AnyHashable: Any]) -> AuthorizeAccountResponse? {
        guard let at = json["authorizationToken"] as? String else { return nil }
        guard let ai = json["accountId"] as? String else { return nil }
        guard let au = json["apiUrl"] as? String else { return nil }
        guard let du = json["downloadUrl"] as? String else { return nil }
        guard let am = json["absoluteMinimumPartSize"] as? Int else { return nil }
        guard let rp = json["recommendedPartSize"] as? Int else { return nil }
        return AuthorizeAccountResponse(authorizationToken: at, accountId: ai, apiUrl: au, downloadUrl: du, absoluteMinimumPartSize: am, recommendedPartSize: rp)
    }
}

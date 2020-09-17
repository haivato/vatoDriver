//  File name   : ParamsArrayEncoding.swift
//
//  Author      : Dung Vu
//  Created date: 2/22/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import Alamofire

typealias ExchangeRequest = (_ urlRequest: URLRequestConvertible, _ parameters: Parameters?) throws -> URLRequest
struct ParamsArrayEncoding: ParameterEncoding {
    let blockExchange: ExchangeRequest
    init(exchange: @escaping ExchangeRequest) {
        blockExchange = exchange
    }
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        return try blockExchange(urlRequest, parameters)
    }
}


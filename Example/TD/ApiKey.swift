//
//  ApiKey.swift
//  Hyber
//
//  Created by Taras on 2/16/17.
//  Copyright © 2017 Incuube. All rights reserved.
//

import UIKit

let clientApiKey = "\(gedApiKeyPreProd())"

func gedApiKeyPreProd() -> String {
    let def = UserDefaults.standard
    if def.object(forKey: "apikey") == nil {
        return "key"
    } else {
        return def.string(forKey: "apikey")!
    }
}

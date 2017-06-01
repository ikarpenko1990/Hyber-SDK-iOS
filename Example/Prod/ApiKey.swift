//
//  apiKey.swift
//  Hyber
//
//  Created by Taras on 2/16/17.
//  Copyright © 2017 Incuube. All rights reserved.
//

import UIKit

let clientApiKey = "\(gedApiKeyProd())"

func gedApiKeyProd() -> String {
    let def = UserDefaults.standard
    if def.object(forKey: "apikey") == nil {
        return "3f15b716-dd56-4c0e-b29f-3d9e6d5b5057"
    } else {
        return def.string(forKey: "apikey")!
    }
}

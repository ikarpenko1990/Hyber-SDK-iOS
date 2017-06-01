//
//  ApiKey.swift
//  Hyber
//
//  Created by Taras on 2/16/17.
//  Copyright © 2017 Incuube. All rights reserved.
//

import UIKit
var clientApiKey = gedApiKeyTest()

func gedApiKeyTest() -> String {
    let def = UserDefaults.standard
    if def.object(forKey: "clientApiKey") == nil {
        return "b5a5b6f4-5af7-11e6-8b77-86f30ca893d3"
    } else {
        return def.string(forKey: "clientApiKey")!
    }
}



//
//  Application+Identify.swift
//  
//
//  Created by Brandon Toms on 4/13/22.
//

import LibP2P

extension Application.Identify.Provider {
    public static var `default`: Self {
        .init { app in
            app.identityManager.use {
                Identify(application: $0)
            }
        }
    }
}

//
//  Constants.swift
//  ChatClinic AI
//
//  Created by charmer on 6/3/24.
//

import Foundation
import UIKit

class Constants {
    static let accentColor: UIColor = UIColor(red: 0, green: 117, blue: 227, alpha: 1)
    static let darkGrayColor: UIColor = UIColor(red: 85, green: 85, blue: 85, alpha: 1)
    
    // lightBgColor: E2E3E2
    
    static let googleClientId: String = "294740910714-pnbk51qt9fjm18vphpfchgi8qqntmdkm.apps.googleusercontent.com"
    static let outlookClientId: String = "740c7d73-cce5-493e-8aae-ce5a19f4d865"
    
    static let kTenantSubdomain = "Enter_the_Tenant_Subdomain_Here"

    // Update the below to your client ID you received in the portal.
    static let kClientID = outlookClientId
    static let kRedirectUri = "Enter_the_Redirect_URI_Here"
    static let kProtectedAPIEndpoint = "Enter_the_Protected_API_Full_URL_Here"
    static let kScopes = ["Enter_the_Protected_API_Scopes_Here"]

    static let kAuthority = "https://\(kTenantSubdomain).ciamlogin.com"
}

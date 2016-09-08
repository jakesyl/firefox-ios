/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

/**
 *  Data structure containing metadata associated with a mailto: link. For additional details, 
 *  see RFC 2368 https://tools.ietf.org/html/rfc2368
 */
public struct MailToMetadata {
    public let to: String
    public let headers: [String: String]
}

public extension NSURL {

    /**
     Extracts the metadata associated with a mailto: URL according to RFC 2368
     https://tools.ietf.org/html/rfc2368
     */
    func mailToMetadata() -> MailToMetadata? {
        guard scheme == "mailto" else {
            return nil
        }

        // Extract 'to' value
        let toStart = absoluteString.startIndex.advancedBy("mailto:".characters.count)
        let toEnd = absoluteString.characters.indexOf("?") ?? absoluteString.endIndex

        let to = absoluteString.substringWithRange(toStart..<toEnd)

        guard toEnd != absoluteString.endIndex else {
            return MailToMetadata(to: to, headers: [String: String]())
        }

        // Extract headers
        let headersString = absoluteString.substringWithRange(toEnd.advancedBy(1)..<absoluteString.endIndex)
        var headers = [String: String]()
        let headerComponents = headersString.componentsSeparatedByString("&")

        headerComponents.forEach { headerPair in
            let components = headerPair.componentsSeparatedByString("=")
            guard components.count == 2 else {
                return
            }
            
            let (hname, hvalue) = (components[0], components[1])
            headers[hname] = hvalue
        }

        return MailToMetadata(to: to, headers: headers)
    }
}

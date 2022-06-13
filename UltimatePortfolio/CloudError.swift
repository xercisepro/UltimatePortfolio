//
//  CloudError.swift
//  UltimatePortfolio
//
//  Created by Andrew CP Markham on 13/6/2022.
//

import SwiftUI
import CloudKit

struct CloudError: Identifiable {
    // swiftlint:disable:next line_length
    /// Wrapper for Cloud Error Strings to make then Identifiable for the purposes of error handling and presenting within alerts
    var id: String { message }
    var message: String = ""

    var localisedMessage: LocalizedStringKey {
        LocalizedStringKey(message)
    }

    init(error: Error) {
        self.message = getCloudKitError(from: error)
    }

    func getCloudKitError(from error: Error) -> String {
        /// Function for parsing specific errors returned from cloud kti

        guard let error = error as? CKError else {
            return "An unknown error occured: \(error.localizedDescription)"
        }

        switch error.code {
            // Fundumental logic erors
        case .badContainer, .badDatabase, .invalidArguments:
            return "A fatal error occured: \(error.localizedDescription)"
            // Comunication errors
        case .networkFailure, .networkUnavailable, .serverResponseLost, .serviceUnavailable:
            return "There was a problem communicating with iCloud; please check your network connection and try again."
            // Authentication
        case .notAuthenticated:
            return "There was a problem with your iCloud account; please check that you're logged in to iCloud."
            // Too many store/delete requests for same data
        case .requestRateLimited:
            return "You've hit iCloud's rate limit; please wait a moment then try again."
            // Storage quota exceeded - very rare
        case .quotaExceeded:
            return "You've exceeded your iCloud quota; please clear up some space then try again."
        default:
            return "An unknown error occured: \(error.localizedDescription)"
        }
    }
}

extension CloudError: ExpressibleByStringInterpolation {

    init(stringLiteral value: String) {
         self.message = value
     }

}

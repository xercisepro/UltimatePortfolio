//
//  SignInView.swift
//  UltimatePortfolio
//
//  Created by Andrew CP Markham on 15/5/22.
//

import SwiftUI
import AuthenticationServices

/// View used to implement sign in with Apple (SIWA)
struct SignInView: View {
    @State private var status = SignInStatus.unknown
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme

    enum SignInStatus {
        case unknown
        case authorized
        case failure(Error?)
    }

    var body: some View {
        NavigationView {
            Group {
                switch status {
                case .unknown:
                    VStack(alignment: .leading) {
                        ScrollView { // Enables easy support of dynamic type - Accessibility
                            Text("""
                            In order to keep our communit safe, we ask that you sign in before commenting on a project.
                            We don't track your personal information, you name is used only for display purposes.
                            Please note: we reserve the right to remove messages that are inappropriate or offensive.
                            """)

                            Spacer()

                            SignInWithAppleButton(onRequest: configureSignIn, onCompletion: completionSignIn)
                                .frame(height: 44) // Stop it from takin up all the space available
                                .signInWithAppleButtonStyle(colorScheme == .light ? .black: .white)
                                // Used to implement different styles triggered with darkmode
                                // as it is not natively supported

                            Button("Cancel", action: close)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }

                case .authorized:
                    Text("You're all set!")
                case .failure(let error):
                    if let error = error {
                        Text("Sorry, there was an error: \(error.localizedDescription)")
                    } else {
                        Text("Sorry, there was an error.")
                    }
                }
            }
            .padding()
            .navigationTitle("Please sign in")
        }
    }

    /// Configure SIWA signin and get UsersName
    func configureSignIn(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName]
    }

    /// Processing  SIWA request on completion
    func completionSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            // the returned type/details from Apple can vary
            // NOTE: Apple sends us the user’s details only once,
            // which is the first time they attempt authentication
            // This includes all devices
            // Hence save the data
            // PS: To remove SIWA Authentication -> Settings -> Apple ID -> Passwords And Security -> Apps using AppleID

            if let appleID = auth.credential as? ASAuthorizationAppleIDCredential {
                if let fullName = appleID.fullName {
                    let formatter = PersonNameComponentsFormatter()
                    var username = formatter.string(from: fullName).trimmingCharacters(in: .whitespacesAndNewlines)

                    if username.isEmpty {
                        // Refuse to allow empty string names
                        username = "User-\(Int.random(in: 1001...9999))"
                    }

                    UserDefaults.standard.set(username, forKey: "username")
                    NSUbiquitousKeyValueStore.default.set(username, forKey: "username")
                    status = .authorized
                    close()
                    return
                }
            }

        case .failure(let error):
            if let error = error as? ASAuthorizationError {
                // for when the user clicked cancel
                if error.errorCode == ASAuthorizationError.canceled.rawValue {
                    status = .unknown
                    return
                }
            }

            status = .failure(error)
        }
    }

    /// Close the SIWA  view
    func close() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}

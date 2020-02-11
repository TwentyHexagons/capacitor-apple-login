import Foundation
import Capacitor
import AuthenticationServices

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitor.ionicframework.com/docs/plugins/ios
 */
@objc(SignInWithApple)
public class SignInWithApple: CAPPlugin {
    var call: CAPPluginCall?

    @objc func Authorize(_ call: CAPPluginCall) {
        self.call = call

        if #available(iOS 13.0, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]

            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.performRequests()
        } else {
            call.reject("Sign in with Apple is available on iOS 13.0+ only.")
        }
    }
}

@available(iOS 13.0, *)
extension SignInWithApple: ASAuthorizationControllerDelegate {
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            call?.reject("Please, try again.")

            return
        }
        var idToken: String = "", authCode: String = "";
        if (appleIDCredential.identityToken != nil) {
            idToken = String(decoding: appleIDCredential.identityToken!, as: UTF8.self);
        }
        if (appleIDCredential.authorizationCode != nil) {
            authCode = String(decoding: appleIDCredential.authorizationCode!, as: UTF8.self);
        }
        let result = [
            "response": [
                "user": appleIDCredential.user,
                "email": appleIDCredential.email,
                "givenName": appleIDCredential.fullName?.givenName,
                "familyName": appleIDCredential.fullName?.familyName,
                "idToken": idToken,
                "authCode": authCode
            ]
        ]

        call?.resolve(result as PluginResultData)
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        call?.reject(error.localizedDescription)
    }
}

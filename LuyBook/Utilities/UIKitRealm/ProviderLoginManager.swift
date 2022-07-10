//
//  ProviderLoginManager.swift
//  TongTin
//
//  Created by Sereivoan Yong on 6/15/22.
//

import Foundation
import Realm
import RealmSwift
import AuthenticationServices
import FacebookLogin
import GoogleSignIn

public enum LoginResult<Success, Failure: Error> {

  case success(Success)
  case failure(Failure)
  case cancellation
}

public enum IdentityProvider: String, CaseIterable {

  case apple = "oauth2-apple"
  case facebook = "oauth2-facebook"
  case google = "oauth2-google"
}

extension IdentityProvider: CustomStringConvertible {

  public var description: String {
    switch self {
    case .apple:    return "Apple"
    case .facebook: return "Facebook"
    case .google:   return "Google"
    }
  }
}

extension User {

  final public func identity(for provider: IdentityProvider) -> RLMUserIdentity? {
    return identities.first(where: { $0.providerType == provider.rawValue })
  }
}

final class ProviderLoginManager: NSObject {

  private var appleCompletion: ((LoginResult<ASAuthorizationAppleIDCredential, ASAuthorizationError>) -> Void)?

  func logIn(with provider: IdentityProvider, presentingViewController: UIViewController, completion: @escaping (LoginResult<Credentials, NSError>) -> Void) {
    switch provider {
    case .apple:
      logInWithApple { result in
        switch result {
        case .success(let credential):
          completion(.success(.apple(idToken: String(data: credential.identityToken!, encoding: .utf8)!)))
        case .failure(let error):
          completion(.failure(error as NSError))
        case .cancellation:
          completion(.cancellation)
        }
      }

    case .facebook:
      logInWithFacebook(presentingViewController: presentingViewController) { result in
        switch result {
        case .success(let accessToken):
          completion(.success(.facebook(accessToken: accessToken.tokenString)))
        case .failure(let error):
          completion(.failure(error as NSError))
        case .cancellation:
          completion(.cancellation)
        }
      }

    case .google:
      logInWithGoogle(presentingViewController: presentingViewController) { result in
        switch result {
        case .success(let user):
          completion(.success(.google(serverAuthCode: user.serverAuthCode!)))
        case .failure(let error):
          completion(.failure(error as NSError))
        case .cancellation:
          completion(.cancellation)
        }
      }
    }
  }

  private func logInWithApple(completion: @escaping (LoginResult<ASAuthorizationAppleIDCredential, ASAuthorizationError>) -> Void) {
    appleCompletion = completion
    let provider = ASAuthorizationAppleIDProvider()
    let request = provider.createRequest()
    request.requestedScopes = [.fullName, .email]

    let authorizationController = ASAuthorizationController(authorizationRequests: [request])
    authorizationController.delegate = self
    authorizationController.performRequests()
  }

  private func logInWithFacebook(presentingViewController: UIViewController, completion: @escaping (LoginResult<AccessToken, LoginError>) -> Void) {
    let loginManager = FacebookLogin.LoginManager()
    let loginConfiguration = LoginConfiguration(permissions: [.publicProfile, .email])
    loginManager.logIn(viewController: presentingViewController, configuration: loginConfiguration) { result in
      switch result {
      case .success(_, _, let token):
        completion(.success(token!))

      case .failed(let error):
        completion(.failure(error as! LoginError))

      case .cancelled:
        completion(.cancellation)
      }
    }
  }

  private func logInWithGoogle(presentingViewController: UIViewController, completion: @escaping (LoginResult<GIDGoogleUser, GIDSignInError>) -> Void) {
    let signIn = GIDSignIn.sharedInstance
    let configuration = GIDConfiguration(clientID: Constants.googleClientID, serverClientID: Constants.googleServerClientID)
    signIn.signIn(with: configuration, presenting: presentingViewController) { user, error in
      switch Result(user, error as! GIDSignInError?)! {
      case .success(let user):
        completion(.success(user))

      case .failure(let error):
        if error.code != .canceled {
          completion(.failure(error))
        } else {
          completion(.cancellation)
        }
      }
    }
  }

  static func logOut() {
    LoginManager().logOut()
    GIDSignIn.sharedInstance.signOut()
  }
}

extension ProviderLoginManager: ASAuthorizationControllerDelegate {

  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    appleCompletion?(.success(authorization.credential as! ASAuthorizationAppleIDCredential))
  }

  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    let error = error as! ASAuthorizationError
    if error.code != .canceled {
      appleCompletion?(.failure(error))
    } else {
      appleCompletion?(.cancellation)
    }
  }
}

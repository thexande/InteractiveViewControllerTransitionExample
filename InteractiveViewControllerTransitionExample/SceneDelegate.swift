import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = scene as? UIWindowScene else {
            return assertionFailure("Scene is not of type `UIWindowScene`")
        }

        let window = UIWindow(windowScene: scene)
        window.rootViewController = UINavigationController(rootViewController: RootViewController())
        self.window = window
        window.makeKeyAndVisible()
    }
}

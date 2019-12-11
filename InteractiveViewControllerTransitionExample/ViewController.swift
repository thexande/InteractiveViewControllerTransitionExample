import UIKit

final class RootViewController: UIViewController {

    private let button = UIButton()
    private let presentationCoordinator = CardPresentationCoordinator()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Payments"
        view.backgroundColor = .systemBackground
        view.addSubview(button)

        button.backgroundColor = .systemBlue
        button.setTitle("Present Modal", for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(presentModal), for: .touchUpInside)

        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-36-[button]-36-|",
                                                                   options: [],
                                                                   metrics: nil,
                                                                   views: ["button":button]))
        NSLayoutConstraint.activate([.init(item: button,
                                           attribute: .centerY,
                                           relatedBy: .equal,
                                           toItem: view,
                                           attribute: .centerY, multiplier: 1, constant: 0),
                                     .init(item: button,
                                           attribute: .height,
                                           relatedBy: .equal,
                                           toItem: nil,
                                           attribute: .notAnAttribute,
                                           multiplier: 1,
                                           constant: 60)])
    }

    @objc private func presentModal() {
        let modal = ModalViewController()
        modal.presentationCoordinator = presentationCoordinator
        modal.modalPresentationStyle = .currentContext
        modal.transitioningDelegate = self
        present(modal, animated: true)
    }
}

extension RootViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CardModalDismissAnimator()
    }

    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return presentationCoordinator.hasStartedInteraction ? presentationCoordinator : nil
    }

    public func animationController(forPresented presented: UIViewController,
                                    presenting: UIViewController,
                                    source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CardModalPresentAnimator()
    }
}


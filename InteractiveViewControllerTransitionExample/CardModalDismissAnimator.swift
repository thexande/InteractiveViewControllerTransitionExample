import UIKit

final class CardModalDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    private let dimmingOverlayView = UIView()

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let originViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let destinationViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            else { return }

        transitionContext.containerView.insertSubview(destinationViewController.view, belowSubview: originViewController.view)

        let containerView = transitionContext.containerView
        let screenSize = UIScreen.main.bounds.size
        let bottomLeftCorner = CGPoint(x: 0, y: screenSize.height)
        let finalFrame = CGRect(origin: bottomLeftCorner, size: screenSize)
        dimmingOverlayView.backgroundColor = .clear

        containerView.insertSubview(dimmingOverlayView, belowSubview: originViewController.view)

        let views = ["dimmingOverlay": dimmingOverlayView]
        dimmingOverlayView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[dimmingOverlay]|",
                                                                   options: [],
                                                                   metrics: nil,
                                                                   views: views))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[dimmingOverlay]|",
                                                                   options: [],
                                                                   metrics: nil,
                                                                   views: views))

        dimmingOverlayView.backgroundColor = UIColor.black.withAlphaComponent(0.6)

        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       animations: {
                        originViewController.view.frame = finalFrame
                        self.dimmingOverlayView.backgroundColor = .clear
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}

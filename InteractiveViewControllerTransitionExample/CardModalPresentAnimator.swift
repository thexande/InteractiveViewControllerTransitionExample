import UIKit

public final class CardModalPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    private let dimmingOverlayView = UIView()

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let originViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let destinationViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            else { return }

        let containerView = transitionContext.containerView
        containerView.insertSubview(destinationViewController.view, aboveSubview: originViewController.view)
        destinationViewController.view.center.y += UIScreen.main.bounds.height
        guard let snapshot = originViewController.view.snapshotView(afterScreenUpdates: false) else { return }
        containerView.insertSubview(snapshot, belowSubview: destinationViewController.view)

        containerView.insertSubview(dimmingOverlayView, belowSubview: destinationViewController.view)
        dimmingOverlayView.backgroundColor = .clear
        dimmingOverlayView.translatesAutoresizingMaskIntoConstraints = false

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

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            destinationViewController.view.center.y = UIScreen.main.bounds.height / 2
            self.dimmingOverlayView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        }, completion: { _ in
            transitionContext.completeTransition(transitionContext.transitionWasCancelled == false)
        })
    }
}


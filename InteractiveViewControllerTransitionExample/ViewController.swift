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

public final class CardPresentationCoordinator: UIPercentDrivenInteractiveTransition {
    public var hasStartedInteraction = false
    public var shouldFinishTransition = false
}


final class ModalViewController: UIViewController {

    var presentationCoordinator: CardPresentationCoordinator?
    private let content = UIView()
    private let qr = UIView()


    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self,
                                                         action: #selector(handleGesture(_:))))

        qr.backgroundColor = .black
        qr.layer.cornerRadius = 26
        content.backgroundColor = .systemBackground

        view.addSubview(content)
        content.addSubview(qr)
        [content, qr].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        let views = ["content": content]
        NSLayoutConstraint.activate([
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-300-[content]|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: views),
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[content]|",
                                           options: [],
                                           metrics: nil,
                                           views: views),
            [
                .init(item: qr,
                      attribute: .centerX,
                      relatedBy: .equal,
                      toItem: content,
                      attribute: .centerX,
                      multiplier: 1,
                      constant: 0),
                .init(item: qr,
                      attribute: .centerY,
                      relatedBy: .equal,
                      toItem: content,
                      attribute: .centerY,
                      multiplier: 1,
                      constant: 0),
                .init(item: qr,
                      attribute: .height,
                      relatedBy: .equal,
                      toItem: nil,
                      attribute: .notAnAttribute,
                      multiplier: 1,
                      constant: 200),
                .init(item: qr,
                      attribute: .width,
                      relatedBy: .equal,
                      toItem: nil,
                      attribute: .notAnAttribute,
                      multiplier: 1,
                      constant: 200),
            ]
        ].flatMap { $0 })
    }

    @objc private func handleGesture(_ sender: UIPanGestureRecognizer) {
        let percentThreshold: CGFloat = 0.2
        let translation = sender.translation(in: view)
        let verticalMovement = translation.y / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)

        guard let presentationCoordinator = presentationCoordinator else { return }

        switch sender.state {
        case .began:
            presentationCoordinator.hasStartedInteraction = true
            dismiss(animated: true, completion: nil)
        case .changed:
            presentationCoordinator.shouldFinishTransition = progress > percentThreshold
            presentationCoordinator.update(progress)
        case .cancelled:
            presentationCoordinator.hasStartedInteraction = false
            presentationCoordinator.cancel()
        case .ended:
            presentationCoordinator.hasStartedInteraction = false
            if presentationCoordinator.shouldFinishTransition {
                presentationCoordinator.finish()
            }
            else {
                presentationCoordinator.cancel()
            }
        default:
            break
        }
    }
}


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

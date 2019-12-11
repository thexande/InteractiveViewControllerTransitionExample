import UIKit

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


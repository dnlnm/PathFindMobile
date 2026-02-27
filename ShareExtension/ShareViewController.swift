import SwiftUI
import UIKit
import UniformTypeIdentifiers

class ShareViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(red: 0.07, green: 0.08, blue: 0.12, alpha: 1)
    // Tell the system container how tall we want to be
    preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: 400)

    extractURL { [weak self] url, title in
      guard let self else { return }
      DispatchQueue.main.async {
        guard let url else {
          self.close()
          return
        }
        self.embedShareView(url: url, title: title)
      }
    }
  }

  private func embedShareView(url: URL, title: String?) {
    let shareView = ShareView(
      url: url.absoluteString,
      title: title,
      onDismiss: { [weak self] in self?.close() }
    )

    let hostingVC = UIHostingController(rootView: shareView)
    hostingVC.view.backgroundColor = .clear

    addChild(hostingVC)
    view.addSubview(hostingVC.view)
    hostingVC.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      hostingVC.view.topAnchor.constraint(equalTo: view.topAnchor),
      hostingVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      hostingVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      hostingVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
    hostingVC.didMove(toParent: self)
  }

  private func extractURL(completion: @escaping (URL?, String?) -> Void) {
    guard let extensionItems = extensionContext?.inputItems as? [NSExtensionItem] else {
      completion(nil, nil)
      return
    }

    var foundURL: URL?
    var foundTitle: String?
    let group = DispatchGroup()

    for item in extensionItems {
      if let text = item.attributedContentText?.string, !text.isEmpty {
        foundTitle = text
      }
      for provider in item.attachments ?? [] {
        if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
          group.enter()
          provider.loadItem(forTypeIdentifier: UTType.url.identifier) { item, _ in
            if let url = item as? URL { foundURL = url }
            group.leave()
          }
        } else if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
          group.enter()
          provider.loadItem(forTypeIdentifier: UTType.plainText.identifier) { item, _ in
            if let text = item as? String,
              let url = URL(string: text),
              url.scheme?.hasPrefix("http") == true
            {
              foundURL = url
            }
            group.leave()
          }
        }
      }
    }

    group.notify(queue: .main) { completion(foundURL, foundTitle) }
  }

  private func close() {
    extensionContext?.completeRequest(returningItems: nil)
  }
}

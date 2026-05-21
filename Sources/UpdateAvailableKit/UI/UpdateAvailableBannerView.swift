#if canImport(SwiftUI) && canImport(UIKit)
import SwiftUI
import UIKit

public struct UpdateAvailableBannerView: View {
    private let newVersion: String?
    private let theme: UpdateAvailableBannerTheme
    private let appStoreID: String?
    private let onTap: (() -> Void)?
    private let onDismiss: (() -> Void)?

    public init(
        result: UpdateAvailableResult,
        theme: UpdateAvailableBannerTheme = .default,
        appStoreID: String? = nil,
        onTap: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        switch result {
        case .updateAvailable(let newVersion):
            self.newVersion = newVersion
        case .noUpdatesAvailable:
            self.newVersion = nil
        }
        self.theme = theme
        self.appStoreID = appStoreID
        self.onTap = onTap
        self.onDismiss = onDismiss
    }

    public init(
        newVersion: String?,
        theme: UpdateAvailableBannerTheme = .default,
        appStoreID: String? = nil,
        onTap: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.newVersion = newVersion
        self.theme = theme
        self.appStoreID = appStoreID
        self.onTap = onTap
        self.onDismiss = onDismiss
    }

    public var body: some View {
        if let version = newVersion {
            VStack(spacing: 0) {
                Button {
                    openAppStore()
                    onTap?()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: theme.iconName)
                            .font(.title2)
                            .foregroundStyle(theme.titleColor)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Update Available")
                                .font(.headline)
                                .foregroundStyle(theme.titleColor)

                            Text("Version \(version) is now available")
                                .font(.caption)
                                .foregroundStyle(theme.subtitleColor)
                        }

                        Spacer(minLength: 8)

                        Text(theme.buttonTitle)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(theme.buttonTitleColor)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(theme.buttonColor, in: Capsule())
                            .modifier(GlassEffectFallbackModifier())

                        if onDismiss != nil {
                            Button {
                                onDismiss?()
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(theme.subtitleColor)
                            }
 
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                Divider()
            }
            .modifier(GlassBannerBackgroundModifier(fallbackColor: theme.backgroundColor))
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    private func openAppStore() {
        let id = appStoreID ?? Bundle.main.bundleIdentifier ?? ""
        guard let url = URL(string: "https://apps.apple.com/app/id\(id)") else {
            return
        }
        UIApplication.shared.open(url)
    }
}

private struct GlassBannerBackgroundModifier: ViewModifier {
    let fallbackColor: Color

    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .glassEffect()
        } else {
            content
                .background(fallbackColor)
        }
    }
}

private struct GlassEffectFallbackModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .glassEffect()
        } else {
            content
        }
    }
}

#if DEBUG
@available(iOS 17, *)
#Preview("Update Available") {
    VStack {
        UpdateAvailableBannerView(
            newVersion: "2.1.0",
            appStoreID: "123456789"
        )
    }
    .preferredColorScheme(.dark)
}

@available(iOS 17, *)
#Preview("Custom Theme") {
    VStack {
        Spacer()
        UpdateAvailableBannerView(
            newVersion: "3.0.0",
            theme: UpdateAvailableBannerTheme(
                backgroundColor: .orange.opacity(0.15),
                titleColor: .orange,
                iconName: "star.fill",
                buttonTitle: "Get Update",
                buttonColor: .orange
            ),
            appStoreID: "123456789"
        )
    }
    .preferredColorScheme(.dark)
}
#endif
#endif

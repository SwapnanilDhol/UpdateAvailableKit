#if canImport(SwiftUI) && canImport(UIKit)
import SwiftUI

public extension View {
    @ViewBuilder
    func updateAvailableBanner(
        version: Binding<String?>,
        appStoreID: String,
        theme: UpdateAvailableBannerTheme = .default,
        onTap: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        self.safeAreaInset(edge: .top, spacing: 0) {
            UpdateAvailableBannerView(
                newVersion: version.wrappedValue,
                theme: theme,
                appStoreID: appStoreID,
                onTap: onTap,
                onDismiss: {
                    version.wrappedValue = nil
                    onDismiss?()
                }
            )
        }
        .animation(.easeInOut, value: version.wrappedValue)
    }
}

#if DEBUG
@available(iOS 17, *)
#Preview {
    @Previewable @State var version: String? = "2.1.0"

    NavigationStack {
        List {
            Text("Content")
        }
        .navigationTitle("App")
        .navigationBarTitleDisplayMode(.inline)
        .updateAvailableBanner(
            version: $version,
            appStoreID: "123456789"
        )
    }
}
#endif
#endif

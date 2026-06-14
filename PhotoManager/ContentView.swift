import SwiftUI
import Photos
import UIKit

struct ContentView: View {
    @StateObject private var viewModel = PhotosHideManager()
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                Group {
                    if viewModel.canAccessLibrary {
                        VStack(spacing: 14) {
                            titleHeader
                            actionCard
                            topCard
                            if viewModel.isProcessing {
                                processingCard
                            }
                            Spacer(minLength: 28)
                            hideButton
                        }
                        .padding()
                    } else {
                        VStack(spacing: 14) {
                            titleHeader
                            accessRequiredView
                            Spacer(minLength: 0)
                        }
                        .padding()
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .task {
                viewModel.refreshAuthorizationStatus()
                if viewModel.canAccessLibrary {
                    viewModel.refreshPhotoCounts()
                }
            }
            .onChange(of: scenePhase) { newPhase in
                guard newPhase == .active else { return }
                viewModel.refreshAuthorizationStatus()
                if viewModel.canAccessLibrary {
                    viewModel.refreshPhotoCounts()
                }
            }
        }
    }

    private var titleHeader: some View {
        VStack(spacing: 8) {
            Image(systemName: "photo.stack.fill")
                .font(.system(size: 56, weight: .bold))
                .foregroundStyle(.blue)
            VStack(spacing: 8) {
                Text("Hide Photos")
                    .font(.system(size: 36, weight: .semibold, design: .default))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)

                Text("by date")
                    .font(.system(size: 15, weight: .semibold, design: .default))
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color.blue.opacity(0.12))
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 56)
        .padding(.bottom, 14)
    }

    private var topCard: some View {
        VStack(spacing: 8) {
            Text(counterText)
                .font(.headline)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color(uiColor: .secondarySystemGroupedBackground)))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color(uiColor: .separator).opacity(0.35), lineWidth: 1))
    }

    private var processingCard: some View {
        VStack(spacing: 8) {
            ProgressView("Hiding media...")
                .tint(.blue)
            Text("Processed: \(viewModel.processedCount)")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color(uiColor: .secondarySystemGroupedBackground)))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color(uiColor: .separator).opacity(0.35), lineWidth: 1))
    }

    private var counterText: String {
        if viewModel.selectedScope == .allVisible {
            return "Hide \(viewModel.matchingPhotosCount) medias"
        }
        return "Hide \(viewModel.matchingPhotosCount) medias out of \(viewModel.visiblePhotosCount)"
    }

    private var accessRequiredView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Permission Required")
                .font(.title3.bold())
                .foregroundStyle(.primary)
            Text("To count and hide media, allow access to your library.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button("Request Media Access") {
                viewModel.requestPhotoAccess()
            }
            .buttonStyle(.bordered)
            .tint(.blue)
            .frame(maxWidth: .infinity)

            if viewModel.shouldShowSettingsButton {
                Button("Open iOS Settings") {
                    guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                    openURL(settingsURL)
                }
                .buttonStyle(.bordered)
                .tint(.blue)
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color(uiColor: .secondarySystemGroupedBackground)))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color(uiColor: .separator).opacity(0.35), lineWidth: 1))
    }

    private var actionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Text("Hide filter")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Spacer()
                Picker("Filter", selection: $viewModel.selectedScope) {
                    ForEach(PhotosHideManager.HideScope.allCases) { scope in
                        Text(scope.label).tag(scope)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
                .tint(.blue)
            }

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color(uiColor: .secondarySystemGroupedBackground)))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color(uiColor: .separator).opacity(0.35), lineWidth: 1))
    }

    private var hideButton: some View {
        Button("Hide") {
            Task {
                await viewModel.hideSelectedScope()
            }
        }
        .font(.system(size: 24, weight: .semibold, design: .default))
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, minHeight: 68)
        .background(
            LinearGradient(
                colors: [Color(red: 0.17, green: 0.46, blue: 0.98), Color(red: 0.08, green: 0.30, blue: 0.78)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.white.opacity(0.22), lineWidth: 1))
        .shadow(color: Color.black.opacity(0.35), radius: 12, x: 0, y: 8)
        .disabled(!viewModel.canHidePhotos)
        .opacity(viewModel.canHidePhotos ? 1 : 0.55)
    }

}

@MainActor
final class PhotosHideManager: ObservableObject {
    enum HideScope: String, CaseIterable, Identifiable {
        case allVisible
        case lastHour
        case yesterdayAndToday
        case today
        case lastWeek

        var id: String { rawValue }

        var label: String {
            switch self {
            case .allVisible: return "All visible"
            case .lastHour: return "Last hour"
            case .yesterdayAndToday: return "Yesterday + Today"
            case .today: return "Today"
            case .lastWeek: return "Last week"
            }
        }

        var detail: String {
            switch self {
            case .allVisible: return "Hide all visible media in the library."
            case .lastHour: return "Hide media created in the last hour."
            case .yesterdayAndToday: return "Hide media created yesterday and today."
            case .today: return "Hide media created today."
            case .lastWeek: return "Hide media created in the last 7 days."
            }
        }
    }

    @Published var visiblePhotosCount = 0
    @Published var matchingPhotosCount = 0
    @Published var isProcessing = false
    @Published var processedCount = 0
    @Published var statusMessage = "Grant access to manage media."
    @Published var selectedScope: HideScope = .allVisible {
        didSet {
            refreshMatchingPhotosCount()
        }
    }
    @Published private(set) var authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)

    var canAccessLibrary: Bool {
        authorizationStatus == .authorized || authorizationStatus == .limited
    }

    var canHidePhotos: Bool {
        canAccessLibrary && !isProcessing && matchingPhotosCount > 0
    }

    var shouldShowSettingsButton: Bool {
        authorizationStatus == .denied || authorizationStatus == .restricted
    }

    func refreshAuthorizationStatus() {
        authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        updateStatusForAuthorization()
    }

    func requestPhotoAccess() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            Task { @MainActor in
                guard let self else { return }
                self.authorizationStatus = status
                self.updateStatusForAuthorization()
                if self.canAccessLibrary {
                    self.refreshPhotoCounts()
                }
            }
        }
    }

    func refreshPhotoCounts() {
        refreshVisiblePhotosCount()
        refreshMatchingPhotosCount()
    }

    func hideSelectedScope() async {
        guard canAccessLibrary else {
            updateStatusForAuthorization()
            return
        }

        let identifiers = Self.identifiers(for: selectedScope)
        guard !identifiers.isEmpty else {
            processedCount = 0
            matchingPhotosCount = 0
            statusMessage = "There is no media to hide for the selected filter."
            return
        }

        isProcessing = true
        processedCount = 0
        statusMessage = "Starting hide for '\(selectedScope.label)'..."

        do {
            try await Self.hideBatch(localIdentifiers: identifiers)
            processedCount = identifiers.count
            isProcessing = false
            refreshPhotoCounts()
            statusMessage = "Done. \(processedCount) items were moved to Hidden."
        } catch {
            isProcessing = false
            statusMessage = "Failed to hide media: \(error.localizedDescription)"
        }
    }

    private func refreshVisiblePhotosCount() {
        guard canAccessLibrary else {
            visiblePhotosCount = 0
            return
        }
        visiblePhotosCount = Self.fetchVisiblePhotos().count
    }

    private func refreshMatchingPhotosCount() {
        guard canAccessLibrary else {
            matchingPhotosCount = 0
            return
        }
        matchingPhotosCount = Self.count(for: selectedScope)
        if !isProcessing {
            statusMessage = "Filter '\(selectedScope.label)' has \(matchingPhotosCount) items."
        }
    }

    private func updateStatusForAuthorization() {
        switch authorizationStatus {
        case .authorized, .limited:
            statusMessage = "Permission granted. Select a filter and run hide."
        case .notDetermined:
            statusMessage = "Tap 'Request Media Access' to continue."
        case .denied:
            statusMessage = "Access denied. Open iOS Settings to allow it."
        case .restricted:
            statusMessage = "Access is restricted by the system."
        @unknown default:
            statusMessage = "Unknown permission status."
        }
    }

    private static func count(for scope: HideScope) -> Int {
        switch scope {
        case .allVisible:
            return fetchVisiblePhotos().count
        case .lastHour:
            let start = Date().addingTimeInterval(-3600)
            return fetchVisiblePhotos(startDate: start).count
        case .yesterdayAndToday:
            let start = Calendar.current.date(byAdding: .day, value: -1, to: Calendar.current.startOfDay(for: Date())) ?? Date()
            return fetchVisiblePhotos(startDate: start).count
        case .today:
            let start = Calendar.current.startOfDay(for: Date())
            return fetchVisiblePhotos(startDate: start).count
        case .lastWeek:
            let start = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            return fetchVisiblePhotos(startDate: start).count
        }
    }

    private static func identifiers(for scope: HideScope) -> [String] {
        let fetchResult: PHFetchResult<PHAsset>
        switch scope {
        case .allVisible:
            fetchResult = fetchVisiblePhotos()
        case .lastHour:
            let start = Date().addingTimeInterval(-3600)
            fetchResult = fetchVisiblePhotos(startDate: start)
        case .yesterdayAndToday:
            let start = Calendar.current.date(byAdding: .day, value: -1, to: Calendar.current.startOfDay(for: Date())) ?? Date()
            fetchResult = fetchVisiblePhotos(startDate: start)
        case .today:
            let start = Calendar.current.startOfDay(for: Date())
            fetchResult = fetchVisiblePhotos(startDate: start)
        case .lastWeek:
            let start = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            fetchResult = fetchVisiblePhotos(startDate: start)
        }

        var identifiers: [String] = []
        identifiers.reserveCapacity(fetchResult.count)
        fetchResult.enumerateObjects { asset, _, _ in
            identifiers.append(asset.localIdentifier)
        }
        return identifiers
    }

    private static func fetchVisiblePhotos(
        startDate: Date? = nil,
        endDate: Date? = nil,
        limit: Int = 0
    ) -> PHFetchResult<PHAsset> {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        if limit > 0 {
            options.fetchLimit = limit
        }

        let mediaPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue),
            NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
        ])

        var predicates: [NSPredicate] = [
            mediaPredicate,
            NSPredicate(format: "hidden == NO")
        ]
        if let startDate {
            predicates.append(NSPredicate(format: "creationDate >= %@", startDate as NSDate))
        }
        if let endDate {
            predicates.append(NSPredicate(format: "creationDate <= %@", endDate as NSDate))
        }
        options.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        return PHAsset.fetchAssets(with: options)
    }

    private static func hideBatch(localIdentifiers: [String]) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.shared().performChanges({
                localIdentifiers.forEach { identifier in
                    let result = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
                    guard let asset = result.firstObject else { return }
                    let request = PHAssetChangeRequest(for: asset)
                    request.isHidden = true
                }
            }, completionHandler: { success, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                if success {
                    continuation.resume(returning: ())
                } else {
                    continuation.resume(throwing: NSError(
                        domain: "PhotoManager",
                        code: 1,
                        userInfo: [NSLocalizedDescriptionKey: "A operacao foi cancelada."]
                    ))
                }
            })
        }
    }
}

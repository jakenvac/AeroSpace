import SwiftUI
import AppBundle

@main
struct AeroSpaceApp: App {
    @StateObject var viewModel = TrayMenuModel.shared

    init() {
        initAppBundle()
    }

    var body: some Scene {
        menuBar(viewModel: viewModel)
    }
}

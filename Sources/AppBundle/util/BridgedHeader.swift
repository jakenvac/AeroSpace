import Foundation
import AppKit
import PrivateAPIBridge

// Alternative:
// @_silgen_name("_AXUIElementGetWindow")
// @discardableResult
// func _AXUIElementGetWindow(_ axUiElement: AXUIElement, _ id: inout CGWindowID) -> AXError
public protocol BridgedHeader {
    func containingWindowId(_ ax: AXUIElement) -> CGWindowID?
}

struct BridgedHeaderImpl: BridgedHeader {
    func containingWindowId(_ ax: AXUIElement) -> CGWindowID? {
        var cgWindowId = CGWindowID()
        return _AXUIElementGetWindow(ax, &cgWindowId) == .success ? cgWindowId : nil
    }
}

public var _bridgedHeader: BridgedHeader? = BridgedHeaderImpl()
public var bridgedHeader: BridgedHeader { _bridgedHeader! }

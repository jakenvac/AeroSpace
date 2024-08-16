import Foundation
import Common

public func initAppBundle() {
    initTerminationHandler()
    isCli = false
    initServerArgs()
    if isDebug {
        sendCommandToReleaseServer(args: ["enable", "off"])
        interceptTermination(SIGINT)
        interceptTermination(SIGKILL)
    }
    if !reloadConfig() {
        check(reloadConfig(forceConfigUrl: defaultConfigUrl))
    }
    if serverArgs.startedAtLogin && !config.startAtLogin {
        terminateApp()
    }

    checkAccessibilityPermissions()
    startServer()
    GlobalObserver.initObserver()
    refreshAndLayout(startup: true)
    refreshSession {
        let state: CommandMutableState = .focused
        if serverArgs.startedAtLogin {
            _ = config.afterLoginCommand.run(state)
        }
        _ = config.afterStartupCommand.run(state)
    }
}

struct ServerArgs {
    var startedAtLogin = false
    var configLocation: String? = nil
}

private let serverHelp = """
USAGE: \(CommandLine.arguments.first ?? "AeroSpace.app/Contents/MacOS/AeroSpace") [<options>]

OPTIONS:
  -h, --help              Print help
  -v, --version           Print AeroSpace.app version
  --started-at-login      Make AeroSpace.app think that it is started at login
                          When AeroSpace.app starts at login it runs 'after-login-command' commands
  --config-path <path>    Config path. It will take priority over ~/.aerospace.toml
                          and ${XDG_CONFIG_HOME}/aerospace/aerospace.toml
"""

var serverArgs = ServerArgs()
private func initServerArgs() {
    var args: [String] = Array(CommandLine.arguments.dropFirst())
    if args.contains(where: { $0 == "-h" || $0 == "--help" }) {
        print(serverHelp)
        exit(0)
    }
    while !args.isEmpty {
        switch args.first {
            case "--version", "-v":
                print("\(aeroSpaceAppVersion) \(gitHash)")
                exit(0)
            case "--config-path":
                if let arg = args.getOrNil(atIndex: 1) {
                    serverArgs.configLocation = arg
                } else {
                    cliError("Missing <path> in --config-path flag")
                }
                args = Array(args.dropFirst(2))
            case "--started-at-login":
                serverArgs.startedAtLogin = true
                args = Array(args.dropFirst())
            case "-NSDocumentRevisionsDebugMode": // Freaking Xcode adds this stupid argument. Ignore it
                if isDebug {
                    if args.getOrNil(atIndex: 1) != "YES" {
                        cliError("Expecting YES after -NSDocumentRevisionsDebugMode flag")
                    }
                    args = Array(args.dropFirst(2))
                } else {
                    fallthrough
                }
            default:
                cliError("Unrecognized flag '\(args.first!)'")
        }
    }
    if let path = serverArgs.configLocation, !FileManager.default.fileExists(atPath: path) {
        cliError("\(path) doesn't exist")
    }
}

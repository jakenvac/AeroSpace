#!/usr/bin/env bash

# I'd not need this script if `swift run` wasn't that damn slow compared to `swift build`!
# https://forums.swift.org/t/swift-run-really-slow/67807/12
swift build > /dev/null || swift build

./.build/debug/aerospace "$@"

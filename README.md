<div align="center">
  
# 🎾 Rally Snap
**An intelligent iOS and watchOS application that automatically detects tennis shots and generates social-ready match highlights using custom on-device machine learning.**

[![Swift](https://img.shields.io/badge/Swift-FA7343?style=for-the-badge&logo=swift&logoColor=white)](https://swift.org)
[![CoreML](https://img.shields.io/badge/CoreML-000000?style=for-the-badge&logo=apple&logoColor=white)](https://developer.apple.com/documentation/coreml)
[![Vision](https://img.shields.io/badge/Vision-007AFF?style=for-the-badge&logo=apple&logoColor=white)](https://developer.apple.com/documentation/vision)
[![iOS](https://img.shields.io/badge/iOS-16.0%2B-blue?style=for-the-badge&logo=apple&logoColor=white)](https://developer.apple.com/)

</div>

---

## 📖 Overview
**Rally Snap** is an advanced iOS application built to solve the tedious process of editing sports footage. By leveraging Apple's CoreML and Vision frameworks, the app processes raw tennis match recordings on-device, identifies key scoring moments, and condenses lengthy matches into short, high-energy highlight clips ready for social media.

## 📸 Screenshots

<div align="center">
  <img src="[URL_TO_MAIN_APP_SCREEN]" width="220" alt="Main App Interface">
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="[URL_TO_HIGHLIGHT_VIEW]" width="220" alt="Highlight Generation">
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="[URL_TO_WATCH_APP]" width="220" alt="Apple Watch Companion">
</div>

## ✨ Key Features
* **AI-Powered Action Recognition:** Utilizes Apple's action classifier model via CoreML to automatically detect tennis shots from raw video footage.
* **Buffer Window Inference Pipeline:** Engineered with a specialized buffer window mechanism to handle continuous video frames smoothly, ensuring accurate temporal processing and action recognition.
* **Automated Video Condensing:** Automatically transforms lengthy 20-minute matches into crisp, 10-second social-media-ready highlight reels.
* **⌚ Apple Watch Companion App:** Features a dedicated watchOS companion app with a simple button, allowing players to manually trigger and bookmark clipping moments on the fly as a backup.

## 🛠 Tech Stack
* **Language:** Swift
* **AI & Machine Learning:** CoreML, Vision Framework
* **Companion Integration:** watchOS, WatchConnectivity
* **UI Framework:** SwiftUI

## 🚀 Getting Started

### Prerequisites
* Mac running macOS 13.0 or later
* Xcode 15.0 or later
* iPhone and Apple Watch running iOS 16.0+ / watchOS 9.0+ (Physical devices recommended for real-time camera and CoreML performance)

### Installation
1. Clone the repository:
   ```bash
   git clone [https://github.com/pisciva/RallySnap.git](https://github.com/pisciva/RallySnap.git)

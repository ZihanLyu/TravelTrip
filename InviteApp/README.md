# InviteApp

A SwiftUI app for **macOS** and **iOS** with login, auto-registration, and invite links you can copy and share to any platform.

## Features

- **Login** — Clean login interface with email and display name
- **Auto-registration** — First-time users are automatically registered (no sign-up step)
- **Invite tab** — Your unique invite link and code; copy to clipboard or share via system share sheet
- **Share anywhere** — Links work for Messages, WhatsApp, Twitter, Email, Slack, etc.
- **Profile** — View account info and sign out

## Setup in Xcode

1. **Create a new project**
   - File → New → Project
   - Choose **App** (under iOS or macOS)
   - Product Name: `InviteApp`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Uncheck "Include Tests" if you want to keep it minimal

2. **Add the second platform**
   - File → New → Target
   - Choose **App** for the other platform (iOS or macOS)
   - Name it `InviteApp (macOS)` or `InviteApp (iOS)` as needed
   - Or create one project per platform and add the shared source files to both

3. **Add these files to your project**
   - Drag the entire `InviteApp` folder into Xcode
   - Ensure all `.swift` files are added to both targets (iOS and macOS)
   - Replace the default `ContentView` and `InviteAppApp` with these versions

4. **File structure to add**
   ```
   InviteApp/
   ├── InviteAppApp.swift      (replace default)
   ├── Models/
   │   ├── AuthManager.swift
   │   └── User.swift
   ├── Views/
   │   ├── RootView.swift
   │   ├── MainTabView.swift
   │   ├── Login/
   │   │   └── LoginView.swift
   │   ├── Home/
   │   │   └── HomeView.swift
   │   ├── Invite/
   │   │   └── InviteView.swift
   │   └── Profile/
   │       └── ProfileView.swift
   ```

5. **Build and run** — Select your target (iPhone Simulator or My Mac) and run.

## Invite Link Format

Links use the format: `https://invite.app/join/YOUR_CODE`

Replace `invite.app` with your actual domain when you deploy a web landing page. The code is unique per user.

## Requirements

- Xcode 15+ (SwiftUI, iOS 17+ / macOS 14+)
- Swift 5.9+

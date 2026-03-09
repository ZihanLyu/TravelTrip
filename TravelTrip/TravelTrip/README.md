# TravelTrip — Team 8

**Team:** Jay Xiao, Geneva Guo, Zihan Lyu, Jiaqi Yu, Jonathan He

SwiftUI app for **macOS** and **iOS** — group trip planner for organizers and ridealong travelers.

## Features (from Prototype Doc)

| Feature | Description |
|---------|-------------|
| **Centralized Discovery Feed** | Add TikTok, Instagram Reels, Google Maps links → parsed into shared Interest List |
| **Anonymous Preference Polling** | Vote on dates/destinations with optional hidden identity |
| **Transparent Budget Snapshot** | Real-time cost dashboard including rideshare, meals, tips |
| **10-Minute Decision Notification** | Deal alerts with Approve/Reject for volatile flight/hotel deals |
| **Invite Links** | Copy/share trip invite links to any platform |
| **Auto-registration** | First-time users registered automatically |

## Setup in Xcode

1. **File → New → Project** → **App** (iOS or macOS)
2. Product Name: `TravelTrip`
3. Interface: **SwiftUI**, Language: **Swift**
4. Drag the `TravelTrip` folder into the project
5. Add both iOS and macOS targets if desired
6. Build and run

## File Structure

```
TravelTrip/
├── TravelTripApp.swift
├── Models/
│   ├── AuthManager.swift
│   ├── Trip.swift
│   ├── TripManager.swift
│   ├── Interest.swift
│   ├── Poll.swift
│   ├── BudgetItem.swift
│   └── Deal.swift
├── Views/
│   ├── RootView.swift
│   ├── CreateOrJoinTripView.swift
│   ├── MainTabView.swift
│   ├── Login/LoginView.swift
│   ├── Discovery/DiscoveryView.swift
│   ├── Polls/PollView.swift
│   ├── Budget/BudgetView.swift
│   ├── Deals/DealsView.swift
│   ├── Invite/InviteView.swift
│   └── Profile/ProfileView.swift
└── README.md
```

## Prototype Notes

- **No backend** — data stored locally (UserDefaults). Joining with a code creates a local trip for demo use.
- **Invite link format:** `https://traveltrip.app/join/CODE` — replace domain when deploying.
- Requires Xcode 15+, iOS 17+ / macOS 14+.

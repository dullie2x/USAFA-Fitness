//  USAFA_FitnessApp.swift
//  USAFA Fitness
//
//  Created by Abdulmalik Ariyo on 5/14/23.

import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency

@main
struct USAFA_FitnessApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var history = FitnessHistory()
    @StateObject private var reviewPrompter = ReviewPrompter()
    @State private var showSplash = true
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashPage()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showSplash = false
                            }
                            appDelegate.splashDidFinish()
                            // Don't stack the rating prompt on top of an app open ad
                            reviewPrompter.recordAppOpen(allowPrompt: !appDelegate.shouldShowAdThisLaunch)
                        }
                    }
            } else {
                MainTabView()
                    .environmentObject(history)
                    .environmentObject(reviewPrompter)
            }
        }
        .onChange(of: scenePhase) { _, phase in
            // Returning from the background on a new day counts as an open
            if phase == .active && !showSplash {
                reviewPrompter.recordAppOpen()
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, FullScreenContentDelegate {
    var appOpenAd: AppOpenAd?

    //let adUnitID = "ca-app-pub-3940256099942544/5575463023"
    let adUnitID = "ca-app-pub-3883739672732267/2035754329"

    // MARK: - Ad frequency
    /// Never on a user's first launch, then on every Nth launch after that.
    private let launchesBetweenAds = 3
    /// If the ad isn't ready this soon after the splash, skip it so it doesn't
    /// interrupt someone who's already using the app.
    private let maxAdWaitSeconds: TimeInterval = 3
    private let launchCountKey = "ad_launchCount"
    private var adRequestedAt: Date?

    var shouldShowAdThisLaunch: Bool {
        let launches = UserDefaults.standard.integer(forKey: launchCountKey)
        return launches > 1 && (launches - 1) % launchesBetweenAds == 0
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let launches = UserDefaults.standard.integer(forKey: launchCountKey) + 1
        UserDefaults.standard.set(launches, forKey: launchCountKey)

        MobileAds.shared.start(completionHandler: nil)
        //GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "4da0971c9044fbe31d76acce10046d83" ]
        return true
    }

    /// Called once the splash screen is gone: ask for tracking permission (first time only),
    /// then load and show the app open ad if this launch qualifies.
    func splashDidFinish() {
        ATTrackingManager.requestTrackingAuthorization { [weak self] _ in
            DispatchQueue.main.async {
                guard let self, self.shouldShowAdThisLaunch else { return }
                self.loadAd()
            }
        }
    }

    func loadAd() {
        adRequestedAt = Date()
        let request = Request()
        // Updated API for loading app open ads in SDK 12.2
        AppOpenAd.load(with: adUnitID,
                      request: request) { [weak self] ad, error in
            guard let self = self else { return }

            if let error = error {
                print("Failed to load app open ad: \(error)")
                return
            }

            // Too slow — the user is already in the app, so don't interrupt them
            if let requestedAt = self.adRequestedAt,
               Date().timeIntervalSince(requestedAt) > self.maxAdWaitSeconds {
                return
            }

            self.appOpenAd = ad
            self.appOpenAd?.fullScreenContentDelegate = self

            // Updated way to get root view controller
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController,
               let ad = self.appOpenAd {
                ad.present(from: rootViewController)
            }
        }
    }

    // GADFullScreenContentDelegate methods
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        appOpenAd = nil
    }
}

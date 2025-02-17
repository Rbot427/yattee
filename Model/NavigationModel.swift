import Foundation
import SwiftUI

final class NavigationModel: ObservableObject {
    enum TabSelection: Hashable {
        case favorites
        case subscriptions
        case popular
        case trending
        case playlists
        case channel(String)
        case playlist(String)
        case recentlyOpened(String)
        case nowPlaying
        case search

        var playlistID: Playlist.ID? {
            if case let .playlist(id) = self {
                return id
            }

            return nil
        }
    }

    @Published var tabSelection: TabSelection!

    @Published var presentingAddToPlaylist = false
    @Published var videoToAddToPlaylist: Video!

    @Published var presentingPlaylistForm = false
    @Published var editedPlaylist: Playlist!

    @Published var presentingUnsubscribeAlert = false
    @Published var channelToUnsubscribe: Channel!

    @Published var presentingChannel = false
    @Published var presentingPlaylist = false
    @Published var sidebarSectionChanged = false

    @Published var presentingSettings = false
    @Published var presentingWelcomeScreen = false

    static func openChannel(
        _ channel: Channel,
        player: PlayerModel,
        recents: RecentsModel,
        navigation: NavigationModel,
        navigationStyle: NavigationStyle,
        delay: Bool = true
    ) {
        let recent = RecentItem(from: channel)
        #if os(macOS)
            Windows.main.open()
        #else
            player.hide()
        #endif

        let openRecent = {
            recents.add(recent)
            navigation.presentingChannel = true
        }

        if navigationStyle == .tab {
            if delay {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    openRecent()
                }
            } else {
                openRecent()
            }
        } else if navigationStyle == .sidebar {
            openRecent()
            navigation.sidebarSectionChanged.toggle()
            navigation.tabSelection = .recentlyOpened(recent.tag)
        }
    }

    static func openChannelPlaylist(
        _ playlist: ChannelPlaylist,
        player: PlayerModel,
        recents: RecentsModel,
        navigation: NavigationModel,
        navigationStyle: NavigationStyle,
        delay: Bool = false
    ) {
        let recent = RecentItem(from: playlist)
        #if os(macOS)
            Windows.main.open()
        #else
            player.hide()
        #endif

        let openRecent = {
            recents.add(recent)
            navigation.presentingPlaylist = true
        }

        if navigationStyle == .tab {
            if delay {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    openRecent()
                }
            } else {
                openRecent()
            }
        } else if navigationStyle == .sidebar {
            openRecent()
            navigation.sidebarSectionChanged.toggle()
            navigation.tabSelection = .recentlyOpened(recent.tag)
        }
    }

    var tabSelectionBinding: Binding<TabSelection> {
        Binding<TabSelection>(
            get: {
                self.tabSelection ?? .search
            },
            set: { newValue in
                self.tabSelection = newValue
            }
        )
    }

    func presentAddToPlaylist(_ video: Video) {
        videoToAddToPlaylist = video
        presentingAddToPlaylist = true
    }

    func presentEditPlaylistForm(_ playlist: Playlist?) {
        editedPlaylist = playlist
        presentingPlaylistForm = editedPlaylist != nil
    }

    func presentNewPlaylistForm() {
        editedPlaylist = nil
        presentingPlaylistForm = true
    }

    func presentUnsubscribeAlert(_ channel: Channel?) {
        channelToUnsubscribe = channel
        presentingUnsubscribeAlert = channelToUnsubscribe != nil
    }
}

typealias TabSelection = NavigationModel.TabSelection

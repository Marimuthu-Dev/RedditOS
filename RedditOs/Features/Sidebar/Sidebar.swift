//
//  Sidebar.swift
//  RedditOs
//
//  Created by Thomas Ricouard on 08/07/2020.
//

import SwiftUI
import Backend
import SDWebImageSwiftUI

struct Sidebar: View {
    @EnvironmentObject private var localData: PersistedContent
    @EnvironmentObject private var currentUser: CurrentUser
    @StateObject private var viewModel = SidebarViewModel()
    @State private var isSearchPopoverPresented = false
    @State private var isHovered = false
    @State private var isInEditMode = false
    
    var body: some View {
        List(selection: $viewModel.selection) {
            Section {
                ForEach(SidebarViewModel.MainSubreddits.allCases, id: \.self) { item in
                    NavigationLink(destination: SubredditPostsListView(name: item.rawValue)) {
                        Label(LocalizedStringKey(item.rawValue.capitalized), systemImage: item.icon())
                    }.tag(item.rawValue)
                }
            }
             
            Section {
                Text("Account").foregroundColor(.gray)
                NavigationLink(destination: ProfileView()) {
                    Label("Profile", systemImage: "person.crop.square")
                }.tag("profile")
                Label("Inbox", systemImage: "envelope")
                Label("Posts", systemImage: "square.and.pencil")
                Label("Comments", systemImage: "text.bubble")
                Label("Saved", systemImage: "archivebox")
            }.listItemTint(.redditBlue)
            
            Section {
                subredditsHeader.foregroundColor(.gray)
                ForEach(localData.favorites) { reddit in
                    HStack {
                        SidebarSubredditRow(name: reddit.name,
                                            iconURL: reddit.iconImg)
                            .tag("local\(reddit.name)")
                        if isInEditMode {
                            Spacer()
                            Button {
                                localData.favorites.removeAll(where: { $0 == reddit })
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .imageScale(.large)
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                }
            }
            .listItemTint(.redditGold)
            .animation(.easeInOut)
                        
            if let subs = currentUser.subscriptions {
                Section {
                    Text("Subscriptions").foregroundColor(.gray)
                    TextField("Filter", text: $viewModel.subscriptionFilter)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    ForEach(subs) { reddit in
                        HStack {
                            SidebarSubredditRow(name: reddit.displayName,
                                                iconURL: reddit.iconImg)
                                .tag(reddit.displayName)
                            Spacer()
                            if isHovered {
                                let isfavorite = localData.favorites.first(where: { $0.name == reddit.displayName}) != nil
                                Button {
                                    if isfavorite {
                                        localData.favorites.removeAll(where: { $0.name == reddit.displayName })
                                    } else {
                                        localData.favorites.append(SubredditSmall.makeSubredditSmall(with: reddit))
                                    }
                                } label: {
                                    Image(systemName: isfavorite ? "star.fill" : "star")
                                        .imageScale(.large)
                                        .foregroundColor(.yellow)
                                        .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
    
                    }
                }.listItemTint(.redditBlue)
            }
        }
        .listStyle(SidebarListStyle())
        .frame(minWidth: 200, idealWidth: 200, maxWidth: 200, maxHeight: .infinity)
        .onHover { hovered in
            isHovered = hovered
        }
        .padding(.top, 16)
    }
    
    private var subredditsHeader: some View {
        HStack(spacing: 8) {
            Text("Favorites")
            if isHovered {
                Button {
                    isSearchPopoverPresented = true
                } label: {
                    Image(systemName: "plus.circle")
                        .imageScale(.large)
                        .foregroundColor(.blue)
                }
                .buttonStyle(BorderlessButtonStyle())
                .popover(isPresented: $isSearchPopoverPresented) {
                    SearchSubredditsPopover().environmentObject(localData)
                }
                
                Button {
                    isInEditMode.toggle()
                } label: {
                    Image(systemName: isInEditMode ? "trash.circle.fill" : "trash.circle")
                        .imageScale(.large)
                        .foregroundColor(.blue)
                }
                .buttonStyle(BorderlessButtonStyle())
            }

        }
    }
}

struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
        Sidebar()
    }
}

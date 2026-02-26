import SwiftUI

struct TagListView: View {
  @Environment(BookmarkStore.self) private var store

  var body: some View {
    NavigationStack {
      ZStack {
        Color.pfBackground.ignoresSafeArea()

        if store.tags.isEmpty {
          VStack(spacing: 12) {
            Image(systemName: "tag")
              .font(.system(size: 44))
              .foregroundColor(.pfTextTertiary)
            Text("No tags yet")
              .font(.headline)
              .foregroundColor(.pfTextSecondary)
            Text("Tags appear when you add them to bookmarks")
              .font(.subheadline)
              .foregroundColor(.pfTextTertiary)
          }
        } else {
          List {
            ForEach(store.tags) { tag in
              Button {
                Task {
                  await store.setTagFilter(tag.name)
                }
              } label: {
                HStack(spacing: 12) {
                  Text("#")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color.tagColor(for: tag.name))
                    .frame(width: 30)

                  Text(tag.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.pfTextPrimary)

                  Spacer()

                  Text("\(tag.bookmarkCount)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.pfTextSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.pfSurfaceLight)
                    .cornerRadius(8)
                }
                .padding(.vertical, 2)
              }
              .listRowBackground(Color.pfBackground)
              .listRowSeparatorTint(.pfBorder)
            }
          }
          .listStyle(.plain)
          .scrollContentBackground(.hidden)
        }
      }
      .navigationTitle("Tags")
      .navigationBarTitleDisplayMode(.large)
      .toolbarBackground(Color.pfBackground, for: .navigationBar)
      .toolbarColorScheme(.dark, for: .navigationBar)
    }
    .task {
      await store.loadTags()
    }
  }
}

#Preview {
  TagListView()
    .environment(BookmarkStore())
}

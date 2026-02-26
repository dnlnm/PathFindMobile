import SwiftUI

struct BookmarkRowView: View {
  let bookmark: Bookmark
  let serverURL: String

  var body: some View {
    HStack(spacing: 14) {
      // Thumbnail or Favicon
      thumbnailView
        .frame(width: 64, height: 64)
        .cornerRadius(10)
        .clipped()

      // Content
      VStack(alignment: .leading, spacing: 4) {
        Text(bookmark.title ?? bookmark.url)
          .font(.subheadline)
          .fontWeight(.medium)
          .foregroundColor(.pfTextPrimary)
          .lineLimit(2)

        Text(bookmark.domain)
          .font(.caption)
          .foregroundColor(.pfTextSecondary)
          .lineLimit(1)

        // Tags
        if !bookmark.tags.isEmpty {
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
              ForEach(bookmark.tags.prefix(3)) { tag in
                Text("#\(tag.name)")
                  .font(.system(size: 10, weight: .medium))
                  .foregroundColor(Color.tagColor(for: tag.name))
                  .padding(.horizontal, 7)
                  .padding(.vertical, 3)
                  .background(Color.tagColor(for: tag.name).opacity(0.15))
                  .cornerRadius(6)
              }
              if bookmark.tags.count > 3 {
                Text("+\(bookmark.tags.count - 3)")
                  .font(.system(size: 10, weight: .medium))
                  .foregroundColor(.pfTextTertiary)
              }
            }
          }
        }
      }

      Spacer(minLength: 0)

      // Status indicators
      VStack(spacing: 4) {
        if bookmark.isReadLater {
          Image(systemName: "bookmark.fill")
            .font(.system(size: 10))
            .foregroundColor(.pfWarning)
        }
        if let date = bookmark.createdAt.parseDate {
          Text(date.relativeFormatted)
            .font(.system(size: 9))
            .foregroundColor(.pfTextTertiary)
            .lineLimit(1)
        }
      }
    }
    .padding(.vertical, 8)
    .padding(.horizontal, 4)
  }

  @ViewBuilder
  private var thumbnailView: some View {
    if let thumbnail = bookmark.thumbnail, !thumbnail.isEmpty {
      let thumbnailURL = thumbnail.hasPrefix("http") ? thumbnail : "\(serverURL)\(thumbnail)"
      AsyncImage(url: URL(string: thumbnailURL)) { phase in
        switch phase {
        case .success(let image):
          image
            .resizable()
            .aspectRatio(contentMode: .fill)
        case .failure:
          faviconFallback
        default:
          Color.pfSurfaceLight
        }
      }
    } else {
      faviconFallback
    }
  }

  @ViewBuilder
  private var faviconFallback: some View {
    if let favicon = bookmark.favicon, !favicon.isEmpty {
      let faviconURL = favicon.hasPrefix("http") ? favicon : "\(serverURL)\(favicon)"
      AsyncImage(url: URL(string: faviconURL)) { phase in
        switch phase {
        case .success(let image):
          ZStack {
            Color.pfSurfaceLight
            image
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 28, height: 28)
          }
        default:
          domainFallback
        }
      }
    } else {
      domainFallback
    }
  }

  private var domainFallback: some View {
    ZStack {
      Color.pfSurfaceLight
      Text(String(bookmark.domain.prefix(1)).uppercased())
        .font(.system(size: 22, weight: .bold, design: .rounded))
        .foregroundColor(.pfAccent)
    }
  }
}

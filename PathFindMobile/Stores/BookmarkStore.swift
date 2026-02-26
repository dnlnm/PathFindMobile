import Foundation
import SwiftUI

enum BookmarkFilter: String, CaseIterable {
  case all = "all"
  case readLater = "readlater"
  case archived = "archived"

  var label: String {
    switch self {
    case .all: return "All"
    case .readLater: return "Read Later"
    case .archived: return "Archived"
    }
  }

  var icon: String {
    switch self {
    case .all: return "tray.full"
    case .readLater: return "bookmark"
    case .archived: return "archivebox"
    }
  }
}

enum BookmarkSort: String, CaseIterable {
  case newest = "newest"
  case oldest = "oldest"
  case titleAsc = "title_asc"
  case titleDesc = "title_desc"

  var label: String {
    switch self {
    case .newest: return "Newest First"
    case .oldest: return "Oldest First"
    case .titleAsc: return "Title A→Z"
    case .titleDesc: return "Title Z→A"
    }
  }

  var icon: String {
    switch self {
    case .newest: return "arrow.down"
    case .oldest: return "arrow.up"
    case .titleAsc: return "textformat.abc"
    case .titleDesc: return "textformat.abc"
    }
  }
}

@Observable
final class BookmarkStore {
  var bookmarks: [Bookmark] = []
  var isLoading: Bool = false
  var isLoadingMore: Bool = false
  var error: String?

  var currentPage: Int = 1
  var totalPages: Int = 1
  var total: Int = 0

  var filter: BookmarkFilter = .all
  var sort: BookmarkSort = .newest
  var searchQuery: String = ""

  // Filter by tag or collection
  var filterTag: String?
  var filterCollectionId: String?
  var filterCollectionName: String?

  var collections: [Collection] = []
  var tags: [Tag] = []

  private var service: BookmarkService?

  var hasMorePages: Bool {
    currentPage < totalPages
  }

  var activeFilterDescription: String? {
    if let tag = filterTag {
      return "#\(tag)"
    }
    if let name = filterCollectionName {
      return name
    }
    return nil
  }

  func configure(service: BookmarkService) {
    self.service = service
  }

  // MARK: - Load Bookmarks

  @MainActor
  func loadBookmarks(reset: Bool = true) async {
    guard let service else { return }

    if reset {
      currentPage = 1
      isLoading = true
    }

    error = nil

    do {
      let response = try await service.fetchBookmarks(
        filter: filter.rawValue,
        query: searchQuery.isEmpty ? nil : searchQuery,
        tag: filterTag,
        collection: filterCollectionId,
        sort: sort.rawValue,
        page: currentPage
      )

      if reset {
        bookmarks = response.bookmarks
      } else {
        bookmarks.append(contentsOf: response.bookmarks)
      }

      totalPages = response.totalPages
      total = response.total
      isLoading = false
      isLoadingMore = false
    } catch {
      self.error = error.localizedDescription
      isLoading = false
      isLoadingMore = false
    }
  }

  @MainActor
  func loadNextPage() async {
    guard hasMorePages, !isLoadingMore else { return }
    isLoadingMore = true
    currentPage += 1
    await loadBookmarks(reset: false)
  }

  @MainActor
  func refresh() async {
    await loadBookmarks(reset: true)
  }

  // MARK: - Actions

  @MainActor
  func deleteBookmark(id: String) async {
    guard let service else { return }

    do {
      try await service.deleteBookmark(id: id)
      bookmarks.removeAll { $0.id == id }
      total -= 1
    } catch {
      self.error = error.localizedDescription
    }
  }

  @MainActor
  func toggleArchive(bookmark: Bookmark) async {
    guard let service else { return }

    do {
      let updated = try await service.updateBookmark(
        id: bookmark.id,
        BookmarkUpdateRequest(isArchived: !bookmark.isArchived)
      )
      if let index = bookmarks.firstIndex(where: { $0.id == updated.id }) {
        // If we're filtering, the bookmark may no longer match — remove it
        if filter != .all {
          bookmarks.remove(at: index)
          total -= 1
        } else {
          bookmarks[index] = updated
        }
      }
    } catch {
      self.error = error.localizedDescription
    }
  }

  @MainActor
  func toggleReadLater(bookmark: Bookmark) async {
    guard let service else { return }

    do {
      let updated = try await service.updateBookmark(
        id: bookmark.id,
        BookmarkUpdateRequest(isReadLater: !bookmark.isReadLater)
      )
      if let index = bookmarks.firstIndex(where: { $0.id == updated.id }) {
        if filter == .readLater {
          bookmarks.remove(at: index)
          total -= 1
        } else {
          bookmarks[index] = updated
        }
      }
    } catch {
      self.error = error.localizedDescription
    }
  }

  // MARK: - Filters

  @MainActor
  func setFilter(_ newFilter: BookmarkFilter) async {
    filter = newFilter
    filterTag = nil
    filterCollectionId = nil
    filterCollectionName = nil
    await loadBookmarks(reset: true)
  }

  @MainActor
  func setTagFilter(_ tag: String) async {
    filterTag = tag
    filterCollectionId = nil
    filterCollectionName = nil
    filter = .all
    await loadBookmarks(reset: true)
  }

  @MainActor
  func setCollectionFilter(id: String, name: String) async {
    filterCollectionId = id
    filterCollectionName = name
    filterTag = nil
    filter = .all
    await loadBookmarks(reset: true)
  }

  @MainActor
  func clearCustomFilter() async {
    filterTag = nil
    filterCollectionId = nil
    filterCollectionName = nil
    await loadBookmarks(reset: true)
  }

  @MainActor
  func setSort(_ newSort: BookmarkSort) async {
    sort = newSort
    await loadBookmarks(reset: true)
  }

  // MARK: - Collections & Tags

  @MainActor
  func loadCollections() async {
    guard let service else { return }
    do {
      collections = try await service.fetchCollections()
    } catch {
      self.error = error.localizedDescription
    }
  }

  @MainActor
  func loadTags() async {
    guard let service else { return }
    do {
      tags = try await service.fetchTags()
    } catch {
      self.error = error.localizedDescription
    }
  }
}

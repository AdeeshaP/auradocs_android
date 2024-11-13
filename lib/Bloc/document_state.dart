// document_state.dart
abstract class DocumentState {}

class DocumentInitial extends DocumentState {}

class DocumentLoading extends DocumentState {}

// PartialSharedDocumentLoaded state to only update specific fields for shared docs

class PartialSharedDocumentLoaded extends DocumentState {
  final List<dynamic>? sharedDocs;

  PartialSharedDocumentLoaded({
    this.sharedDocs,
  });

  SharedDocumentLoaded mergeWith(SharedDocumentLoaded existingState) {
    return SharedDocumentLoaded(
      sharedDocs: sharedDocs ?? existingState.sharedDocs,
    );
  }
}

class SharedDocumentLoaded extends DocumentState {
  final List<dynamic>? sharedDocs;

  SharedDocumentLoaded({this.sharedDocs});
}

// PartialFavoriteListLoaded state to only update specific fields for favourite docs

class PartialFavoriteListLoaded extends DocumentState {
  final List<dynamic>? bookmarks;
  final int? totalPages;
  PartialFavoriteListLoaded({
    this.bookmarks,
    this.totalPages,
  });

  FavoriteListLoaded mergeWith(FavoriteListLoaded existingState) {
    return FavoriteListLoaded(
      bookmarks: bookmarks ?? existingState.bookmarks,
      totalPages: totalPages ?? existingState.totalPages,
    );
  }
}

class FavoriteListLoaded extends DocumentState {
  final List<dynamic>? bookmarks;
  final int? totalPages;

  FavoriteListLoaded({this.bookmarks, this.totalPages});
}

// SearchDocumentLoaded state to only update specific fields for search docs

class PartialSearchDocumentLoaded extends DocumentState {
  final List<dynamic>? searchDocs;
  final int? totalPages;

  PartialSearchDocumentLoaded({
    this.searchDocs,
    this.totalPages,
  });

  SearchDocumentLoaded mergeWith(SearchDocumentLoaded existingState) {
    return SearchDocumentLoaded(
      searchDocs: searchDocs ?? existingState.searchDocs,
      totalPages: totalPages ?? existingState.totalPages,
    );
  }
}

class SearchDocumentLoaded extends DocumentState {
  final List<dynamic>? searchDocs;
  final int? totalPages;

  SearchDocumentLoaded({this.searchDocs, this.totalPages});
}

class AdvancedSearchedListLoaded extends DocumentState {
  final List<dynamic>? documents;
  final int? totalPages;

  AdvancedSearchedListLoaded({this.documents, this.totalPages});
}

class PendingDocsLoaded extends DocumentState {
  final List<dynamic>? pendingDocs;
  final List<bool>? folderExpansionStates;

  PendingDocsLoaded({this.pendingDocs, this.folderExpansionStates});
}

class TemplateDropdownLoaded extends DocumentState {
  final List<Map<String, dynamic>> values;
  final List<String> dropdownValues;

  TemplateDropdownLoaded({required this.values, required this.dropdownValues});
}

class DocumentError extends DocumentState {
  final String message;

  DocumentError(this.message);
}

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

class DocumentError extends DocumentState {
  final String message;

  DocumentError(this.message);
}

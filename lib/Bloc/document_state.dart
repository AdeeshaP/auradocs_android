// document_state.dart
abstract class DocumentState {}

class DocumentInitial extends DocumentState {}

class DocumentLoading extends DocumentState {}

class DocumentCountLoading extends DocumentState {}

class WFDashboardCountLoading extends DocumentState {}

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

// PartialSignListLoaded state to only update specific fields for signed docs

class PartialSignListLoaded extends DocumentState {
  final List<dynamic>? signDocs;
  final int? totalPages;

  PartialSignListLoaded({
    this.signDocs,
    this.totalPages,
  });

  SignListLoaded mergeWith(SignListLoaded existingState) {
    return SignListLoaded(
      signDocs: signDocs ?? existingState.signDocs,
      totalPages: totalPages ?? existingState.totalPages,
    );
  }
}

class SignListLoaded extends DocumentState {
  final List<dynamic>? signDocs;
  final int? totalPages;

  SignListLoaded({this.signDocs, this.totalPages});
}

// PartialDocumentLoaded state to only update specific fields for history tables

class PartialHistoryLoaded extends DocumentState {
  final List? accountHistory;
  final List? indexHistory;
  final List? downloadHistory;
  final List? todoHistory;

  PartialHistoryLoaded({
    this.accountHistory,
    this.indexHistory,
    this.downloadHistory,
    this.todoHistory,
  });

  HistoryLoaded mergeWith(HistoryLoaded existingState) {
    return HistoryLoaded(
      accountHistory: accountHistory ?? existingState.accountHistory,
      indexHistory: indexHistory ?? existingState.indexHistory,
      downloadHistory: downloadHistory ?? existingState.downloadHistory,
      todoHistory: todoHistory ?? existingState.todoHistory,
    );
  }
}

class HistoryLoaded extends DocumentState {
  final List<dynamic>? accountHistory;
  final List<dynamic>? indexHistory;
  final List<dynamic>? downloadHistory;
  final List<dynamic>? todoHistory;

  HistoryLoaded({
    this.accountHistory,
    this.indexHistory,
    this.downloadHistory,
    this.todoHistory,
  });
}

class WFDasboardCountLoaded extends DocumentState {
  final String? inProgressTasksCount;
  final String? suspendedTasksCount;
  final String? completedTasksCount;
  final String? assignedTasksCount;

  WFDasboardCountLoaded({
    this.inProgressTasksCount,
    this.suspendedTasksCount,
    this.completedTasksCount,
    this.assignedTasksCount,
  });
}

class DocumentError extends DocumentState {
  final String message;

  DocumentError(this.message);
}

// document_event.dart
abstract class DocumentEvent {}

class FetchSharedWithMeDocs extends DocumentEvent {
  final String username;
  final String token;

  FetchSharedWithMeDocs(this.username, this.token);
}

class FetchFavoriteDocs extends DocumentEvent {
  final String username;
  final String token;

  FetchFavoriteDocs(this.username, this.token);
}

class FetchSearchDocuments extends DocumentEvent {
  final String searchValue;
  final String token;

  FetchSearchDocuments(this.searchValue, this.token);
}

class FetchAdvancedeSearchDocuments extends DocumentEvent {
  final String searchValue;
  final int templateId;
  final String templateName;
  final String fieldId;
  final String token;

  FetchAdvancedeSearchDocuments(this.searchValue, this.templateName,
      this.templateId, this.fieldId, this.token);
}

class FetchPendingDocumentsToIndex extends DocumentEvent {
  final String username;
  final String token;

  FetchPendingDocumentsToIndex(this.username, this.token);
}

class FetchTemplateDropdown extends DocumentEvent {
  final String username;
  final String token;

  FetchTemplateDropdown(this.username, this.token);
}

class FetchSignDocuments extends DocumentEvent {
  final String username;
  final String token;

  FetchSignDocuments(this.username, this.token);
}

class FetchIndexHistory extends DocumentEvent {
  final String username;
  final String token;

  FetchIndexHistory(this.username, this.token);
}

class FetchAccountHistory extends DocumentEvent {
  final String username;
  final String token;

  FetchAccountHistory(this.username, this.token);
}

class FetchDownloadHistory extends DocumentEvent {
  final String username;
  final String token;

  FetchDownloadHistory(this.username, this.token);
}

class FetchToDoHistory extends DocumentEvent {
  final String username;
  final String token;

  FetchToDoHistory(this.username, this.token);
}

class FetchWFDashboardCounts extends DocumentEvent {
  final String username;
  final String token;

  FetchWFDashboardCounts(this.username, this.token);
}

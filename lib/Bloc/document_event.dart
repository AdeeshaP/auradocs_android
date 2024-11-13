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

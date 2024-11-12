// document_event.dart
abstract class DocumentEvent {}

class FetchSharedWithMeDocs extends DocumentEvent {
  final String username;
  final String token;

  FetchSharedWithMeDocs(this.username, this.token);
}

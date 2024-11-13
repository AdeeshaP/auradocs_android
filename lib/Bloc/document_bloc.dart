import 'dart:convert';
import 'package:auradocs_android/Bloc/document_event.dart';
import 'package:auradocs_android/Bloc/document_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../API-Services/api_service.dart';

class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  final String username;
  final String token;

  DocumentBloc(this.username, this.token) : super(DocumentInitial()) {
    on<FetchSharedWithMeDocs>((event, emit) async {
      emit(DocumentLoading());
      try {
        var shredResponse =
            await ApiService.getSharedDocumentList(event.username, event.token);
        print("shredResponse.statusCode ${shredResponse.statusCode}");

        if (shredResponse.statusCode == 200) {
          var responsedata = jsonDecode(shredResponse.body);

          emit(PartialSharedDocumentLoaded(sharedDocs: responsedata['value'])
              .mergeWith(state is SharedDocumentLoaded
                  ? state as SharedDocumentLoaded
                  : SharedDocumentLoaded()));
        } else if (shredResponse.statusCode == 404) {
          emit(PartialSharedDocumentLoaded(sharedDocs: null).mergeWith(
              state is SharedDocumentLoaded
                  ? state as SharedDocumentLoaded
                  : SharedDocumentLoaded()));
        } else if (shredResponse.statusCode == 500) {
          emit(
              DocumentError("Server error! Please contact the administrator."));
        }
      } catch (e) {
        emit(DocumentError("An unexpected error occurred: $e"));
      }
    });

    on<FetchFavoriteDocs>((event, emit) async {
      emit(DocumentLoading());
      try {
        var bookmarkResponse =
            await ApiService.getBookmarkList(event.username, event.token);

        print("bookmarkResponse.statusCode ${bookmarkResponse.statusCode}");

        if (bookmarkResponse.statusCode == 200) {
          var responsedata = jsonDecode(bookmarkResponse.body);
          List<dynamic> documents = responsedata?['value'] ?? [];
          int totalPages = (documents.length / 4).ceil();

          emit(PartialFavoriteListLoaded(
                  bookmarks: responsedata['value'], totalPages: totalPages)
              .mergeWith(state is FavoriteListLoaded
                  ? state as FavoriteListLoaded
                  : FavoriteListLoaded()));
        } else if (bookmarkResponse.statusCode == 404) {
          emit(PartialFavoriteListLoaded(bookmarks: null).mergeWith(
              state is FavoriteListLoaded
                  ? state as FavoriteListLoaded
                  : FavoriteListLoaded()));
        } else if (bookmarkResponse.statusCode == 500) {
          emit(
              DocumentError("Server error! Please contact the administrator."));
        }
      } catch (e) {
        emit(DocumentError("An unexpected error occurred: $e"));
      }
    });

    on<FetchSearchDocuments>((event, emit) async {
      emit(DocumentLoading());
      try {
        var response = await ApiService.getDocumentsBySearchValue(
            event.searchValue, event.token);
        if (response.statusCode == 200) {
          var responsedata = jsonDecode(response.body);
          List<dynamic> documents = responsedata?['value'] ?? [];
          int totalPages = (documents.length / 4).ceil();

          emit(PartialSearchDocumentLoaded(
                  searchDocs: responsedata['value'], totalPages: totalPages)
              .mergeWith(state is SearchDocumentLoaded
                  ? state as SearchDocumentLoaded
                  : SearchDocumentLoaded()));
        } else if (response.statusCode == 404) {
          emit(PartialSearchDocumentLoaded(searchDocs: null).mergeWith(
              state is SearchDocumentLoaded
                  ? state as SearchDocumentLoaded
                  : SearchDocumentLoaded()));
        } else if (response.statusCode == 500) {
          emit(
              DocumentError("Server error! Please contact the administrator."));
        }
      } catch (e) {
        emit(DocumentError("An unexpected error occurred: $e"));
      }
    });

    on<FetchAdvancedeSearchDocuments>((event, emit) async {
      emit(DocumentLoading());
      try {
        var response = await ApiService.advanceSearch(event.searchValue,
            event.templateId.toString(), event.fieldId, event.token);
        if (response.statusCode == 200) {
          var responsedata = jsonDecode(response.body);
          List<dynamic> documents = responsedata?['value'] ?? [];
          int totalPages = (documents.length / 4).ceil();
          emit(
            AdvancedSearchedListLoaded(
              documents: documents,
              totalPages: totalPages,
            ),
          );
        } else if (response.statusCode == 404) {
          emit(DocumentError("No documents for advanced search."));
        } else if (response.statusCode == 500) {
          emit(
              DocumentError("Server error! Please contact the administrator."));
        }
      } catch (e) {
        emit(DocumentError("An unexpected error occurred: $e"));
      }
    });

    on<FetchPendingDocumentsToIndex>((event, emit) async {
      emit(DocumentLoading());
      try {
        var response =
            await ApiService.getPendingDocuments(event.username, event.token);
        if (response.statusCode == 200) {
          var responsedata = jsonDecode(response.body);
          List<dynamic> documents = responsedata?['value'] ?? [];

          // Initialize folderExpansionStates2 with 'false' for each document item
          List<bool> folderExpansionStates =
              List.generate(documents.length, (index) => false);
          emit(
            PendingDocsLoaded(
              pendingDocs: documents,
              folderExpansionStates: folderExpansionStates,
            ),
          );
        } else if (response.statusCode == 404) {
          emit(DocumentError("No documents to index."));
        } else if (response.statusCode == 500) {
          emit(
              DocumentError("Server error! Please contact the administrator."));
        }
      } catch (e) {
        emit(DocumentError("An unexpected error occurred: $e"));
      }
    });

    on<FetchTemplateDropdown>((event, emit) async {
      emit(DocumentLoading());

      try {
        var response = await ApiService.getAvalableTemplatesLists(
            event.username, event.token);

        print("templatelist.statusCode ${response.statusCode}");

        if (response.statusCode == 200) {
          var templatelist = jsonDecode(response.body);
          List<Map<String, dynamic>> values =
              List<Map<String, dynamic>>.from(templatelist['value']);
          List<String> dropdownValues =
              values.map((e) => e.values.first.toString()).toList();

          emit(TemplateDropdownLoaded(
              values: values, dropdownValues: dropdownValues));
        } else {
          emit(DocumentError("Failed to load template dropdown values"));
        }
      } catch (e) {
        emit(DocumentError("An error occurred: $e"));
      }
    });
    on<FetchSignDocuments>((event, emit) async {
      emit(DocumentLoading());
      try {
        var response =
            await ApiService.getDocumentListToSign(event.token, event.username);
        if (response.statusCode == 200) {
          var responsedata = jsonDecode(response.body);
          List<dynamic> documents = responsedata?['value'] ?? [];
          int totalPages = (documents.length / 7).ceil();

          emit(PartialSignListLoaded(
                  signDocs: responsedata['value'], totalPages: totalPages)
              .mergeWith(state is SignListLoaded
                  ? state as SignListLoaded
                  : SignListLoaded()));
        } else if (response.statusCode == 404) {
          // emit(DocumentError("No documents to sign."));
          emit(PartialSignListLoaded(signDocs: null).mergeWith(
              state is SignListLoaded
                  ? state as SignListLoaded
                  : SignListLoaded()));
        } else if (response.statusCode == 500) {
          emit(
              DocumentError("Server error! Please contact the administrator."));
        }
      } catch (e) {
        emit(DocumentError("An unexpected error occurred: $e"));
      }
    });

    on<FetchAccountHistory>((event, emit) async {
      emit(DocumentLoading());
      try {
        var accountHstoryResponse =
            await ApiService.getAccountHistory(event.username, event.token);
        print(
            "getAccountHistory.statusCode ${accountHstoryResponse.statusCode}");

        if (accountHstoryResponse.statusCode == 200) {
          var responsedata = jsonDecode(accountHstoryResponse.body);

          emit(PartialHistoryLoaded(accountHistory: responsedata['value'])
              .mergeWith(state is HistoryLoaded
                  ? state as HistoryLoaded
                  : HistoryLoaded()));
        } else if (accountHstoryResponse.statusCode == 404) {
          emit(PartialHistoryLoaded(accountHistory: null).mergeWith(
              state is HistoryLoaded
                  ? state as HistoryLoaded
                  : HistoryLoaded()));
        } else if (accountHstoryResponse.statusCode == 500) {
          emit(
              DocumentError("Server error! Please contact the administrator."));
        }
      } catch (e) {
        emit(DocumentError("An unexpected error occurred: $e"));
      }
    });

    on<FetchIndexHistory>((event, emit) async {
      emit(DocumentLoading());
      try {
        var indexHistoryResponse =
            await ApiService.getIndexHistory(event.username, event.token);
        print("getIndexHistory.statusCode ${indexHistoryResponse.statusCode}");

        if (indexHistoryResponse.statusCode == 200) {
          var responsedata = jsonDecode(indexHistoryResponse.body);

          emit(PartialHistoryLoaded(indexHistory: responsedata['value'])
              .mergeWith(state is HistoryLoaded
                  ? state as HistoryLoaded
                  : HistoryLoaded()));
        } else if (indexHistoryResponse.statusCode == 404) {
          // emit(DocumentError("No data ."));
          emit(PartialHistoryLoaded(indexHistory: null).mergeWith(
              state is HistoryLoaded
                  ? state as HistoryLoaded
                  : HistoryLoaded()));
        } else if (indexHistoryResponse.statusCode == 500) {
          emit(
              DocumentError("Server error! Please contact the administrator."));
        }
      } catch (e) {
        emit(DocumentError("An unexpected error occurred: $e"));
      }
    });

    on<FetchToDoHistory>((event, emit) async {
      emit(DocumentLoading());
      try {
        var toDoHistoryResponse =
            await ApiService.getToDoHistory(event.username, event.token);
        print("getToDoHistory.statusCode ${toDoHistoryResponse.statusCode}");

        if (toDoHistoryResponse.statusCode == 200) {
          var responsedata = jsonDecode(toDoHistoryResponse.body);

          emit(PartialHistoryLoaded(todoHistory: responsedata['value'])
              .mergeWith(state is HistoryLoaded
                  ? state as HistoryLoaded
                  : HistoryLoaded()));
        } else if (toDoHistoryResponse.statusCode == 404) {
          emit(PartialHistoryLoaded(todoHistory: null).mergeWith(
              state is HistoryLoaded
                  ? state as HistoryLoaded
                  : HistoryLoaded()));
        } else if (toDoHistoryResponse.statusCode == 500) {
          emit(
              DocumentError("Server error! Please contact the administrator."));
        }
      } catch (e) {
        emit(DocumentError("An unexpected error occurred: $e"));
      }
    });

    on<FetchDownloadHistory>((event, emit) async {
      emit(DocumentLoading());
      try {
        var downloadHistoryResponse =
            await ApiService.getDownloadHistory(event.username, event.token);
        print(
            "getDownloadHistory.statusCode ${downloadHistoryResponse.statusCode}");

        if (downloadHistoryResponse.statusCode == 200) {
          var responsedata = jsonDecode(downloadHistoryResponse.body);
          emit(PartialHistoryLoaded(downloadHistory: responsedata['value'])
              .mergeWith(state is HistoryLoaded
                  ? state as HistoryLoaded
                  : HistoryLoaded()));
        } else if (downloadHistoryResponse.statusCode == 404) {
          emit(PartialHistoryLoaded(downloadHistory: null).mergeWith(
              state is HistoryLoaded
                  ? state as HistoryLoaded
                  : HistoryLoaded()));
        } else if (downloadHistoryResponse.statusCode == 500) {
          emit(
              DocumentError("Server error! Please contact the administrator."));
        }
      } catch (e) {
        emit(DocumentError("An unexpected error occurred: $e"));
      }
    });
  }
}

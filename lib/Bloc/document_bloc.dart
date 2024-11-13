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

  }
}

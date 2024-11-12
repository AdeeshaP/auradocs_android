import 'package:http/http.dart' as http;

class ApiService {
  static String companyCode = '';
  static String apiBaseUrl = 'https://$companyCode/mobile/';

  // -----------------Login endpoint POST ---------------------

  static dynamic loginSuccessWithMobile(
      String userName, String password) async {
    final encodedUserName = Uri.encodeComponent(userName);
    final encodedPassword = Uri.encodeComponent(password);

    final response = await http.post(
      Uri.parse(apiBaseUrl +
          'service/authorization/mobile-login/$encodedUserName/$encodedPassword'),
      headers: {
        'Content-Type': 'application/json',
      },
      // ignore: body_might_complete_normally_catch_error
    ).catchError((e) {
      print(e);
    });
    print(response.request!.url);
    return response;
  }

  // -----------------Login endpoint with device POST---------------------
  static dynamic loginSuccessWithDevice(
      String userName, String password, String dviceId) async {
    final response = await http.post(
      Uri.parse(apiBaseUrl +
          'service/authorization/log-in/$userName/$password/$dviceId'),
      headers: {"Accept": "application/json"},
    );
    return response;
  }

  // -----------------Login endpoint - Verify the user GET---------------------
  static dynamic authenticateUserWithToken(String token) async {
    var response = await http
        .get(Uri.parse(apiBaseUrl + 'service/authorization/verify/$token'));

    return response;
  }

  // -----------------Login endpoint - Logout GET--------------------
  static dynamic logoutUser(String userId, String token) async {
    var response = await http.get(
        Uri.parse(apiBaseUrl + 'service/authorization/log-out/$userId/$token'));
    return response;
  }

  // ----------------- Document-search-endpoint - View Documents By search value GET----------------
  static dynamic getDocumentsBySearchValue(
      String searchValue, String token) async {
    var url = apiBaseUrl + 'service/document/direct-search/$searchValue/$token';

    var response = await http.get(Uri.parse(url));
    return response;
  }

  // ----------------- Document-search-endpoint - Documents search Viewer GET----------------
  static dynamic openViewerSearch(
      int docId, String userId, String token) async {
    var url = apiBaseUrl + 'service/document/open-viewer/$docId/$userId/$token';

    var response = await http.get(
      Uri.parse(url),
    );
    return response;
  }

  // ----------------- Document-search-endpoint - Advance Search  GET----------------
  static dynamic advanceSearch(String searchValue, String templateId,
      String fieldId, String token) async {
    var url = '$apiBaseUrl/service/document/advance-search?token=$token';
    // Append optional parameters if they are provided
    if (searchValue != "" && searchValue.isNotEmpty) {
      url += '&searchValue=$searchValue';
    }
    if (templateId != "" && templateId.isNotEmpty) {
      url += '&templateId=$templateId';
    }
    if (fieldId != "" && fieldId.isNotEmpty) {
      url += '&fieldId=$fieldId';
    }

    var response = await http.get(Uri.parse(url));
    return response;
  }

  // ----------------- Template-end-point - View a list of Avalable Templates GET---------------
  static dynamic getAvalableTemplatesLists(
      String username, String token) async {
    var url = apiBaseUrl + 'service/template/templateList/$username/$token';

    var response = await http.get(Uri.parse(url));
    return response;
  }

  // ----------------- Template-end-point - Upload Teplate Data to Get OCR values  POST---------------
  static dynamic sendTemplateDataToGetOCR(
      int templateId, String token, String image, String userId) async {
    // final http.Response response = await http.post(
    final response = await http.post(
      Uri.parse(
          apiBaseUrl + 'service/template/template-ocr/$templateId/$token'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: image,
    );
    return response;
  }

  // ----------------- Template-end-point - View Avalable Template By username GET---------------
  static dynamic getAvailableTemplateByUserName(
      String username, String token) async {
    var url = apiBaseUrl + 'service/template/templateReport/$username/$token';

    var response = await http.get(Uri.parse(url));
    return response;
  }

  // ----------------- Template-end-point - View Avalable Template By Id GET---------------
  static dynamic getAvailableTemplateById(int templateId, String token) async {
    var url = apiBaseUrl + 'service/template/template/$templateId/$token';

    var response = await http.get(Uri.parse(url));
    return response;
  }

  // -----------------Notification endpoint - Add firebase token GET--------------------
  static dynamic addFirebaseTokenn(String userId, String token) async {
    var url = apiBaseUrl + 'service/notification/getToken/$userId/$token';

    var response = await http.get(Uri.parse(url));
    return response;
  }

  // -----------------Notification endpoint - Add firebase token GET--------------------
  static dynamic addFirebaseToken(String userId, String token,
      String fireBaseToken, String deviceId) async {
    var url = apiBaseUrl +
        'service/notification/addToken/$userId/$token/$fireBaseToken/$deviceId';

    var response = await http.get(Uri.parse(url));
    return response;
  }

  // -----------------Access-track-endpoint - AccessTrack By DocId GET--------------------
  static dynamic accessTrackByDocId(String userId, String token) async {
    var url = apiBaseUrl + 'service/access-track/userid/$userId/$token';

    var response = await http.get(Uri.parse(url));
    return response;
  }

  // -----------------Access-track-endpoint - AccessTrack By DocId 2 GET--------------------
  static dynamic accessTrackByDocIdTwo(String docId, String token) async {
    var url = apiBaseUrl + 'service/access-track/documentId/$docId/$token';

    var response = await http.get(Uri.parse(url));
    return response;
  }

  // -----------------Access-track-endpoint - AccessTrack By DocId 2 GET--------------------
  static dynamic passAccessTrackAction(String docId, String userId,
      String operation, String templateName, String token) async {
    // final http.Response response = await http.post(
    final response = await http.post(
      Uri.parse(apiBaseUrl +
          'service/access-track/add-action/$docId/$userId/$operation/$templateName/$token'),
      headers: {
        'Content-Type': 'application/json;',
      },
    );
    return response;
  }

  // -----------------Document-index-endpoint - Retrieve Pending Documents GET--------------------
  static dynamic getPendingDocuments(String user, String token) async {
    var url =
        apiBaseUrl + 'service/document-Index/pending_docment/$token/$user';
    var response = await http.get(Uri.parse(url));
    return response;
  }

// -----------------Document-index-endpoint - View Pending Document GET--------------------
  static dynamic viewPendingDocument(
      String user, String token, String folderName, String fileName) async {
    var url = apiBaseUrl +
        'service/document-Index/view_pending_document/$token/$user/$folderName/$fileName';

    var response = await http.get(Uri.parse(url));
    return response;
  }

  // -----------------Document-index-endpoint - Delete Pending Document GET--------------------
  static dynamic deletePendingDocument(
      String user, String token, String folderName, String fileName) async {
    var url = apiBaseUrl +
        'service/document-Index/delete_pending_document/$token/$user/$folderName/$fileName';

    var response = await http.get(Uri.parse(url));
    return response;
  }

  // -----------------Document-index-endpoint - Upload Pending Document  POST---------------------
  static dynamic indexPendingDocuments(int templateId, String templateName,
      String fileName, String token, String user, String payloadImage) async {
    // final http.Response response = await http.post(
    final response = await http.post(
      Uri.parse(apiBaseUrl +
          'service/document-Index/upload_document/$templateId/$templateName/$fileName/$token/$user'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: payloadImage,
    );
    return response;
  }

  // -----------------Document-index-endpoint - Index All documents at Once  POST---------------------
  static dynamic indexAllDocumentsAtOnce(int templateId, String templateName,
      String fodlername, String token, String user, String payloadImage) async {
    // final http.Response response = await http.post(
    final response = await http.post(
      Uri.parse(apiBaseUrl +
          'service/document-Index/bulk_index/$templateId/$templateName/$fodlername/$token/$user'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: payloadImage,
    );
    return response;
  }

  // -----------------Document-index-endpoint - Upload Folder POST---------------------
  static dynamic uploadFolder(String token, String user,
      String pendingFolderName, String payloadImage) async {
    // final http.Response response = await http.post(
    final response = await http.post(
      Uri.parse(apiBaseUrl +
          'service/document-Index/folder_upload/$token/$user/$pendingFolderName'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: payloadImage,
    );
    return response;
  }

  // -----------------Workflow Endpoint POST----------------------
  static dynamic getWorkflowAssignTasks(String userId, String token) async {
    var url = apiBaseUrl + 'service/workflow/assign-tasks/$userId/$token';

    var response = await http.get(Uri.parse(url));
    return response;
  }

  // ----------------- Bookmark-endpoint - Get Bookmark GET----------------
  static dynamic getBookmark(int docId, String userId, String token) async {
    var url = apiBaseUrl + 'service/book-mark/get/$docId/$userId/$token';

    var response = await http.get(Uri.parse(url));
    return response;
  }

  // ----------------- Bookmark-endpoint - Add Bookmark GET----------------
  static dynamic addBookmark(int docId, String userId, String token) async {
    var url = apiBaseUrl + 'service/book-mark/add/$docId/$userId/$token';

    var response = await http.get(Uri.parse(url));
    return response;
  }

  // ----------------- Bookmark-endpoint - Get Bookmark list GET----------------
  static dynamic getBookmarkList(String userId, String token) async {
    var url = apiBaseUrl + 'service/book-mark/get-list/$userId/$token';

    var response = await http.get(Uri.parse(url));
    return response;
  }

  // ----------------- Bookmark-endpoint - Remove Bookmark GET----------------
  static dynamic removeBookmark(int bookmarkId, String token) async {
    var url = apiBaseUrl + 'service/book-mark/remove/$bookmarkId/$token';

    var response = await http.get(Uri.parse(url));
    return response;
  }

  // ----------------- Dashboard-endpoint - Get Today Indexed Count GET----------------
  static dynamic getTodayIndexedDocCount(String userId, String token) async {
    var url = apiBaseUrl + 'service/dashboard/today-index/$userId/$token';

    var response = await http.get(Uri.parse(url));
    return response;
  }

  // ----------------- Dashboard-endpoint - Get My Total Indexed Count GET----------------
  static dynamic getMyTotalIndexedDocCount(String userId, String token) async {
    var url = apiBaseUrl + 'service/dashboard/my-total-index/$userId/$token';

    var response = await http.get(Uri.parse(url));
    return response;
  }

  // ----------------- Dashboard-endpoint - Get Total Indexed Count GET----------------
  static dynamic getTotalIndexedDocCount(String userId, String token) async {
    var url = apiBaseUrl + 'service/dashboard/total-index/$userId/$token';

    var response = await http.get(Uri.parse(url));
    return response;
  }

  // ----------------- Dashboard-endpoint - Get Total Viewed Count GET----------------
  static dynamic getTotalViewedDocCount(String userId, String token) async {
    var url = apiBaseUrl + 'service/dashboard/total-viewed/$userId/$token';

    var response = await http.get(Uri.parse(url));
    return response;
  }

  // ----------------- Dashboard-endpoint - Get Pending Folders Count GET----------------
  static dynamic getPendingFoldersCount(String userId, String token) async {
    var url = apiBaseUrl + 'service/dashboard/pending-documents/$userId/$token';

    var response = await http.get(Uri.parse(url));
    return response;
  }

  // ----------------- Dashboard-endpoint - Get Pending Documents Count GET----------------
  static dynamic getPendingTasksCount(String userId, String token) async {
    var url =
        apiBaseUrl + 'service/dashboard/pending-taks-count/$userId/$token';
    var response = await http.get(Uri.parse(url));
    return response;
  }

  // ----------------- Dashboard-endpoint - Get All Notification Counts Count GET----------------
  static dynamic getNotifciationsCount(String userId, String token) async {
    var url = apiBaseUrl + 'service/dashboard/allNotifications/$userId/$token';

    var response = await http.get(Uri.parse(url));
    return response;
  }

  // ----------------- Dashboard-endpoint - Get Shared Documents GET----------------
  static dynamic getSharedDocumentList(String userId, String token) async {
    var url = apiBaseUrl + 'service/dashboard/shared-documents/$userId/$token';

    var response = await http.get(Uri.parse(url));
    return response;
  }

  // ----------------- Dashboard-endpoint - Get Account History GET----------------
  static dynamic getAccountHistory(String userId, String token) async {
    var url = apiBaseUrl + 'service/dashboard/account-history/$userId/$token';

    var response = await http.get(Uri.parse(url));
    return response;
  }

  // ----------------- Dashboard-endpoint - Get Download History GET----------------
  static dynamic getDownloadHistory(String userId, String token) async {
    var url = apiBaseUrl + 'service/dashboard/download-history/$userId/$token';

    var response = await http.get(Uri.parse(url));
    return response;
  }

  // ----------------- Dashboard-endpoint - Get Index History GET----------------
  static dynamic getIndexHistory(String userId, String token) async {
    var url = apiBaseUrl + 'service/dashboard/index-history/$userId/$token';

    var response = await http.get(Uri.parse(url));
    return response;
  }

  // ----------------- Dashboard-endpoint - Get To-Do History GET----------------
  static dynamic getToDoHistory(String userId, String token) async {
    var url =
        apiBaseUrl + 'service/dashboard/pending-taks-history/$userId/$token';

    var response = await http.get(Uri.parse(url));
    return response;
  }

  // ----------------- Task Management-endpoint - Get Pending Tasks List GET----------------
  static dynamic getAllPendingTasks(String userId, String token) async {
    var url = apiBaseUrl + 'service/taks/pending-taks/$userId/$token';

    var response = await http.get(Uri.parse(url));
    return response;
  }

  // ----------------- Task Management-endpoint - Get Pending Tasks List GET----------------
  static dynamic getSelectedPendingTaskByDocId(
      String userId, int docId, String token) async {
    var url = apiBaseUrl + 'service/taks/pending-taks/$userId/$docId/$token';

    var response = await http.get(Uri.parse(url));
    return response;
  }

  // ----------------- Task Management-endpoint - Get Completed Tasks List GET----------------
  static dynamic getCompletedTaskByDocId(int docId, String token) async {
    var url = apiBaseUrl + 'service/taks/completed-task/$docId/$token';

    var response = await http.get(Uri.parse(url));
    return response;
  }

  // ----------------- Task Management-endpoint - Save Tasks POST----------------
  static dynamic saveTaskByApprovedUser(
    String userId,
    String approvedUser,
    int docId,
    String status,
    String remark,
    int tempId,
    String docName,
    String token,
  ) async {
    // final http.Response response = await http.put(
    final response = await http.put(
      Uri.parse(apiBaseUrl +
          'service/taks/save-task/$userId/$approvedUser/$docId/$status/$remark/$tempId/$docName/$token'),
      headers: {"Accept": "application/json"},
    );
    return response;
  }

  // ----------------- Task Management-endpoint - Update Task Status PUT----------------
  static dynamic updateStatusOfTask(
      int taskId, String status, String comment, String token) async {
    // final http.Response response = await http.put(
    final response = await http.put(
      Uri.parse(apiBaseUrl +
          'service/taks/update-task/$taskId/$status/$comment/$token'),
      headers: {"Accept": "application/json"},
    );
    return response;
  }

  // ----------------- Task Management-endpoint - get User list----------------
  static dynamic getUserNames(String token) async {
    var url = apiBaseUrl + 'service/taks/user-list/$token';

    var response = await http.get(Uri.parse(url));
    return response;
  }

  // ----------------- Signature-endpoint -  get Doc list ----------------

  static dynamic getDocumentListToSign(String token, String user) async {
    var url = apiBaseUrl +
        "service/signature/availableDocuments?token=" +
        token +
        "&user=" +
        user;
    var response = await http.get(Uri.parse(url));
    return response;
  }

  // ----------------- Signature-endpoint -  view document to sign ----------------

  static dynamic viewDocumentToSign(String token, int docId) async {
    var url = apiBaseUrl +
        "service/signature/pendingDocument?token=" +
        token +
        "&docId=" +
        docId.toString();
    var response = await http.get(Uri.parse(url));
    return response;
  }

  static dynamic uploadSignatures(
      String token, int docId, String userId, String payloadImage) async {
    final http.Response response = await http.post(
      Uri.parse(apiBaseUrl +
          'service/signature/addSignature?token=' +
          token +
          "&docId=" +
          docId.toString() +
          "&userId=" +
          userId),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: payloadImage,
    );
    return response;
  }

  // ----------------- Dashboard-endpoint - Get Workflow DashBoard Count GET----------------
  static dynamic getWorkflowCounts(String userId, String token) async {
    var url = apiBaseUrl +
        'service/dashboadinfo/getWorkflowDashBoardCount/$userId/$token';

    var response = await http.get(Uri.parse(url));
    return response;
  }

  // ----------------- Dashboard-endpoint - Get Workflow DashBoard Count GET----------------
  static dynamic getInProgressTasksForWF(String userId, String token) async {
    var url = apiBaseUrl + 'service/task/getWorkflowTasks/$userId/$token';

    var response = await http.get(Uri.parse(url));
    return response;
  }

  // ----------------- Dashboard-endpoint - Get Workflow DashBoard Count GET----------------
  static dynamic getFormFieldsForWFPendingTask(
      String taskId, String token) async {
    var url =
        apiBaseUrl + 'service/task/getWorkflowTaskFormByTaskId/$taskId/$token';

    var response = await http.get(Uri.parse(url));
    return response;
  }
}

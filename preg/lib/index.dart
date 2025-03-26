import 'package:functions_framework/functions_framework.dart';
import 'package:shelf/shelf.dart';
import 'dart:convert';
import 'package:googleapis/dialogflow/v2.dart' as dialogflow;
import 'package:googleapis_auth/auth_io.dart';

@CloudFunction()
Future<Response> chatbot(Request request) async {
  final credentials = await clientViaApplicationDefaultCredentials(
    scopes: [dialogflow.DialogflowApi.cloudPlatformScope],
  );

  final dialogflowApi = dialogflow.DialogflowApi(credentials);
  final project = 'your-firebase-project-id';
  final sessionId = 'pregnacare-chat-session';
  final requestJson = jsonDecode(await request.readAsString());
  final userMessage = requestJson['message'];

  final dialogflowRequest =
      dialogflow.GoogleCloudDialogflowV2DetectIntentRequest(
        queryInput: dialogflow.GoogleCloudDialogflowV2QueryInput(
          text: dialogflow.GoogleCloudDialogflowV2TextInput(
            text: userMessage,
            languageCode: 'en',
          ),
        ),
      );

  final response = await dialogflowApi.projects.agent.sessions.detectIntent(
    dialogflowRequest,
    'projects/$project/agent/sessions/$sessionId',
  );

  final botResponse =
      response.queryResult?.fulfillmentText ?? 'Sorry, I didn’t understand.';

  return Response.ok(
    jsonEncode({'response': botResponse}),
    headers: {'Content-Type': 'application/json'},
  );
}

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:hidden_gem/components/friendRequest.dart';
import 'package:hidden_gem/service/friend_request_service.dart';
import 'package:hidden_gem/service/user_services.dart';

final _userService = UserService();

/*
  Displays the friend request view 
  To add friend enter email of user
  Also displays friend requests of users where you can accept or decline their requests
  with displayname, and profile picture
  
*/

Future<void> showAddFriendDialog(
  BuildContext context,
  TextEditingController controller,
  FriendRequestService requestService,
) async {
  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Add Friend"),
      content: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: "example@email.com"),
            ),
            const SizedBox(height: 5),
            ElevatedButton(
              onPressed: () =>
                  _sendRequest(context, controller, requestService),
              child: const Text("Send"),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 400,
              height: 240,
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: requestService.getIncomingFriendRequests(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data!;
                  if (data.isEmpty) {
                    return const Center(child: Text("No requests"));
                  }
                  log("Data: ${data}");

                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, i) {
                      final dataResult = data[i];
                      print("RESULT: ${dataResult}");
                      return FriendRequestCard(
                        fullName: dataResult['displayName'],
                        profilePicture: dataResult['photoUrl'],
                        onAccept: () {
                          print(dataResult['requestId']);
                          requestService.updateRequestStatus(
                            dataResult['requestId'],
                            "accept",
                          );
                        },
                        onDecline: () {
                          requestService.updateRequestStatus(
                            dataResult['requestId'],
                            "decline",
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _sendRequest(
  BuildContext context,
  TextEditingController controller,
  FriendRequestService service,
) async {
  final email = controller.text.trim();
  if (email.isEmpty) return;

  final uid = await _userService.getUserIdByEmail(email);
  if (uid == null) {
    _snack(context, "User not found");
    return;
  }

  final ok = await _userService.sendFriendRequest(uid);
  Navigator.of(context).pop();
  _snack(context, ok ? "Request sent" : "Something went wrong");
}

void _snack(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}

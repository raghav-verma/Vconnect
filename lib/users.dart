import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

import 'chat.dart';
import 'util.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  bool isLoading = false;


  Widget _buildAvatar(types.User user) {
    final color = getUserAvatarNameColor(user);
    final hasImage = user.imageUrl != null;
    final name = getUserName(user);



    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: CircleAvatar(
        backgroundColor: hasImage ? Colors.transparent : color,
        backgroundImage: hasImage ? NetworkImage(user.imageUrl!) : null,
        radius: 20,
        child: !hasImage
            ? Text(
                name.isEmpty ? '' : name[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              )
            : null,
      ),
    );
  }

  Future<void> _handlePressed(types.User otherUser, BuildContext context) async {
    if (!isLoading) {
      isLoading = true;
      showLoaderDialog(context);
      final navigator = Navigator.of(context);
      await FirebaseChatCore.instance.createRoom(otherUser);
      final room = await FirebaseChatCore.instance.createRoom(otherUser);

      navigator.pop();
      print(room.name);
      print(otherUser.firstName);
      await navigator.push(
        MaterialPageRoute(
          builder: (context) =>
              ChatPage(
                room: room,

                userName: otherUser.firstName ?? '',
                imageUrl: otherUser.imageUrl ?? '',
              ),
        ),
      );
      isLoading = false;
      dismissLoaderDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF0D1B2A),
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          title: const Text('Contacts', style: TextStyle(color: Colors.white),),
          leading:    IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed:  () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: StreamBuilder<List<types.User>>(
          stream: FirebaseChatCore.instance.users(),
          initialData: const [],
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(
                  bottom: 200,
                ),
                child: const Text('No users'),
              );
            }

            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final user = snapshot.data![index];

                return GestureDetector(
                  onTap: () async {
                    await _handlePressed(user, context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        _buildAvatar(user),
                        Text(getUserName(user)),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
  void showLoaderDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Dialog will not dismiss on tap outside
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Loading Room..."),
              ],
            ),
          ),
        );
      },
    );
  }

  // Function to dismiss the loader dialog
  void dismissLoaderDialog(BuildContext context) {
    Navigator.pop(context); // Dismiss the dialog
  }
}


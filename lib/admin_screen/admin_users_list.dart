import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:onlineclass/admin_screen/admin_add_user.dart';
import 'package:onlineclass/utlities/colors.dart';
import 'package:onlineclass/utlities/snack_bar.dart';

final _firebase = FirebaseFirestore.instance;

class AdminUsersList extends StatefulWidget {
  const AdminUsersList({Key? key}) : super(key: key);

  @override
  _AdminUsersListState createState() => _AdminUsersListState();
}

class _AdminUsersListState extends State<AdminUsersList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      appBar: AppBar(
        title: const Text(
          'Users',
          style: TextStyle(color: Colors.yellow),
        ),
        backgroundColor: darkBlue,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => const AdminAddUser(
                        tappedButton: 'Add', userDocumentID: ''),
                  ),
                );
              },
              icon: const Icon(
                Icons.person_add,
                color: Colors.yellow,
              ))
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firebase
            .collection('users')
            .orderBy('name', descending: false)
            .snapshots(),
        builder: (ctx, snapshot) {
          final userList = snapshot.data?.docs;
          List<String> name = [];
          List<String> email = [];
          if (snapshot.hasData) {
            for (var user in userList!) {
              final userName = user.get('name');
              final userEmail = user.get('username');
              name.add(userName);
              email.add(userEmail);
            }
          }
          return UserCard(name: name, username: email);
        },
      ),
    );
  }
}

// ignore: must_be_immutable
class UserCard extends StatefulWidget {
  UserCard({
    Key? key,
    required this.name,
    // required this.stage,
    required this.username,
    // required this.role
  }) : super(key: key);

  List<String> name = [];
  List<String> username = [];

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  String? newEmail;

  List<String> userIds = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    final users = await _firebase.collection('users').get();
    for (var user in users.docs) {
      userIds.add(user.id);
    }
  }

  deleteUser(int index) async {
    try {
      await _firebase.collection('users').doc(userIds[index]).delete();
      showSnackBar(context, 'User has been deleted', Colors.redAccent);
      // ignore: empty_catches
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: widget.name.length,
          itemBuilder: (ctx, index) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
              decoration: BoxDecoration(
                  color: testColor, borderRadius: BorderRadius.circular(15.0)),
              child: ListTile(
                  title: Text(widget.name[index],
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.username[index],
                        style: const TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                  trailing: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) => AdminAddUser(
                                      tappedButton: 'Update',
                                      userDocumentID: userIds[index]),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.yellow,
                            ),
                          ),
                        ),
                        Flexible(
                          child: IconButton(
                            onPressed: () {
                              deleteUser(index);
                              userIds.removeAt(index);
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: Color.fromARGB(255, 250, 25, 9),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ),
          ),
        ),
      ),
    );
  }
}

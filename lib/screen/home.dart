import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test/methods/firestoremethods.dart';
import '../auth/auth.dart';
import '../utils/snackbar.dart';
import 'login.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = false;
  TextEditingController textFieldController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  deletedata(id) async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(inputData())
        .collection('notes')
        .doc(id)
        .delete();
  }

  String inputData() {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    return uid;
    // here you write the codes to input the data into firestore
  }

  void postNotes(
    String uid,
    String description,
  ) async {
    setState(() {
      isLoading = true;
    });

    // start the loading
    try {
      // upload to storage and db
      String res = await FirestoreMethods().postNotes(uid, description);
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        showSnackBar(
          context,
          'Posted!',
        );
      } else {
        //showSnackBar(context, res);
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Add Notes!"),
              content: TextField(
                controller: textFieldController,
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    postNotes(inputData(), textFieldController.text);
                    Navigator.of(ctx).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    child: const Text("Add"),
                  ),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text("My Notes"),
        elevation: 0,
        actions: [
          InkWell(
            onTap: () async {
              await AuthMethods().signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
            child: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('user')
                .doc(inputData())
                .collection('notes')
                .snapshots(),
            builder: (
              BuildContext context,
              AsyncSnapshot<QuerySnapshot> snapshot,
            ) {
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text('Loading');
              }
              final data = snapshot.requireData;
              return Container(
                child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: data.docs.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 300,
                      childAspectRatio: 1,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    itemBuilder: (BuildContext ctx, index) {
                      return Stack(
                        children: [
                          Container(
                            height: 300,
                            width: 300,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Colors.blue[200],
                                borderRadius: BorderRadius.circular(15)),
                            child: Text(data.docs[index]['description']),
                          ),
                          Positioned(
                            right: 0,
                            child: IconButton(
                              iconSize: 15,
                              onPressed: () {
                                deletedata(snapshot.data?.docs[index].id);
                              },
                              icon: const Icon(Icons.delete),
                            ),
                          )
                        ],
                      );
                    }),
              );
            },
          ),
        ),
      ),
    );
  }
}

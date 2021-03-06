import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tweezer/Views/new_tweez.dart';
import 'package:tweezer/widgets/tweezes.dart';
import '../drawer/drawer.dart';

class Dashboard extends StatefulWidget {
  final User user;
  const Dashboard(this.user, {Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List following_ids = [];

  //get the list of users you follow
  Future<List> getFollowing() async {
    List followings = [];
    final QuerySnapshot qSnap = await db
        .collection('relationships')
        .where("follower_id", isEqualTo: widget.user.uid)
        .get();
    for (var queryDocumentSnapshot in qSnap.docs) {
      Map<String, dynamic> followingData = queryDocumentSnapshot.data();
      var followedId = followingData["following_id"];
      followings.add(followedId);
    }
    return followings;
  }

  @override
  void initState() {
    getFollowing().then((value) {
      setState(() {
        // set the list
        following_ids = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final User _currentUser = widget.user;

    // get the tweezes and order by descending time
    //  if the user of the tweez is one of the users that the current_user is following
    CollectionReference ref =
        db.collection('tweezes');
        
    return FutureBuilder(
      future: ref.orderBy('created_at', descending: true).get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong',
              textAlign: TextAlign.center);
        }

        // if call was successful
        if (snapshot.connectionState == ConnectionState.done) {
          List tweezes = [];

          //  get the tweezes
          for (var queryDocumentSnapshot in snapshot.data!.docs) {
            Map<String, dynamic> data = queryDocumentSnapshot.data();
            var content = data["content"];
            var date = data["created_at"];
            var username = data["username"];
            var profilePicture = data["profile_picture"];
            var likes = data['likes'];
            var image = data['image'];
            var userId = data['user_id'];
            var userLiked = data['user_liked'];
            var tweezId = queryDocumentSnapshot.id;

            if( following_ids.contains(userId)){
              tweezes.add([
              content,
              date,
              username,
              profilePicture,
              likes,
              image,
              tweezId,
              userLiked
            ]);
            }
            

            // }
          }

          return Scaffold(
            drawer: const MyDrawer(),
            appBar: AppBar(title: const Text('Dashboard')),
            body: SingleChildScrollView(
              child: Column(
                // create Tweez cards
                children: tweezes
                    .map((e) => Card(
                          // pass data in the card (Tweez widget)
                          child: Tweezes(
                              e[0], e[1], e[2], e[3], e[4], e[5], e[6], e[7]),
                        ))
                    .toList(),
              ),
            ),

            // floating button to create a new tweez
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => NewTweez(_currentUser),
                  ),
                );
              },
              child: const Icon(Icons.edit),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

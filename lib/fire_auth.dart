import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FireAuth {
  static Future<User?> registerUsingEmailPassword({
    required String username,
    required String email,
    required String password,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore db = FirebaseFirestore.instance;
    User? user;

    var usernameExists = await db.collection('usernames').doc(username).get();
    try {
      if (!usernameExists.exists) {
        UserCredential userCredential = await auth
            .createUserWithEmailAndPassword(email: email, password: password);
        user = userCredential.user;
        await user!.updateDisplayName(username);
        await user.reload();
        user = auth.currentUser;
        db.collection('users').doc(user?.uid).set({
          "username": username,
          "email": email,
          "password": password,
          "bio": "",
          "followers": 0,
          "following": 0,
          "tweezes": 0,
          "profile picture":
              "https://firebasestorage.googleapis.com/v0/b/tweezer-ecam.appspot.com/o/profiles%2FProfile%20pictures%2Fblank-profile-picture-973460_1280.webp?alt=media&token=ee3911d9-d138-4b6c-8b0e-32e157da82b6",
          "profile cover":
              "https://firebasestorage.googleapis.com/v0/b/tweezer-ecam.appspot.com/o/profiles%2FProfile%20covers%2Fdefault-cover.webp?alt=media&token=c1611beb-78b3-4914-824b-d566995a91c2",
        });
        db.collection('usernames').doc(username).set({});
      } else {
        print("Username already exists");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak');
      } else if (e.code == 'email-already-in-use') {
        print('An account already exists for that email');
      }
    } catch (e) {
      print(e);
    }

    return user;
  }

  static Future<User?> signInUsingEmailPassword({
    required String email,
    required String password,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided');
      }
    }
    return user;
  }

  // for signing out just neet to use FirebaseAuth.instance.signOut();

  static Future<User?> refreshUser(User user) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    await user.reload();
    User? refreshedUser = auth.currentUser;

    return refreshedUser;
  }
}

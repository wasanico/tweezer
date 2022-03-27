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
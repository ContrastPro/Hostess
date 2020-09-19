import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hostess/models/profile.dart';
import 'package:hostess/notifier/profile_notifier.dart';

getProfile(
    ProfileNotifier profileNotifier, String restaurant, String address) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection(restaurant)
      .where('id', isEqualTo: address)
      .get();

  List<Profile> _profileList = [];

  snapshot.docs.forEach((element) {
    Profile profile = Profile.fromMap(element.data());
    _profileList.add(profile);
  });

  profileNotifier.profileList = _profileList;
}

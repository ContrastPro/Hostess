import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hostess/model/profile.dart';
import 'package:hostess/notifier/profile_notifier.dart';

getProfile(ProfileNotifier profileNotifier, String uid, String address) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('Database')

      /// Users or Public_Catering
      .doc('Public_Catering')
      .collection(uid)
      .where('id', isEqualTo: address)
      .get();

  List<Profile> _profileList = [];

  snapshot.docs.forEach((element) {
    Profile profile = Profile.fromMap(element.data());
    _profileList.add(profile);
  });

  profileNotifier.profileList = _profileList;
}

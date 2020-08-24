class Profile {
  String id;
  String title;
  String address;
  String image;
  List subTime = [];

  Profile();

  Profile.fromMap(Map<String, dynamic> data) {
    id = data['id'];
    title = data['title'];
    address = data['address'];
    image = data['image'];
    subTime = data['subTime'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'address': address,
      'image': image,
      'subTime': subTime,
    };
  }
}

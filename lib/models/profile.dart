class Profile {
  String id;
  String title;
  String address;
  String image;
  String time;

  Profile();

  Profile.fromMap(Map<String, dynamic> data) {
    id = data['id'];
    title = data['title'];
    address = data['address'];
    image = data['image'];
    time = data['time'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'address': address,
      'image': image,
      'time': time,
    };
  }
}

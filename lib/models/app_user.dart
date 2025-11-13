class AppUser {
  final String uid;
  final String name;
  final String email;
  final String country;
  final String photoUrl;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.country,
    required this.photoUrl,
  });

  factory AppUser.fromMap(Map<String, dynamic> data) {
    return AppUser(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      country: data['country'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'country': country,
      'photoUrl': photoUrl,
    };
  }
}




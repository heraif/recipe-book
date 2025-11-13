class Recipe {
  final String id;
  final String title;
  final List<String> ingredients;
  final List<String> steps;
  final String category;
  final String imageUrl;
  final String videoUrl;
  final String ownerId;
  final String ownerName;

  const Recipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.steps,
    required this.category,
    required this.imageUrl,
    required this.videoUrl,
    required this.ownerId,
    required this.ownerName,
  });

  factory Recipe.fromMap(String id, Map<String, dynamic> data) {
    return Recipe(
      id: id,
      title: (data['title'] ?? '').toString(),
      ingredients: List<String>.from(data['ingredients'] ?? const <String>[]),
      steps: List<String>.from(data['steps'] ?? const <String>[]),
      category: (data['category'] ?? '').toString(),
      imageUrl: (data['imageUrl'] ?? '').toString(),
      videoUrl: (data['videoUrl'] ?? '').toString(),
      ownerId: (data['ownerId'] ?? '').toString(),
      ownerName: (data['ownerName'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'titleLower': title.toLowerCase(),
      'ingredients': ingredients,
      'steps': steps,
      'category': category,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'ownerId': ownerId,
      'ownerName': ownerName,
    };
  }
}




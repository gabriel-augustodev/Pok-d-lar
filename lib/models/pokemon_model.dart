class PokemonModel {
  final int number;
  final String name;
  final String imageUrl;
  final String type;
  final String category;
  final String description;

  const PokemonModel({
    required this.number,
    required this.name,
    required this.imageUrl,
    required this.type,
    required this.category,
    required this.description,
  });

  PokemonModel copyWith({
    int? number,
    String? name,
    String? imageUrl,
    String? type,
    String? category,
    String? description,
  }) {
    return PokemonModel(
      number: number ?? this.number,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      category: category ?? this.category,
      description: description ?? this.description,
    );
  }

  factory PokemonModel.empty() {
    return const PokemonModel(
      number: 0,
      name: '???',
      imageUrl: '',
      type: '',
      category: '',
      description: '',
    );
  }
}

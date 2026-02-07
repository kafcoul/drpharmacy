class CategoryEntity {
  final int id;
  final String name;
  final String slug;
  final String? description;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
  });
}

/// Example domain entity.
///
/// This is a domain entity and must remain framework-agnostic.
/// No Flutter, Dio, or other framework imports should be added.
///
/// Entities represent business objects that are used throughout the application.
/// They should be simple data classes with equality comparison.
class ExampleEntity {
  final String id;
  final String name;
  final String description;

  const ExampleEntity({
    required this.id,
    required this.name,
    required this.description,
  });

  /// Creates a copy of this entity with the given fields replaced.
  ///
  /// This is used for immutable state updates.
  ExampleEntity copyWith({
    String? id,
    String? name,
    String? description,
  }) {
    return ExampleEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExampleEntity &&
        other.id == id &&
        other.name == name &&
        other.description == description;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ description.hashCode;
}

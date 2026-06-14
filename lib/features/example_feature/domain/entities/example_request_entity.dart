/// Example request entity.
///
/// This is a domain entity and must remain framework-agnostic.
/// No Flutter, Dio, or other framework imports should be added.
///
/// Request entities represent data sent from the presentation layer
/// to use cases for processing.
class ExampleRequestEntity {
  final String name;
  final String description;

  const ExampleRequestEntity({
    required this.name,
    required this.description,
  });

  /// Creates a copy of this entity with the given fields replaced.
  ExampleRequestEntity copyWith({
    String? name,
    String? description,
  }) {
    return ExampleRequestEntity(
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }
}

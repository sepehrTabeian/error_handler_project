import '../../domain/entities/example_request_entity.dart';

/// Data transfer object for example request.
///
/// DTOs are used for data transfer between layers and for serialization.
/// They map to/from domain entities.
class ExampleRequestDto {
  final String name;
  final String description;

  const ExampleRequestDto({
    required this.name,
    required this.description,
  });

  /// Creates a DTO from a domain entity.
  factory ExampleRequestDto.fromEntity(ExampleRequestEntity entity) {
    return ExampleRequestDto(
      name: entity.name,
      description: entity.description,
    );
  }

  /// Converts DTO to JSON.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }

  /// Creates a copy of this DTO with the given fields replaced.
  ExampleRequestDto copyWith({
    String? name,
    String? description,
  }) {
    return ExampleRequestDto(
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }
}

import '../../domain/entities/example_entity.dart';

/// Data transfer object for example entity.
///
/// DTOs are used for data transfer between layers and for serialization.
/// They map to/from domain entities.
class ExampleEntityDto {
  final String id;
  final String name;
  final String description;

  const ExampleEntityDto({
    required this.id,
    required this.name,
    required this.description,
  });

  /// Creates a DTO from a domain entity.
  factory ExampleEntityDto.fromEntity(ExampleEntity entity) {
    return ExampleEntityDto(
      id: entity.id,
      name: entity.name,
      description: entity.description,
    );
  }

  /// Converts DTO to domain entity.
  ExampleEntity toEntity() {
    return ExampleEntity(
      id: id,
      name: name,
      description: description,
    );
  }

  /// Creates a DTO from JSON.
  factory ExampleEntityDto.fromJson(Map<String, dynamic> json) {
    return ExampleEntityDto(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }

  /// Converts DTO to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  /// Creates a copy of this DTO with the given fields replaced.
  ExampleEntityDto copyWith({
    String? id,
    String? name,
    String? description,
  }) {
    return ExampleEntityDto(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }
}

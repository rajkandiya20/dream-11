/// Tournament model matching the tournaments table schema in Supabase.
///
/// Table schema:
/// id, name, logo, description, status, start_date, end_date
class TournamentModel {
  final String id;
  final String name;
  final String? logo;
  final String? description;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;

  const TournamentModel({
    required this.id,
    required this.name,
    this.logo,
    this.description,
    this.status = 'active',
    this.startDate,
    this.endDate,
    this.createdAt,
  });

  /// Create from JSON (Supabase response).
  factory TournamentModel.fromJson(Map<String, dynamic> json) {
    return TournamentModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      logo: json['logo'] as String?,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'active',
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  /// Convert to JSON for Supabase operations.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (logo != null) 'logo': logo,
      if (description != null) 'description': description,
      'status': status,
      if (startDate != null) 'start_date': startDate!.toIso8601String(),
      if (endDate != null) 'end_date': endDate!.toIso8601String(),
    };
  }

  /// Copy with modified fields.
  TournamentModel copyWith({
    String? id,
    String? name,
    String? logo,
    String? description,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
  }) {
    return TournamentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      logo: logo ?? this.logo,
      description: description ?? this.description,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Whether the tournament is currently active.
  bool get isActive => status == 'active';

  @override
  String toString() => 'TournamentModel(id: $id, name: $name, status: $status)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TournamentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

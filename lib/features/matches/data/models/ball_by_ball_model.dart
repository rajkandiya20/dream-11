/// Ball-by-ball model matching the ball_by_ball table schema in Supabase.
///
/// Table schema:
/// id, match_id, over_number, ball_number, batsman_id, bowler_id, runs, extras,
/// extras_type, is_wicket, wicket_type, fielder_id, is_boundary, is_six,
/// commentary, created_at
class BallByBallModel {
  final String id;
  final String matchId;
  final int overNumber;
  final int ballNumber;
  final String? batsmanId;
  final String? bowlerId;
  final int runs;
  final int extras;
  final String? extrasType;
  final bool isWicket;
  final String? wicketType;
  final String? fielderId;
  final bool isBoundary;
  final bool isSix;
  final String? commentary;
  final DateTime? createdAt;

  const BallByBallModel({
    required this.id,
    required this.matchId,
    this.overNumber = 0,
    this.ballNumber = 0,
    this.batsmanId,
    this.bowlerId,
    this.runs = 0,
    this.extras = 0,
    this.extrasType,
    this.isWicket = false,
    this.wicketType,
    this.fielderId,
    this.isBoundary = false,
    this.isSix = false,
    this.commentary,
    this.createdAt,
  });

  /// Create from JSON (Supabase response).
  factory BallByBallModel.fromJson(Map<String, dynamic> json) {
    return BallByBallModel(
      id: json['id'] as String? ?? '',
      matchId: json['match_id'] as String? ?? '',
      overNumber: json['over_number'] as int? ?? 0,
      ballNumber: json['ball_number'] as int? ?? 0,
      batsmanId: json['batsman_id'] as String?,
      bowlerId: json['bowler_id'] as String?,
      runs: json['runs'] as int? ?? 0,
      extras: json['extras'] as int? ?? 0,
      extrasType: json['extras_type'] as String?,
      isWicket: json['is_wicket'] as bool? ?? false,
      wicketType: json['wicket_type'] as String?,
      fielderId: json['fielder_id'] as String?,
      isBoundary: json['is_boundary'] as bool? ?? false,
      isSix: json['is_six'] as bool? ?? false,
      commentary: json['commentary'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  /// Convert to JSON for Supabase operations.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'match_id': matchId,
      'over_number': overNumber,
      'ball_number': ballNumber,
      if (batsmanId != null) 'batsman_id': batsmanId,
      if (bowlerId != null) 'bowler_id': bowlerId,
      'runs': runs,
      'extras': extras,
      if (extrasType != null) 'extras_type': extrasType,
      'is_wicket': isWicket,
      if (wicketType != null) 'wicket_type': wicketType,
      if (fielderId != null) 'fielder_id': fielderId,
      'is_boundary': isBoundary,
      'is_six': isSix,
      if (commentary != null) 'commentary': commentary,
    };
  }

  /// Copy with modified fields.
  BallByBallModel copyWith({
    String? id,
    String? matchId,
    int? overNumber,
    int? ballNumber,
    String? batsmanId,
    String? bowlerId,
    int? runs,
    int? extras,
    String? extrasType,
    bool? isWicket,
    String? wicketType,
    String? fielderId,
    bool? isBoundary,
    bool? isSix,
    String? commentary,
    DateTime? createdAt,
  }) {
    return BallByBallModel(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      overNumber: overNumber ?? this.overNumber,
      ballNumber: ballNumber ?? this.ballNumber,
      batsmanId: batsmanId ?? this.batsmanId,
      bowlerId: bowlerId ?? this.bowlerId,
      runs: runs ?? this.runs,
      extras: extras ?? this.extras,
      extrasType: extrasType ?? this.extrasType,
      isWicket: isWicket ?? this.isWicket,
      wicketType: wicketType ?? this.wicketType,
      fielderId: fielderId ?? this.fielderId,
      isBoundary: isBoundary ?? this.isBoundary,
      isSix: isSix ?? this.isSix,
      commentary: commentary ?? this.commentary,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get over.ball format string.
  String get overBall => '$overNumber.$ballNumber';

  /// Display text for this ball (runs, W for wicket, etc.)
  String get displayText {
    if (isWicket) return 'W';
    if (isSix) return '6';
    if (isBoundary) return '4';
    if (extras > 0) return '${runs + extras}${extrasType ?? ""}';
    return '$runs';
  }

  @override
  String toString() =>
      'BallByBallModel(id: $id, over: $overBall, runs: $runs)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BallByBallModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

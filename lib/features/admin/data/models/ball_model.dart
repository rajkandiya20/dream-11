/// Model representing a single ball delivery in a cricket match.
class BallEntry {
  final String? id;
  final String matchId;
  final int innings;
  final int overNo;
  final int ballNo;
  final String batsmanId;
  final String nonStrikerId;
  final String bowlerId;
  final int runs;
  final int extras;
  final String? extrasType; // wide, no_ball, bye, leg_bye
  final bool isWicket;
  final String? dismissalType;
  final String? dismissedPlayerId;
  final String? fielderId;
  final bool isLegal;
  final DateTime? createdAt;

  const BallEntry({
    this.id,
    required this.matchId,
    required this.innings,
    required this.overNo,
    required this.ballNo,
    required this.batsmanId,
    required this.nonStrikerId,
    required this.bowlerId,
    this.runs = 0,
    this.extras = 0,
    this.extrasType,
    this.isWicket = false,
    this.dismissalType,
    this.dismissedPlayerId,
    this.fielderId,
    this.isLegal = true,
    this.createdAt,
  });

  /// Create a BallEntry from a JSON map (Supabase row).
  factory BallEntry.fromJson(Map<String, dynamic> json) {
    return BallEntry(
      id: json['id'] as String?,
      matchId: json['match_id'] as String,
      innings: json['innings'] as int,
      overNo: json['over_no'] as int,
      ballNo: json['ball_no'] as int,
      batsmanId: json['batsman_id'] as String,
      nonStrikerId: json['non_striker_id'] as String,
      bowlerId: json['bowler_id'] as String,
      runs: (json['runs'] as num?)?.toInt() ?? 0,
      extras: (json['extras'] as num?)?.toInt() ?? 0,
      extrasType: json['extras_type'] as String?,
      isWicket: json['is_wicket'] as bool? ?? false,
      dismissalType: json['dismissal_type'] as String?,
      dismissedPlayerId: json['dismissed_player_id'] as String?,
      fielderId: json['fielder_id'] as String?,
      isLegal: json['is_legal'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Convert this BallEntry to a JSON map for Supabase insertion.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'match_id': matchId,
      'innings': innings,
      'over_no': overNo,
      'ball_no': ballNo,
      'batsman_id': batsmanId,
      'non_striker_id': nonStrikerId,
      'bowler_id': bowlerId,
      'runs': runs,
      'extras': extras,
      'extras_type': extrasType,
      'is_wicket': isWicket,
      'dismissal_type': dismissalType,
      'dismissed_player_id': dismissedPlayerId,
      'fielder_id': fielderId,
      'is_legal': isLegal,
    };
    // Only include id if it exists (for updates)
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  /// Create a copy with modified fields.
  BallEntry copyWith({
    String? id,
    String? matchId,
    int? innings,
    int? overNo,
    int? ballNo,
    String? batsmanId,
    String? nonStrikerId,
    String? bowlerId,
    int? runs,
    int? extras,
    String? extrasType,
    bool? isWicket,
    String? dismissalType,
    String? dismissedPlayerId,
    String? fielderId,
    bool? isLegal,
    DateTime? createdAt,
  }) {
    return BallEntry(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      innings: innings ?? this.innings,
      overNo: overNo ?? this.overNo,
      ballNo: ballNo ?? this.ballNo,
      batsmanId: batsmanId ?? this.batsmanId,
      nonStrikerId: nonStrikerId ?? this.nonStrikerId,
      bowlerId: bowlerId ?? this.bowlerId,
      runs: runs ?? this.runs,
      extras: extras ?? this.extras,
      extrasType: extrasType ?? this.extrasType,
      isWicket: isWicket ?? this.isWicket,
      dismissalType: dismissalType ?? this.dismissalType,
      dismissedPlayerId: dismissedPlayerId ?? this.dismissedPlayerId,
      fielderId: fielderId ?? this.fielderId,
      isLegal: isLegal ?? this.isLegal,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'BallEntry(innings: $innings, over: $overNo.$ballNo, '
        'runs: $runs, extras: $extras, wicket: $isWicket)';
  }
}

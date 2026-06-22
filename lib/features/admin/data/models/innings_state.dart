/// State model for the current batting position of a batsman.
class BatsmanState {
  final String id;
  final String name;
  final int runs;
  final int balls;
  final int fours;
  final int sixes;

  const BatsmanState({
    required this.id,
    required this.name,
    this.runs = 0,
    this.balls = 0,
    this.fours = 0,
    this.sixes = 0,
  });

  double get strikeRate => balls > 0 ? (runs / balls) * 100 : 0.0;

  BatsmanState copyWith({
    String? id,
    String? name,
    int? runs,
    int? balls,
    int? fours,
    int? sixes,
  }) {
    return BatsmanState(
      id: id ?? this.id,
      name: name ?? this.name,
      runs: runs ?? this.runs,
      balls: balls ?? this.balls,
      fours: fours ?? this.fours,
      sixes: sixes ?? this.sixes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'runs': runs,
      'balls': balls,
      'fours': fours,
      'sixes': sixes,
    };
  }

  factory BatsmanState.fromJson(Map<String, dynamic> json) {
    return BatsmanState(
      id: json['id'] as String,
      name: json['name'] as String,
      runs: (json['runs'] as num?)?.toInt() ?? 0,
      balls: (json['balls'] as num?)?.toInt() ?? 0,
      fours: (json['fours'] as num?)?.toInt() ?? 0,
      sixes: (json['sixes'] as num?)?.toInt() ?? 0,
    );
  }
}

/// State model for the current bowling position of a bowler.
class BowlerState {
  final String id;
  final String name;
  final double overs;
  final int maidens;
  final int runsConceded;
  final int wickets;
  final double economy;

  const BowlerState({
    required this.id,
    required this.name,
    this.overs = 0.0,
    this.maidens = 0,
    this.runsConceded = 0,
    this.wickets = 0,
    this.economy = 0.0,
  });

  BowlerState copyWith({
    String? id,
    String? name,
    double? overs,
    int? maidens,
    int? runsConceded,
    int? wickets,
    double? economy,
  }) {
    return BowlerState(
      id: id ?? this.id,
      name: name ?? this.name,
      overs: overs ?? this.overs,
      maidens: maidens ?? this.maidens,
      runsConceded: runsConceded ?? this.runsConceded,
      wickets: wickets ?? this.wickets,
      economy: economy ?? this.economy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'overs': overs,
      'maidens': maidens,
      'runs_conceded': runsConceded,
      'wickets': wickets,
      'economy': economy,
    };
  }

  factory BowlerState.fromJson(Map<String, dynamic> json) {
    return BowlerState(
      id: json['id'] as String,
      name: json['name'] as String,
      overs: (json['overs'] as num?)?.toDouble() ?? 0.0,
      maidens: (json['maidens'] as num?)?.toInt() ?? 0,
      runsConceded: (json['runs_conceded'] as num?)?.toInt() ?? 0,
      wickets: (json['wickets'] as num?)?.toInt() ?? 0,
      economy: (json['economy'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Represents a partnership between two batsmen.
class Partnership {
  final int runs;
  final int balls;
  final String batsman1Id;
  final String batsman2Id;

  const Partnership({
    this.runs = 0,
    this.balls = 0,
    this.batsman1Id = '',
    this.batsman2Id = '',
  });

  Partnership copyWith({
    int? runs,
    int? balls,
    String? batsman1Id,
    String? batsman2Id,
  }) {
    return Partnership(
      runs: runs ?? this.runs,
      balls: balls ?? this.balls,
      batsman1Id: batsman1Id ?? this.batsman1Id,
      batsman2Id: batsman2Id ?? this.batsman2Id,
    );
  }
}

/// Represents a fall of wicket entry.
class FallOfWicket {
  final int wicketNumber;
  final int score;
  final double overs;
  final String playerId;
  final String playerName;

  const FallOfWicket({
    required this.wicketNumber,
    required this.score,
    required this.overs,
    required this.playerId,
    required this.playerName,
  });

  Map<String, dynamic> toJson() {
    return {
      'wicket_number': wicketNumber,
      'score': score,
      'overs': overs,
      'player_id': playerId,
      'player_name': playerName,
    };
  }

  factory FallOfWicket.fromJson(Map<String, dynamic> json) {
    return FallOfWicket(
      wicketNumber: (json['wicket_number'] as num?)?.toInt() ?? 0,
      score: (json['score'] as num?)?.toInt() ?? 0,
      overs: (json['overs'] as num?)?.toDouble() ?? 0.0,
      playerId: json['player_id'] as String? ?? '',
      playerName: json['player_name'] as String? ?? '',
    );
  }
}

/// Full state of an innings for live scoring.
class InningsState {
  final int score;
  final int wickets;
  final double overs; // e.g. 12.5 means 12 overs and 5 balls
  final BatsmanState? striker;
  final BatsmanState? nonStriker;
  final BowlerState? bowler;
  final List<String> lastSixBalls;
  final Partnership partnership;
  final List<FallOfWicket> fallOfWickets;
  final int? target; // For 2nd innings
  final String? tossWinner;
  final String? electedTo;

  const InningsState({
    this.score = 0,
    this.wickets = 0,
    this.overs = 0.0,
    this.striker,
    this.nonStriker,
    this.bowler,
    this.lastSixBalls = const [],
    this.partnership = const Partnership(),
    this.fallOfWickets = const [],
    this.target,
    this.tossWinner,
    this.electedTo,
  });

  double get currentRunRate => overs > 0 ? score / overs : 0.0;

  double get requiredRunRate {
    if (target == null || target! <= score) return 0.0;
    final remainingRuns = target! - score;
    // Assuming T20: 20 overs max
    final oversRemaining = 20.0 - overs;
    if (oversRemaining <= 0) return 0.0;
    return remainingRuns / oversRemaining;
  }

  InningsState copyWith({
    int? score,
    int? wickets,
    double? overs,
    BatsmanState? striker,
    BatsmanState? nonStriker,
    BowlerState? bowler,
    List<String>? lastSixBalls,
    Partnership? partnership,
    List<FallOfWicket>? fallOfWickets,
    int? target,
    String? tossWinner,
    String? electedTo,
    bool clearStriker = false,
    bool clearNonStriker = false,
    bool clearBowler = false,
  }) {
    return InningsState(
      score: score ?? this.score,
      wickets: wickets ?? this.wickets,
      overs: overs ?? this.overs,
      striker: clearStriker ? null : (striker ?? this.striker),
      nonStriker: clearNonStriker ? null : (nonStriker ?? this.nonStriker),
      bowler: clearBowler ? null : (bowler ?? this.bowler),
      lastSixBalls: lastSixBalls ?? this.lastSixBalls,
      partnership: partnership ?? this.partnership,
      fallOfWickets: fallOfWickets ?? this.fallOfWickets,
      target: target ?? this.target,
      tossWinner: tossWinner ?? this.tossWinner,
      electedTo: electedTo ?? this.electedTo,
    );
  }
}

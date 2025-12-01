class Level {
  final int levelNumber;
  final String name;
  final double? levelSize;
  final double? distance;
  final int? nextLevelCorrection;
  final int? nextLevelWrong;

  const Level({
    required this.levelNumber,
    required this.name,
    this.levelSize,
    this.distance,
    this.nextLevelCorrection,
    this.nextLevelWrong,
  });

  // From JSON
  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      levelNumber: json['levelNumber'] as int,
      name: json['name'] as String,
      levelSize: (json['levelSize'] as num?)?.toDouble(),
      distance: (json['distance'] as num?)?.toDouble(),
      nextLevelCorrection: json['nextLevelCorrection'] as int?,
      nextLevelWrong: json['nextLevelWrong'] as int?,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'levelNumber': levelNumber,
      'name': name,
      'levelSize': levelSize,
      'distance': distance,
      'nextLevelCorrection': nextLevelCorrection,
      'nextLevelWrong': nextLevelWrong,
    };
  }
}

const Map<int, Level> levels = {
  0: Level(
    levelNumber: 0,
    name: '3/60',
    levelSize: 6.402,
    distance: 1.0,
    nextLevelCorrection: null,
    nextLevelWrong: 6,
  ),
  1: Level(
    levelNumber: 1,
    name: '6/60',
    levelSize: 9.592,
    distance: 3.0,
    nextLevelCorrection: 2,
    nextLevelWrong: null,
  ),
  2: Level(
    levelNumber: 2,
    name: '6/19',
    levelSize: 2.882,
    distance: 3.0,
    nextLevelCorrection: 3,
    nextLevelWrong: null,
  ),
  3: Level(
    levelNumber: 3,
    name: '6/12',
    levelSize: 1.914,
    distance: 3.0,
    nextLevelCorrection: 4,
    nextLevelWrong: null,
  ),
  4: Level(
    levelNumber: 4,
    name: '6/9.5',
    levelSize: 1.430,
    distance: 3.0,
    nextLevelCorrection: null,
    nextLevelWrong: null,
  ),
  5: Level(
    levelNumber: 5,
    name: 'N6',
    levelSize: 0.330,
    distance: 0.4,
    nextLevelCorrection: null,
    nextLevelWrong: null,
  ),
  6: Level(
    levelNumber: 6,
    name: 'FC',
    levelSize: null,
    distance: 0.3,
    nextLevelCorrection: null,
    nextLevelWrong: 7,
  ),
  7: Level(
    levelNumber: 7,
    name: 'PL-',
    levelSize: null,
    distance: 0.1,
    nextLevelCorrection: null,
    nextLevelWrong: 8,
  ),
  8: Level(
    levelNumber: 8,
    name: 'PL+',
    levelSize: null,
    distance: 0.1,
    nextLevelCorrection: null,
    nextLevelWrong: 7,
  ),
};

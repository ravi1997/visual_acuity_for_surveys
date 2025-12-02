import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Logger/logger.dart';
import '../../utils/helpers.dart';
import 'visual_test_screen.dart';

class TestScreenWrapper extends StatefulWidget {
  const TestScreenWrapper({super.key});

  @override
  State<TestScreenWrapper> createState() => _TestScreenWrapperState();
}

class _TestScreenWrapperState extends State<TestScreenWrapper> {
  bool _hasStartedNavigation = false;
  bool _showTest = false;
  bool _invalidArgs = false;
  late String _patientInfo;
  late String _visionType;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_showTest || _invalidArgs || _hasStartedNavigation) return;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args == null) {
      setState(() {
        _invalidArgs = true;
      });
      return;
    }

    _patientInfo = args['patientInfo'] ?? '';
    _visionType = args['visionType'] ?? '';

    // This still decides what distance page to show;
    // starting TEST level is now always 1 regardless of this.
    final distance = _visionType == 'Near Vision' ? 0.4 : 3.0;
    _hasStartedNavigation = true;

    // Schedule navigation to `/distance` after first frame, then show TestScreen
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await Navigator.pushNamed(
        context,
        '/distance',
        arguments: {'distance': distance},
      );

      if (!mounted) return;
      setState(() {
        _showTest = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_invalidArgs) {
      return const Scaffold(body: Center(child: Text('Invalid arguments')));
    }

    if (!_showTest) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return TestScreen(patientInfo: _patientInfo, visionType: _visionType);
  }
}

// ---------------- Direction enum & helpers ----------------

enum Direction { up, down, left, right }

extension DirectionX on Direction {
  double get rotation {
    switch (this) {
      case Direction.up:
        return pi / 2;
      case Direction.down:
        return -pi / 2;
      case Direction.left:
        return pi;
      case Direction.right:
        return 0;
    }
  }
}

Direction randomDirection(Direction current) {
  final all = Direction.values;
  Direction next;
  final rand = Random();
  do {
    next = all[rand.nextInt(all.length)];
  } while (next == current);
  return next;
}

Direction directionFromAngle(double angleDeg) {
  if (angleDeg >= -45 && angleDeg < 45) {
    return Direction.right;
  } else if (angleDeg >= 45 && angleDeg < 135) {
    return Direction.up;
  } else if (angleDeg >= -135 && angleDeg < -45) {
    return Direction.down;
  } else {
    return Direction.left;
  }
}

// ---------------- Level model ----------------

class Level {
  final int levelNumber;
  final String name;
  final double? levelSize;
  final double? distance;

  /// Level to go when patient passes this level
  final int? nextLevelCorrection;

  /// Level to go when patient fails this level
  final int? nextLevelWrong;

  const Level({
    required this.levelNumber,
    required this.name,
    this.levelSize,
    this.distance,
    this.nextLevelCorrection,
    this.nextLevelWrong,
  });

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
    nextLevelWrong: 6, // go to FC if fail 3/60
  ),
  1: Level(
    levelNumber: 1,
    name: '6/60',
    levelSize: 9.592,
    distance: 3.0,
    nextLevelCorrection: 2,
    nextLevelWrong: null, // special: demote to 0
  ),
  2: Level(
    levelNumber: 2,
    name: '6/19',
    levelSize: 2.882,
    distance: 3.0,
    nextLevelCorrection: 3,
    nextLevelWrong: null, // special: final 6/60
  ),
  3: Level(
    levelNumber: 3,
    name: '6/12',
    levelSize: 1.914,
    distance: 3.0,
    nextLevelCorrection: 4,
    nextLevelWrong: null, // special: final 6/18
  ),
  4: Level(
    levelNumber: 4,
    name: '6/9.5',
    levelSize: 1.430,
    distance: 3.0,
    nextLevelCorrection: null, // final
    nextLevelWrong: null, // final
  ),
  5: Level(
    levelNumber: 5,
    name: 'N6',
    levelSize: 0.330,
    distance: 0.4,
    nextLevelCorrection: null, // final N6
    nextLevelWrong: null, // final N6-failed
  ),
  6: Level(
    levelNumber: 6,
    name: 'FC',
    levelSize: null,
    distance: 0.3,
    nextLevelCorrection: null, // final FC on pass
    nextLevelWrong: 7, // go to PL- on fail
  ),
  7: Level(
    levelNumber: 7,
    name: 'PL-',
    levelSize: null,
    distance: 0.1,
    nextLevelCorrection: null, // final PL- on pass
    nextLevelWrong: 8, // go to PL+ on fail (to confirm)
  ),
  8: Level(
    levelNumber: 8,
    name: 'PL+',
    levelSize: null,
    distance: 0.1,
    nextLevelCorrection: null, // final PL+ on pass
    nextLevelWrong: 7, // back to PL- on fail (re-check)
  ),
};

// ---------------- Test Screen ----------------

class TestScreen extends StatefulWidget {
  final String patientInfo;
  final String visionType;

  const TestScreen({
    super.key,
    required this.patientInfo,
    required this.visionType,
  });

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  // SharedPreferences keys
  static const String _keyLevel = 'etest_level';
  static const String _keyDistance = 'etest_distance';
  static const String _keyTotalCorrect = 'etest_totalCorrect';
  static const String _keyTotalWrong = 'etest_totalWrong';
  static const String _keyIgnoredGestures = 'etest_ignoredGestures';

  // Constants
  static const int _maxLuxValue = 15000;
  static const double _minVelocityThreshold = 100.0;
  static const double _distanceTolerance = 0.01; // for double comparisons
  static const double _minSwipeDistance = 10.0; // to ignore taps

  // State variables
  Direction _currentDirection = Direction.up;

  int _level = 1;
  int _correctAtLevel = 0;
  int _wrongAtLevel = 0;
  int _attemptsAtLevel = 0;

  int _totalCorrect = 0;
  int _totalWrong = 0;
  int _ignoredGestures = 0;

  double _distance = 3.0;
  bool _testCompleted = false;

  // Timers / gesture tracking
  Timer? _ambientLightTimer;
  Offset _swipeDelta = Offset.zero;

  SharedPreferences? _prefs;

  // ---------------- Lifecycle ----------------

  @override
  void initState() {
    super.initState();
    _initializeDefaults(); // CHANGED: always level 1
    _initSharedPreferences(); // CHANGED: no longer overrides level/distance
    setBrightnessTo90();
    _currentDirection = randomDirection(_currentDirection);
    _startAmbientLightTimer();
  }

  void _initializeDefaults() {
    // Always start from level 1 and 3m
    _level = 1; // CHANGED
    _distance = levels[1]?.distance ?? 3.0; // CHANGED
    _correctAtLevel = 0;
    _wrongAtLevel = 0;
    _attemptsAtLevel = 0;
    _totalCorrect = 0;
    _totalWrong = 0;
    _ignoredGestures = 0;
    _testCompleted = false;

    logger.d("Starting test for ${widget.visionType} at level: $_level");
  }

  Future<void> _initSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;

    final hasLevelKey = prefs.containsKey(_keyLevel);

    if (!hasLevelKey) {
      // First run: persist current defaults (level 1, 3m)
      await prefs.setInt(_keyLevel, _level);
      await prefs.setDouble(_keyDistance, _distance);
      await prefs.setInt(_keyTotalCorrect, _totalCorrect);
      await prefs.setInt(_keyTotalWrong, _totalWrong);
      await prefs.setInt(_keyIgnoredGestures, _ignoredGestures);
    }

    if (!mounted) return;

    // CHANGED:
    // We NO LONGER load level or distance from prefs.
    // Test always starts at level 1, 3m.
    // We only restore counters (if you want even those reset, remove these lines).

    setState(() {
      _totalCorrect = prefs.getInt(_keyTotalCorrect) ?? _totalCorrect;
      _totalWrong = prefs.getInt(_keyTotalWrong) ?? _totalWrong;
      _ignoredGestures = prefs.getInt(_keyIgnoredGestures) ?? _ignoredGestures;
    });
  }

  void _startAmbientLightTimer() {
    _ambientLightTimer = Timer.periodic(const Duration(seconds: 15), (
      timer,
    ) async {
      final ok = await checkAmbientLight(_maxLuxValue, false, context);

      if (!mounted) return;

      if (ok) {
        setState(() {
          _testCompleted = true;
        });
        _ambientLightTimer?.cancel();
        logger.d('Ambient light condition triggered: testCompleted = true');
      }
    });
  }

  @override
  void dispose() {
    _ambientLightTimer?.cancel();
    ScreenBrightness().resetApplicationScreenBrightness();
    _persistProgress();
    super.dispose();
  }

  Future<void> _persistProgress() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setInt(_keyLevel, _level);
    await prefs.setDouble(_keyDistance, _distance);
    await prefs.setInt(_keyTotalCorrect, _totalCorrect);
    await prefs.setInt(_keyTotalWrong, _totalWrong);
    await prefs.setInt(_keyIgnoredGestures, _ignoredGestures);
  }

  // ---------------- Gesture handling ----------------

  void _onPanStart(DragStartDetails details) {
    _swipeDelta = Offset.zero;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _swipeDelta += details.delta;
  }

  void _onPanEnd(DragEndDetails details) {
    if (_testCompleted) {
      logger.d('Swipe ignored: test already completed.');
      return;
    }

    final velocity = details.velocity.pixelsPerSecond;
    final speed = velocity.distance;

    // Adaptive threshold based on ignored gestures
    double threshold = _minVelocityThreshold;
    if (_ignoredGestures >= 10) {
      threshold = 60;
    } else if (_ignoredGestures >= 5) {
      threshold = 80;
    }

    if (_swipeDelta.distance < _minSwipeDistance || speed < threshold) {
      setState(() {
        _ignoredGestures++;
      });
      logger.d(
        'Gesture ignored: distance=${_swipeDelta.distance.toStringAsFixed(2)}, '
        'speed=${speed.toStringAsFixed(2)}, threshold=$threshold',
      );
      return;
    }

    final angleRad = atan2(_swipeDelta.dy, _swipeDelta.dx);
    final angleDeg = angleRad * (180 / pi);

    final swipeDirection = directionFromAngle(angleDeg);
    logger.d(
      'Swipe detected: $swipeDirection, angle=${angleDeg.toStringAsFixed(2)}, '
      'velocity=${speed.toStringAsFixed(2)}',
    );

    _processSwipe(swipeDirection);
  }

  // ---------------- Test logic ----------------

  void _processSwipe(Direction swipeDirection) {
    if (_testCompleted) return;

    setState(() {
      _attemptsAtLevel++;
      logger.d(
        'Swipe attempt #$_attemptsAtLevel at level $_level with distance ${_distance}m',
      );

      if (swipeDirection == _currentDirection) {
        _correctAtLevel++;
        _totalCorrect++;
        logger.d(
          '✅ Correct swipe: $swipeDirection (Correct at level: $_correctAtLevel)',
        );
      } else {
        _wrongAtLevel++;
        _totalWrong++;
        logger.d(
          '❌ Wrong swipe: $swipeDirection, expected: $_currentDirection '
          '(Wrong at level: $_wrongAtLevel)',
        );
      }

      final isPass = _correctAtLevel >= 4;
      final isFail = _wrongAtLevel >= 2;

      logger.d('Check pass/fail: isPass=$isPass, isFail=$isFail');

      if (!_testCompleted && (isPass || isFail)) {
        _handleLevelProgression(isPass, isFail);
      }

      _currentDirection = randomDirection(_currentDirection);
      logger.d('🧭 New direction generated: $_currentDirection');
    });

    _persistProgress(); // best-effort
  }

  bool _distanceMatches(Level level) {
    final cfg = level.distance;
    if (cfg == null) return true; // if not configured, don't block
    return (_distance - cfg).abs() < _distanceTolerance;
  }

  void _handleLevelProgression(bool isPass, bool isFail) {
    final levelConfig = levels[_level];
    if (levelConfig == null) {
      logger.w('No Level config found for level $_level');
      _resetLevelCounters();
      return;
    }

    logger.d(
      '↪ Case: Level ${levelConfig.levelNumber} (${levelConfig.name}) at '
      '${levelConfig.distance ?? _distance} m',
    );

    if (!_distanceMatches(levelConfig)) {
      logger.d(
        'Distance mismatch for level ${levelConfig.levelNumber}. '
        'Expected ${levelConfig.distance}, actual $_distance. '
        'Resetting counters.',
      );
      _resetLevelCounters();
      return;
    }

    switch (_level) {
      // Distance vision
      case 1:
        if (isPass) {
          _promoteTo(levelConfig.nextLevelCorrection ?? 2);
        } else if (isFail) {
          _demoteToLevel0();
        }
        break;

      case 2:
        if (isPass) {
          _promoteTo(levelConfig.nextLevelCorrection ?? 3);
        } else if (isFail) {
          logger.d('❌ Failed at level 2 — Final Acuity: 6/60');
          _showSummary('6/60');
        }
        break;

      case 3:
        if (isPass) {
          _promoteTo(levelConfig.nextLevelCorrection ?? 4);
        } else if (isFail) {
          logger.d('❌ Failed at level 3 — Final Acuity: 6/18');
          _showSummary('6/18');
        }
        break;

      case 4:
        if (isPass) {
          logger.d('✅ Passed at level 4 — Final Acuity: 6/9');
          _showSummary('6/9');
        } else if (isFail) {
          logger.d('❌ Failed at level 4 — Final Acuity: 6/12');
          _showSummary('6/12');
        }
        break;

      // Near vision
      case 5:
        logger.d('↪ Case: Level 5 Near Vision');
        if (isPass) {
          logger.d('✅ Passed near vision — Final Acuity: N6');
          _showSummary('N6');
        } else if (isFail) {
          logger.d('❌ Failed near vision — Final Acuity: N6-failed');
          _showSummary('N6-failed'); // interpret as N12 if needed
        }
        break;

      // 3/60 at 1m
      case 0:
        logger.d('↪ Case: Level 0 at 1m (3/60)');
        if (isPass) {
          logger.d('✅ Passed at 3/60 — Final Acuity: 3/60');
          _showSummary('3/60');
        } else if (isFail) {
          logger.d('❌ Failed at 3/60 — switching to visual test');
          _openVisualTestScreen();
        }
        break;

      // FC / PL logic
      case 6: // FC
        if (isPass) {
          logger.d('✅ Passed at FC — Final Acuity: FC');
          _showSummary('FC');
        } else if (isFail && levelConfig.nextLevelWrong != null) {
          _setLevel(levelConfig.nextLevelWrong!);
        }
        break;

      case 7: // PL-
        if (isPass) {
          logger.d('✅ PL- confirmed — Final Acuity: PL-');
          _showSummary('PL-');
        } else if (isFail && levelConfig.nextLevelWrong != null) {
          _setLevel(levelConfig.nextLevelWrong!); // go to PL+
        }
        break;

      case 8: // PL+
        if (isPass) {
          logger.d('✅ PL+ confirmed — Final Acuity: PL+');
          _showSummary('PL+');
        } else if (isFail && levelConfig.nextLevelWrong != null) {
          _setLevel(levelConfig.nextLevelWrong!); // back to PL-
        }
        break;

      default:
        logger.w('Unhandled level $_level. Resetting counters.');
        _resetLevelCounters();
        break;
    }
  }

  void _promoteTo(int nextLevel) {
    logger.d('✅ Promoted to level $nextLevel');
    _setLevel(nextLevel);
  }

  void _demoteToLevel0() {
    logger.d('❌ Demoted to level 0 (3/60), distance reduced to 1.0 m');
    _setLevel(0, overrideDistance: levels[0]?.distance ?? 1.0);
  }

  void _setLevel(int newLevel, {double? overrideDistance}) {
    final cfg = levels[newLevel];
    setState(() {
      _level = newLevel;
      _distance = overrideDistance ?? cfg?.distance ?? _distance;
      _resetLevelCounters();
    });
  }

  void _resetLevelCounters() {
    _correctAtLevel = 0;
    _wrongAtLevel = 0;
    _attemptsAtLevel = 0;
  }

  void _showSummary(String finalResult) {
    _testCompleted = true;
    _persistProgress();

    Navigator.pushReplacementNamed(
      context,
      '/summary',
      arguments: {
        'finalResult': finalResult,
        'totalCorrect': _totalCorrect,
        'totalWrong': _totalWrong,
        'ignoredGestures': _ignoredGestures,
        'patientInfo': widget.patientInfo,
        'visionType': widget.visionType,
      },
    );
  }

  void _openVisualTestScreen() {
    _testCompleted = true;
    _persistProgress();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => VisualTestScreen(
          patientInfo: widget.patientInfo,
          visionType: widget.visionType,
        ),
      ),
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final currentLevelConfig = levels[_level];
    logger.d('Building E Optotype Test Screen at level: $_level');

    final levelSizeCm = currentLevelConfig?.levelSize ?? 8.73;
    logger.d('Building E Optotype Test Screen at size: $levelSizeCm cm');

    return FutureBuilder<Size>(
      future: getCalibratedSvgSize(context, levelSizeCm, levelSizeCm),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final size = snapshot.data!;
        logger.i(
          '📐 SVG will render: ${size.width.toStringAsFixed(2)} x ${size.height.toStringAsFixed(2)} px '
          '(from $levelSizeCm cm)',
        );

        return Scaffold(
          backgroundColor: const Color(0xFFFFFEF5),
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            // Center ensures the *center point* is in the middle of the screen
            child: Center(
              child: OverflowBox(
                alignment: Alignment.center,
                minWidth: 0,
                minHeight: 0,
                maxWidth: double.infinity,
                maxHeight: double.infinity,
                child: Transform.rotate(
                  angle: _currentDirection.rotation,
                  child: SvgPicture.asset(
                    'assets/images/tests/e_optotype.svg',
                    width: size.width,
                    height: size.height,
                    fit: BoxFit.none, // 🔥 do NOT scale to fit
                    allowDrawingOutsideViewBox: true, // 🔥 allow SVG overflow
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

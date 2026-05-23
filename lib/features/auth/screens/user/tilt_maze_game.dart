import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:finalproject/services/minigame_service.dart';

// ── MAZE CELL ──────────────────────────────────────────────────────────────
class MazeCell {
  bool wallTop, wallRight, wallBottom, wallLeft;
  bool visited;

  MazeCell({
    this.wallTop = true,
    this.wallRight = true,
    this.wallBottom = true,
    this.wallLeft = true,
    this.visited = false,
  });
}

// ── MAZE GENERATOR (Recursive Backtracking) ────────────────────────────────
class MazeGenerator {
  final int cols;
  final int rows;
  late List<List<MazeCell>> grid;
  final _rng = Random();

  MazeGenerator({required this.cols, required this.rows}) {
    grid = List.generate(
        rows, (_) => List.generate(cols, (_) => MazeCell()));
    _generate(0, 0);
  }

  void _generate(int col, int row) {
    grid[row][col].visited = true;
    final dirs = [0, 1, 2, 3]..shuffle(_rng);
    for (final d in dirs) {
      final nc = col + [0, 1, 0, -1][d];
      final nr = row + [-1, 0, 1, 0][d];
      if (nr < 0 || nr >= rows || nc < 0 || nc >= cols) continue;
      if (grid[nr][nc].visited) continue;
      // Remove walls between current and neighbor
      switch (d) {
        case 0: // up
          grid[row][col].wallTop = false;
          grid[nr][nc].wallBottom = false;
          break;
        case 1: // right
          grid[row][col].wallRight = false;
          grid[nr][nc].wallLeft = false;
          break;
        case 2: // down
          grid[row][col].wallBottom = false;
          grid[nr][nc].wallTop = false;
          break;
        case 3: // left
          grid[row][col].wallLeft = false;
          grid[nr][nc].wallRight = false;
          break;
      }
      _generate(nc, nr);
    }
  }
}

// ── MAZE PAINTER ───────────────────────────────────────────────────────────
class MazePainter extends CustomPainter {
  final List<List<MazeCell>> grid;
  final int cols;
  final int rows;
  final Offset ballPos;      // in maze units (0..cols, 0..rows)
  final double ballRadius;   // in maze units

  MazePainter({
    required this.grid,
    required this.cols,
    required this.rows,
    required this.ballPos,
    required this.ballRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / cols;
    final cellH = size.height / rows;

    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFF5F1E8),
    );

    // Finish cell highlight (bottom-right)
    canvas.drawRect(
      Rect.fromLTWH(
          (cols - 1) * cellW, (rows - 1) * cellH, cellW, cellH),
      Paint()..color = const Color(0xFF2F3E2F).withOpacity(0.15),
    );

    // Finish flag icon area
    final flagPaint = Paint()..color = const Color(0xFF2F3E2F);
    final flagCenter = Offset(
        (cols - 0.5) * cellW, (rows - 0.5) * cellH);
    canvas.drawCircle(flagCenter, cellW * 0.28, flagPaint);
    // Draw checkered pattern on finish
    final checker = Paint()..color = Colors.white;
    canvas.drawRect(
      Rect.fromCenter(
          center: flagCenter,
          width: cellW * 0.3,
          height: cellH * 0.3),
      Paint()..color = Colors.transparent,
    );

    // Walls
    final wallPaint = Paint()
      ..color = const Color(0xFF2F3E2F)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final x = c * cellW;
        final y = r * cellH;
        final cell = grid[r][c];

        if (cell.wallTop) {
          canvas.drawLine(Offset(x, y), Offset(x + cellW, y), wallPaint);
        }
        if (cell.wallRight) {
          canvas.drawLine(
              Offset(x + cellW, y), Offset(x + cellW, y + cellH), wallPaint);
        }
        if (cell.wallBottom) {
          canvas.drawLine(
              Offset(x, y + cellH), Offset(x + cellW, y + cellH), wallPaint);
        }
        if (cell.wallLeft) {
          canvas.drawLine(Offset(x, y), Offset(x, y + cellH), wallPaint);
        }
      }
    }

    // Outer border
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..color = const Color(0xFF2F3E2F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Ball
    final bx = ballPos.dx * cellW;
    final by = ballPos.dy * cellH;
    final br = ballRadius * cellW;

    // Ball shadow
    canvas.drawCircle(
      Offset(bx + 2, by + 2),
      br,
      Paint()..color = Colors.black26,
    );

    // Ball gradient effect
    final ballGradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      colors: [
        const Color(0xFFFF7043),
        const Color(0xFFE4572E),
        const Color(0xFFB83E1F),
      ],
    );
    canvas.drawCircle(
      Offset(bx, by),
      br,
      Paint()
        ..shader = ballGradient.createShader(
          Rect.fromCircle(center: Offset(bx, by), radius: br),
        ),
    );

    // Ball shine
    canvas.drawCircle(
      Offset(bx - br * 0.3, by - br * 0.3),
      br * 0.25,
      Paint()..color = Colors.white54,
    );
  }

  @override
  bool shouldRepaint(MazePainter old) =>
      old.ballPos != ballPos || old.grid != grid;
}

// ── TILT MAZE GAME SCREEN ──────────────────────────────────────────────────
class TiltMazeGame extends StatefulWidget {
  const TiltMazeGame({super.key});

  @override
  State<TiltMazeGame> createState() => _TiltMazeGameState();
}

class _TiltMazeGameState extends State<TiltMazeGame>
    with TickerProviderStateMixin {
  static const int kCols = 7;
  static const int kRows = 10;
  static const double kBallRadius = 0.28; // in cell units
  static const double kSpeed = 0.06;      // cells per frame per unit gyro

  late MazeGenerator _mazeGen;
  StreamSubscription<GyroscopeEvent>? _gyroSub;

  // Ball position in cell units
  double _bx = 0.5;
  double _by = 0.5;

  // Gyro velocity (smoothed)
  double _vx = 0;
  double _vy = 0;

  // Raw gyro for smoothing
  double _gx = 0;
  double _gy = 0;

  late AnimationController _loopCtrl;
  late AnimationController _winCtrl;

  bool _won = false;
  bool _isLoading = false;
  int _level = 1;
  int _pointsEarned = 0;

  // Timer
  int _secondsLeft = 60;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _generateMaze();
    _startGyroscope();
    _startLoop();
    _startCountdown();
  }

  void _generateMaze() {
    _mazeGen = MazeGenerator(cols: kCols, rows: kRows);
    _bx = 0.5;
    _by = 0.5;
    _vx = 0;
    _vy = 0;
    _won = false;
    _secondsLeft = 60;
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _secondsLeft--;
        if (_secondsLeft <= 0) {
          _secondsLeft = 0;
          _countdownTimer?.cancel();
          if (!_won) _showTimeUpDialog();
        }
      });
    });
  }

  void _startGyroscope() {
    _gyroSub = gyroscopeEventStream().listen((event) {
      // Smooth raw gyro values
      _gx = _gx * 0.6 + event.y * 0.4; // tilt left/right → move x
      _gy = _gy * 0.6 + event.x * 0.4; // tilt forward/back → move y
    });
  }

  void _startLoop() {
    _loopCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _loopCtrl.addListener(_update);

    _winCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  void _update() {
    if (_won || _secondsLeft <= 0) return;

    // Apply gyro to velocity (with damping)
    _vx = _vx * 0.7 + _gx * kSpeed;
    _vy = _vy * 0.7 + _gy * kSpeed;

    // Clamp velocity
    _vx = _vx.clamp(-0.2, 0.2);
    _vy = _vy.clamp(-0.2, 0.2);

    double nx = _bx + _vx;
    double ny = _by + _vy;

    // Wall collision
    final col = _bx.floor().clamp(0, kCols - 1);
    final row = _by.floor().clamp(0, kRows - 1);
    final cell = _mazeGen.grid[row][col];

    // Check walls and bounce
    if (_vx > 0 && cell.wallRight) {
      final wallX = (col + 1).toDouble();
      if (nx + kBallRadius > wallX) {
        nx = wallX - kBallRadius;
        _vx = 0;
      }
    }
    if (_vx < 0 && cell.wallLeft) {
      final wallX = col.toDouble();
      if (nx - kBallRadius < wallX) {
        nx = wallX + kBallRadius;
        _vx = 0;
      }
    }
    if (_vy > 0 && cell.wallBottom) {
      final wallY = (row + 1).toDouble();
      if (ny + kBallRadius > wallY) {
        ny = wallY - kBallRadius;
        _vy = 0;
      }
    }
    if (_vy < 0 && cell.wallTop) {
      final wallY = row.toDouble();
      if (ny - kBallRadius < wallY) {
        ny = wallY + kBallRadius;
        _vy = 0;
      }
    }

    // Boundary clamp
    nx = nx.clamp(kBallRadius, kCols - kBallRadius);
    ny = ny.clamp(kBallRadius, kRows - kBallRadius);

    setState(() {
      _bx = nx;
      _by = ny;
    });

    // Check win: ball center near finish cell center (bottom-right)
    final finCx = kCols - 0.5;
    final finCy = kRows - 0.5;
    final dist = sqrt(pow(_bx - finCx, 2) + pow(_by - finCy, 2));
    if (dist < 0.45 && !_won) {
      _onWin();
    }
  }

  Future<void> _onWin() async {
    _won = true;
    _countdownTimer?.cancel();
    _winCtrl.forward();

    // Calculate points: base + time bonus
    final timeBonus = (_secondsLeft * 0.5).round();
    final basePoints = 50 * _level;
    _pointsEarned = basePoints + timeBonus;

    // Try submit to backend
    try {
      setState(() => _isLoading = true);
      await MiniGameService.submitMazeWin(points: _pointsEarned);
    } catch (_) {
      // Ignore if backend fails, still show win dialog
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }

    if (!mounted) return;
    _showWinDialog();
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF2F3E2F),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emoji_events,
                    color: Colors.amber, size: 40),
              ),
              const SizedBox(height: 16),
              const Text("Level Selesai! 🎉",
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                "+$_pointsEarned Poin",
                style: const TextStyle(
                    fontSize: 22,
                    color: Color(0xFF2F3E2F),
                    fontWeight: FontWeight.bold),
              ),
              Text(
                "Termasuk bonus waktu: +${(_secondsLeft * 0.5).round()} pts",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text("Keluar"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _level++;
                          _generateMaze();
                        });
                        _startCountdown();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE4572E),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text("Level Berikut",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTimeUpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFE4572E),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.timer_off,
                    color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              const Text("Waktu Habis! ⏰",
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                "Coba lagi dan capai finish lebih cepat!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text("Keluar"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() => _generateMaze());
                        _startCountdown();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F3E2F),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text("Coba Lagi",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _gyroSub?.cancel();
    _loopCtrl.dispose();
    _winCtrl.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerColor = _secondsLeft <= 10
        ? const Color(0xFFE4572E)
        : const Color(0xFF2F3E2F);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              decoration: const BoxDecoration(
                color: Color(0xFF2F3E2F),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Tilt Maze",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        Text("Miringkan HP untuk gerakkan bola",
                            style: TextStyle(
                                color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  // Timer
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _secondsLeft <= 10
                          ? const Color(0xFFE4572E)
                          : Colors.white24,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          "$_secondsLeft s",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Level badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      "Lv.$_level",
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── LEGEND ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _legendItem(
                      color: const Color(0xFFE4572E),
                      label: "Bola (kamu)"),
                  _legendItem(
                      color: const Color(0xFF2F3E2F),
                      label: "Finish (pojok kanan bawah)"),
                  Row(
                    children: const [
                      Icon(Icons.screen_rotation,
                          size: 13, color: Colors.grey),
                      SizedBox(width: 4),
                      Text("Gyroscope",
                          style:
                              TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── MAZE ────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 12)
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CustomPaint(
                      painter: MazePainter(
                        grid: _mazeGen.grid,
                        cols: kCols,
                        rows: kRows,
                        ballPos: Offset(_bx, _by),
                        ballRadius: kBallRadius,
                      ),
                      child: Container(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }
}
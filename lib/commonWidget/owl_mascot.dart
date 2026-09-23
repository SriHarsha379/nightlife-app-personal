import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Hii Owl's moods: idle (blinks, floats), thinking (looks around, music
/// notes) and happy (smiling eyes - shown briefly when a reply lands).
enum OwlMood { idle, thinking, happy }

const Color _pink = Color(0xFFFF1CC0);
const Color _violet = Color(0xFF7B2FF7);
const Color _gold = Color(0xFFFFC74D);
const Color _ink = Color(0xFF1A0B22);

/// Paints the DJ owl in a 100x100 design box scaled to [size].
void paintOwl(
  Canvas canvas,
  double size, {
  double blink = 0,
  Offset look = Offset.zero,
  OwlMood mood = OwlMood.idle,
  double notesPhase = 0,
}) {
  canvas.save();
  canvas.scale(size / 100, size / 100);
  final p = Paint()..isAntiAlias = true;

  // ear tufts
  p.color = const Color(0xFF4B2A5E);
  for (final sx in const [-1.0, 1.0]) {
    canvas.drawPath(
      Path()
        ..moveTo(50 + sx * 18, 30)
        ..lineTo(50 + sx * 30, 10)
        ..lineTo(50 + sx * 33, 34)
        ..close(),
      p,
    );
  }

  // body
  p.shader = ui.Gradient.linear(const Offset(0, 20), const Offset(0, 95),
      const [Color(0xFF7A4A94), Color(0xFF2A1434)]);
  canvas.drawOval(Rect.fromCenter(center: const Offset(50, 56), width: 66, height: 73.9), p);
  p.shader = null;

  // wings
  p.color = const Color(0xFF3A1F4A);
  for (final sx in const [-1.0, 1.0]) {
    canvas.save();
    canvas.translate(50 + sx * 29, 66);
    canvas.rotate(sx * -0.25);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 16.5, height: 30), p);
    canvas.restore();
  }

  // belly + feather marks
  p.color = const Color(0xFF5E3775);
  canvas.drawOval(Rect.fromCenter(center: const Offset(50, 72), width: 36, height: 32.4), p);
  final stroke = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.6
    ..strokeCap = StrokeCap.round
    ..color = const Color(0xE68E62A8);
  for (final y in const [65.0, 71.0, 77.0]) {
    for (final x in const [43.0, 50.0, 57.0]) {
      canvas.drawPath(
        Path()
          ..moveTo(x - 3, y)
          ..cubicTo(x - 1, y + 3, x + 1, y + 3, x + 3, y),
        stroke,
      );
    }
  }

  // face disc
  p.color = const Color(0xFFE9D8F2);
  canvas.drawCircle(const Offset(39, 44), 15, p);
  canvas.drawCircle(const Offset(61, 44), 15, p);

  // eyes
  for (final sx in const [-1.0, 1.0]) {
    final c = Offset(50 + sx * 11, 44);
    p.color = _pink;
    canvas.drawCircle(c, 11.5, p);
    p.color = Colors.white;
    canvas.drawCircle(c, 9.5, p);
    if (mood == OwlMood.happy) {
      final s = Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round
        ..color = _ink;
      canvas.drawPath(
        Path()
          ..moveTo(c.dx - 5, c.dy + 2)
          ..cubicTo(c.dx - 3, c.dy - 4, c.dx + 3, c.dy - 4, c.dx + 5, c.dy + 2),
        s,
      );
      continue;
    }
    final pupil = c + Offset(look.dx * 3.2, look.dy * 2.5);
    p.color = _ink;
    canvas.drawCircle(pupil, 5.6, p);
    p.color = Colors.white;
    canvas.drawCircle(pupil + const Offset(1.8, -2), 1.9, p);
    canvas.drawCircle(pupil + const Offset(-1.6, 1.8), 0.9, p);
    if (blink > 0) {
      canvas.save();
      canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: 9.6)));
      p.color = const Color(0xFF6B3F84);
      canvas.drawRect(Rect.fromLTWH(c.dx - 12, c.dy - 12, 24, 24 * blink.clamp(0.0, 1.0)), p);
      canvas.restore();
    }
  }

  // music notes while thinking - drift up and fade
  if (mood == OwlMood.thinking) {
    const notes = [Offset(12, 22), Offset(86, 16), Offset(90, 40)];
    for (var i = 0; i < notes.length; i++) {
      final t = (notesPhase + i / notes.length) % 1.0;
      final o = notes[i] + Offset(math.sin(t * math.pi * 2) * 1.5, -t * 8);
      final alpha = (1 - t).clamp(0.0, 1.0);
      final np = Paint()
        ..isAntiAlias = true
        ..color = _pink.withOpacity(alpha);
      canvas.drawOval(Rect.fromCenter(center: o, width: 6.5, height: 5.2), np);
      np
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3;
      canvas.drawPath(
        Path()
          ..moveTo(o.dx + 2.9, o.dy)
          ..lineTo(o.dx + 2.9, o.dy - 9)
          ..lineTo(o.dx + 6, o.dy - 7.5),
        np,
      );
    }
  }

  // beak
  p.color = _gold;
  canvas.drawPath(
    Path()
      ..moveTo(46, 53)
      ..lineTo(54, 53)
      ..lineTo(50, 60)
      ..close(),
    p,
  );

  // headphones
  final arcRect = Rect.fromCircle(center: const Offset(50, 44), radius: 31);
  final band = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4.2
    ..color = _ink;
  canvas.drawArc(arcRect, 200 * math.pi / 180, 140 * math.pi / 180, false, band);
  band
    ..strokeWidth = 2.2
    ..color = _pink;
  canvas.drawArc(arcRect, 205 * math.pi / 180, 130 * math.pi / 180, false, band);
  for (final sx in const [-1.0, 1.0]) {
    p.color = _ink;
    canvas.drawOval(Rect.fromCenter(center: Offset(50 + sx * 31, 47), width: 11.2, height: 18), p);
    p.color = _pink;
    canvas.drawOval(Rect.fromCenter(center: Offset(50 + sx * 31.5, 47), width: 7.2, height: 12.8), p);
  }

  // feet
  p.color = _gold;
  for (final sx in const [-1.0, 1.0]) {
    for (final dx in const [-2.5, 0.0, 2.5]) {
      canvas.drawCircle(Offset(50 + sx * 9 + dx, 93), 1.9, p);
    }
  }
  canvas.restore();
}

/// Shared animation driver: gentle float, random blinks, look-around,
/// music-note phase and a glow pulse. Respects "reduce motion".
mixin _OwlAnimation<T extends StatefulWidget> on State<T>, TickerProviderStateMixin<T> {
  late final AnimationController loop =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));
  late final AnimationController blinkCtl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 130));
  Timer? _blinkTimer;
  final math.Random _rng = math.Random();

  bool get animate;

  void startOwlAnimation() {
    if (!animate) return;
    loop.repeat();
    _scheduleBlink();
  }

  void _scheduleBlink() {
    _blinkTimer?.cancel();
    _blinkTimer = Timer(Duration(milliseconds: 2400 + _rng.nextInt(3200)), () async {
      if (!mounted) return;
      await blinkCtl.forward(from: 0);
      if (!mounted) return;
      await blinkCtl.reverse();
      if (mounted) _scheduleBlink();
    });
  }

  Offset lookFor(OwlMood mood) {
    final a = loop.value * math.pi * 2;
    if (mood == OwlMood.thinking) return Offset(math.cos(a) * 0.9, -0.45 + math.sin(a) * 0.35);
    return Offset(math.sin(a) * 0.22, 0);
  }

  double get bob => math.sin(loop.value * math.pi * 2);

  @override
  void dispose() {
    _blinkTimer?.cancel();
    loop.dispose();
    blinkCtl.dispose();
    super.dispose();
  }
}

/// The full-body animated owl (welcome screen, empty states).
class OwlMascot extends StatefulWidget {
  final double size;
  final OwlMood mood;
  final bool animate;
  const OwlMascot({super.key, this.size = 96, this.mood = OwlMood.idle, this.animate = true});

  @override
  State<OwlMascot> createState() => _OwlMascotState();
}

class _OwlMascotState extends State<OwlMascot> with TickerProviderStateMixin, _OwlAnimation {
  @override
  bool get animate => widget.animate;

  @override
  void initState() {
    super.initState();
    startOwlAnimation();
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([loop, blinkCtl]),
        builder: (context, _) => Transform.translate(
          offset: Offset(0, still ? 0 : bob * widget.size * 0.025),
          child: CustomPaint(
            size: Size.square(widget.size),
            painter: _OwlPainter(
              blink: blinkCtl.value,
              look: still ? Offset.zero : lookFor(widget.mood),
              mood: widget.mood,
              notesPhase: loop.value,
            ),
          ),
        ),
      ),
    );
  }
}

class _OwlPainter extends CustomPainter {
  final double blink;
  final Offset look;
  final OwlMood mood;
  final double notesPhase;
  _OwlPainter({required this.blink, required this.look, required this.mood, required this.notesPhase});

  @override
  void paint(Canvas canvas, Size size) =>
      paintOwl(canvas, size.shortestSide, blink: blink, look: look, mood: mood, notesPhase: notesPhase);

  @override
  bool shouldRepaint(_OwlPainter old) =>
      old.blink != blink || old.look != look || old.mood != mood || old.notesPhase != notesPhase;
}

/// Round owl badge: the owl peeks into a dark disc with a pink-to-violet
/// neon ring. [glow] adds the soft pulsing halo (use it on the floating button).
class OwlBadge extends StatefulWidget {
  final double size;
  final OwlMood mood;
  final bool glow;
  final bool ring;
  final bool animate;
  const OwlBadge({
    super.key,
    this.size = 56,
    this.mood = OwlMood.idle,
    this.glow = false,
    this.ring = true,
    this.animate = true,
  });

  @override
  State<OwlBadge> createState() => _OwlBadgeState();
}

class _OwlBadgeState extends State<OwlBadge> with TickerProviderStateMixin, _OwlAnimation {
  @override
  bool get animate => widget.animate;

  @override
  void initState() {
    super.initState();
    startOwlAnimation();
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([loop, blinkCtl]),
        builder: (context, _) => CustomPaint(
          size: Size.square(widget.size),
          painter: _OwlBadgePainter(
            blink: blinkCtl.value,
            look: still ? Offset.zero : lookFor(widget.mood),
            mood: widget.mood,
            notesPhase: loop.value,
            glow: widget.glow ? (still ? 0.8 : 0.65 + 0.35 * (0.5 + 0.5 * bob)) : 0,
            ring: widget.ring,
            bob: still ? 0 : bob,
          ),
        ),
      ),
    );
  }
}

class _OwlBadgePainter extends CustomPainter {
  final double blink, notesPhase, glow, bob;
  final Offset look;
  final OwlMood mood;
  final bool ring;
  _OwlBadgePainter({
    required this.blink,
    required this.look,
    required this.mood,
    required this.notesPhase,
    required this.glow,
    required this.ring,
    required this.bob,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide / 2;
    final c = Offset(r, r);
    if (glow > 0) {
      canvas.drawCircle(
        c,
        r * 0.86,
        Paint()
          ..color = _pink.withOpacity(0.55 * glow)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.22),
      );
    }
    final inner = ring ? r * 0.8 : r;
    if (ring) {
      canvas.drawCircle(
        c,
        r * 0.9,
        Paint()..shader = ui.Gradient.linear(Offset.zero, Offset(r * 2, r * 2), const [_pink, _violet]),
      );
    }
    final disc = Rect.fromCircle(center: c, radius: inner);
    canvas.drawCircle(
      c,
      inner,
      Paint()
        ..shader = ui.Gradient.radial(Offset(r, r * 0.8), inner, const [Color(0xFF3B1C4C), Color(0xFF140818)]),
    );
    canvas.save();
    canvas.clipPath(Path()..addOval(disc));
    final k = inner * 2.56; // owl drawn large so the face fills the disc
    canvas.translate(r - k * 0.5, r - k * 0.40 + bob * inner * 0.03);
    paintOwl(canvas, k, blink: blink, look: look, mood: mood, notesPhase: notesPhase);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_OwlBadgePainter o) =>
      o.blink != blink || o.look != look || o.mood != mood || o.notesPhase != notesPhase ||
      o.glow != glow || o.ring != ring || o.bob != bob;
}

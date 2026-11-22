import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'radar_models.dart';

class RadarArtwork extends StatelessWidget {
  final Color color;
  final bool compact;

  const RadarArtwork({super.key, required this.color, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(painter: _RadarPainter(color, compact)),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final Color color;
  final bool compact;

  _RadarPainter(this.color, this.compact);

  @override
  void paint(Canvas canvas, Size size) {
    final center = compact
        ? size.center(Offset.zero)
        : Offset(size.width * .59, size.height * .48);
    final radius = math.min(size.width, size.height) * (compact ? .44 : .46);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color.withValues(alpha: compact ? .5 : .25);
    for (final scale in [0.33, 0.66, 1.0]) {
      canvas.drawCircle(center, radius * scale, line);
    }
    canvas.drawLine(
      center.translate(-radius, 0),
      center.translate(radius, 0),
      line,
    );
    canvas.drawLine(
      center.translate(0, -radius),
      center.translate(0, radius),
      line,
    );
    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweep = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        colors: [
          Colors.transparent,
          color.withValues(alpha: .38),
          Colors.transparent,
          Colors.transparent,
        ],
        stops: const [0, .19, .192, 1],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect);
    canvas.drawCircle(center, radius, sweep);
    final beam = center.translate(radius * .93, -radius * .37);
    canvas.drawLine(center, beam, line..color = color);
    for (final point in [
      center.translate(radius * .55, -radius * .24),
      center.translate(-radius * .48, radius * .37),
      if (!compact) center.translate(radius * .21, radius * .64),
    ]) {
      canvas.drawCircle(point, compact ? 2 : 3, Paint()..color = color);
      canvas.drawCircle(
        point,
        compact ? 4 : 7,
        line..color = color.withValues(alpha: .4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter old) =>
      old.color != color || old.compact != compact;
}

class RadarList extends StatelessWidget {
  final List<Widget> children;
  final Future<void> Function()? onRefresh;

  const RadarList({super.key, required this.children, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final list = ListView(
      physics: onRefresh == null ? null : const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        28 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        for (final child in children)
          Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: SizedBox(width: double.infinity, child: child),
            ),
          ),
      ],
    );
    return onRefresh == null
        ? list
        : RefreshIndicator(onRefresh: onRefresh!, child: list);
  }
}

class RadarHeading extends StatelessWidget {
  final String title;
  final String? subtitle;

  const RadarHeading(this.title, {super.key, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class RadarPanel extends StatelessWidget {
  final Widget child;
  final Color? tint;
  final EdgeInsetsGeometry padding;

  const RadarPanel({
    super.key,
    required this.child,
    this.tint,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: tint ?? colors.surfaceContainerLow,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(21),
      ),
      child: child,
    );
  }
}

class RadarTag extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool accent;

  const RadarTag(this.label, {super.key, this.icon, this.accent = false});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = accent
        ? colors.onPrimaryContainer
        : colors.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent ? colors.primaryContainer : colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            if (icon != null)
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(icon, color: foreground, size: 14),
                ),
              ),
            TextSpan(text: label),
          ],
        ),
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class RadarEmpty extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Widget? action;

  const RadarEmpty({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RadarPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 30),
          const SizedBox(height: 10),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            description,
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
          if (action != null) ...[const SizedBox(height: 12), action!],
        ],
      ),
    );
  }
}

class RadarIdeaRow extends StatelessWidget {
  final RadarIdea idea;
  final String category;
  final VoidCallback onTap;
  final Widget? trailing;

  const RadarIdeaRow({
    super.key,
    required this.idea,
    required this.category,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Material(
        color: colors.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(17),
          side: BorderSide(color: colors.outlineVariant),
        ),
        child: ListTile(
          leading: Icon(
            institutionIcon(idea.institution),
            color: colors.primary,
          ),
          title: Text(
            idea.title,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            '$category · ${idea.published ? idea.stage.label : 'Szkic'}',
          ),
          trailing: trailing ?? const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}

IconData institutionIcon(Institution institution) {
  return switch (institution) {
    Institution.school => Icons.school_outlined,
    Institution.university => Icons.science_outlined,
    Institution.council => Icons.account_balance_outlined,
    Institution.publicBody => Icons.hub_outlined,
  };
}

void showRadarMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

class RadarSupportSection extends StatelessWidget {
  final RadarIdea idea;
  final bool compact;

  const RadarSupportSection({
    super.key,
    required this.idea,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final icon = switch (idea.support) {
      Support.mentor => Icons.psychology_outlined,
      Support.technical => Icons.build_outlined,
      Support.pilot => Icons.science_outlined,
      Support.deployment => Icons.rocket_launch_outlined,
      Support.funding => Icons.payments_outlined,
    };
    final description = idea.supportDetails.isEmpty
        ? idea.support.description
        : idea.supportDetails;

    return RadarPanel(
      padding: EdgeInsets.all(compact ? 13 : 16),
      tint: colors.primaryContainer,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.onPrimaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Potrzebne wsparcie',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  idea.support.label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall,
                  maxLines: compact ? 2 : null,
                  overflow: compact ? TextOverflow.ellipsis : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../themes/app_theme.dart';

/// The MX Player mark: a green gradient squircle with a play glyph.
class MxLogo extends StatelessWidget {
  const MxLogo({super.key, this.size = 96, this.showShadow = true});

  final double size;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final double radius = size * 0.26;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: MxColors.brandGradient,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: showShadow
            ? <BoxShadow>[
                BoxShadow(
                  color: MxColors.brand.withOpacity(0.35),
                  blurRadius: size * 0.4,
                  spreadRadius: size * 0.04,
                ),
              ]
            : null,
      ),
      child: CustomPaint(
        painter: _MxMarkPainter(),
        child: Center(
          child: Icon(
            Icons.play_arrow_rounded,
            size: size * 0.52,
            color: const Color(0xFF06210F),
          ),
        ),
      ),
    );
  }
}

class _MxMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.055;
    canvas.drawLine(
      Offset(size.width * 0.16, size.height * 0.86),
      Offset(size.width * 0.5, size.height * 0.14),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Logo plus wordmark, used on the splash screen and in the app bar.
class MxWordmark extends StatelessWidget {
  const MxWordmark({
    super.key,
    this.logoSize = 34,
    this.title = 'MX PLAYER',
    this.subtitle = 'PRO',
    this.compact = false,
  });

  final double logoSize;
  final String title;
  final String? subtitle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        MxLogo(size: logoSize, showShadow: false),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              title,
              style: text.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                fontSize: compact ? 13 : 15,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: text.labelSmall?.copyWith(
                  color: MxColors.brand,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w700,
                  fontSize: compact ? 8.5 : 9.5,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Compact circular icon button with a subtle translucent background.
class MxIconButton extends StatelessWidget {
  const MxIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.filled = false,
    this.size = 40,
    this.iconSize = 21,
    this.color,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool filled;
  final double size;
  final double iconSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color foreground = onPressed == null
        ? Theme.of(context).disabledColor
        : (color ?? Theme.of(context).iconTheme.color ?? Colors.white);

    final Widget button = InkResponse(
      onTap: onPressed,
      radius: size / 1.4,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: filled ? MxColors.brand.withOpacity(0.14) : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.55),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: iconSize, color: filled ? MxColors.brand : foreground),
      ),
    );

    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// The small green label used for section headers ("Continue watching", ...).
class MxSectionHeader extends StatelessWidget {
  const MxSectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(16, 20, 16, 10),
  });

  final String title;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: <Widget>[
          Container(
            width: 3,
            height: 15,
            decoration: BoxDecoration(
              color: MxColors.brand,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class MxEmptyState extends StatelessWidget {
  const MxEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: compact ? 64 : 86,
              height: compact ? 64 : 86,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    MxColors.brand.withOpacity(0.22),
                    MxColors.brand.withOpacity(0.04),
                  ],
                ),
                border: Border.all(color: MxColors.brand.withOpacity(0.25)),
              ),
              child: Icon(icon, size: compact ? 28 : 36, color: MxColors.brand),
            ),
            SizedBox(height: compact ? 14 : 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: text.titleMedium?.copyWith(fontSize: compact ? 15 : 17),
            ),
            if (message != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: text.bodySmall?.copyWith(height: 1.45),
              ),
            ],
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: MxColors.brand,
                  foregroundColor: const Color(0xFF06210F),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(actionLabel!, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Thin green progress indicator used on video cards and the mini player.
class MxProgressLine extends StatelessWidget {
  const MxProgressLine({
    super.key,
    required this.value,
    this.height = 3,
    this.background = const Color(0x33FFFFFF),
  });

  final double value;
  final double height;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: height,
        backgroundColor: background,
        valueColor: const AlwaysStoppedAnimation<Color>(MxColors.brand),
      ),
    );
  }
}

/// Small rounded label drawn over thumbnails (duration, "LIVE", quality...).
class MxBadge extends StatelessWidget {
  const MxBadge({
    super.key,
    required this.label,
    this.background = const Color(0xCC000000),
    this.foreground = Colors.white,
    this.dense = false,
    this.leadingIcon,
  });

  final String label;
  final Color background;
  final Color foreground;
  final bool dense;
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: dense ? 5 : 7, vertical: dense ? 2 : 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (leadingIcon != null) ...<Widget>[
            Icon(leadingIcon, size: dense ? 9 : 10, color: foreground),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: dense ? 9.5 : 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Flat, MX-styled surface used instead of Material cards.
class MxSurface extends StatelessWidget {
  const MxSurface({
    super.key,
    required this.child,
    this.padding,
    this.radius = 16,
    this.color,
    this.onTap,
    this.border = true,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final Color? color;
  final VoidCallback? onTap;
  final bool border;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color background = color ?? (isDark ? MxColors.surface : MxColors.lightSurface);
    final BorderRadius borderRadius = BorderRadius.circular(radius);

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Material(
        color: background,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              border: border
                  ? Border.all(color: isDark ? MxColors.divider : MxColors.lightDivider, width: 0.8)
                  : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A settings row with icon, title, optional subtitle and trailing widget.
class MxSettingsTile extends StatelessWidget {
  const MxSettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color accent = iconColor ?? MxColors.brand;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 19, color: accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(title, style: theme.textTheme.titleMedium?.copyWith(fontSize: 14.5)),
                  if (subtitle != null) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: isDark ? MxColors.textTertiary : MxColors.lightTextSecondary,
                ),
          ],
        ),
      ),
    );
  }
}

/// Rounded group of settings rows with an optional caption.
class MxSettingsGroup extends StatelessWidget {
  const MxSettingsGroup({super.key, this.title, required this.children});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
            child: Text(
              title!.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: MxColors.brand,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        MxSurface(
          radius: 18,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: <Widget>[
              for (int i = 0; i < children.length; i++) ...<Widget>[
                children[i],
                if (i != children.length - 1)
                  Divider(
                    height: 1,
                    thickness: 0.7,
                    indent: 66,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? MxColors.divider
                        : MxColors.lightDivider,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Simple animated sheet title with a grab handle.
class MxSheetHeader extends StatelessWidget {
  const MxSheetHeader({super.key, required this.title, this.subtitle, this.trailing});

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 12, 12),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(title, style: text.titleMedium?.copyWith(fontSize: 16)),
                if (subtitle != null) ...<Widget>[
                  const SizedBox(height: 3),
                  Text(subtitle!, style: text.bodySmall),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

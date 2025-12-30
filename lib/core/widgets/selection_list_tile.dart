import 'package:flutter/material.dart';

/// Seçim yapılabilen list tile widget'ı
/// Şehir, ilçe, kategori vb. seçimler için kullanılabilir
class SelectionListTile extends StatelessWidget {
  /// Başlık metni
  final String title;

  /// Alt başlık metni
  final String subtitle;

  /// Sol taraftaki widget (genellikle CircleAvatar)
  final Widget? leading;

  /// Sağ taraftaki widget
  final Widget? trailing;

  /// Tıklandığında çağrılır
  final VoidCallback? onTap;

  /// Tile'ın aktif/pasif durumu
  final bool isEnabled;

  /// Arka plan rengi (null ise tema rengini kullanır)
  final Color? backgroundColor;

  /// Border rengi
  final Color? borderColor;

  /// Border radius
  final double borderRadius;

  const SelectionListTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.isEnabled = true,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 12,
  });

  /// İkon ile oluşturma
  factory SelectionListTile.withIcon({
    required String title,
    required String subtitle,
    required IconData icon,
    Color? iconColor,
    VoidCallback? onTap,
    bool isEnabled = true,
    Color? backgroundColor,
  }) {
    return SelectionListTile(
      title: title,
      subtitle: subtitle,
      leading: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final effectiveIconColor = isEnabled
              ? (iconColor ?? theme.colorScheme.primary)
              : theme.colorScheme.onSurface.withValues(alpha: 0.38);
          return CircleAvatar(
            backgroundColor: effectiveIconColor.withValues(alpha: 0.1),
            child: Icon(icon, color: effectiveIconColor),
          );
        },
      ),
      trailing: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return Icon(
            Icons.keyboard_arrow_down,
            color: isEnabled
                ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                : theme.colorScheme.onSurface.withValues(alpha: 0.38),
          );
        },
      ),
      onTap: onTap,
      isEnabled: isEnabled,
      backgroundColor: backgroundColor,
    );
  }

  /// Kilitli (seçilemez) görünüm
  factory SelectionListTile.locked({
    required String title,
    required String subtitle,
    Widget? leading,
    Color? backgroundColor,
  }) {
    return SelectionListTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return Icon(
            Icons.lock_outline,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
            size: 20,
          );
        },
      ),
      isEnabled: false,
      backgroundColor: backgroundColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Tema bazlı arka plan rengi hesaplama
    final Color effectiveBackgroundColor;
    if (backgroundColor != null) {
      effectiveBackgroundColor = backgroundColor!;
    } else if (!isEnabled) {
      // Devre dışı durum için tema uyumlu renk
      effectiveBackgroundColor = isDarkMode
          ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
          : Colors.grey[100]!;
    } else {
      effectiveBackgroundColor = theme.colorScheme.surface;
    }

    // Border rengi
    final Color effectiveBorderColor =
        borderColor ??
        (isEnabled
            ? theme.colorScheme.outline.withValues(alpha: 0.3)
            : theme.colorScheme.outline.withValues(alpha: 0.15));

    // Metin renkleri
    final Color titleColor = isEnabled
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurface.withValues(alpha: 0.5);

    final Color subtitleColor = isEnabled
        ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
        : theme.colorScheme.onSurface.withValues(alpha: 0.38);

    return Container(
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: effectiveBorderColor),
      ),
      child: ListTile(
        leading: leading,
        title: Text(
          title,
          style: TextStyle(color: titleColor, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(subtitle, style: TextStyle(color: subtitleColor)),
        trailing: trailing,
        onTap: isEnabled ? onTap : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

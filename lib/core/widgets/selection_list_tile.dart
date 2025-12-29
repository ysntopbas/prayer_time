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

  /// Arka plan rengi
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

  /// CircleAvatar ile icon içeren versiyon
  factory SelectionListTile.withIcon({
    Key? key,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    Color? iconBackgroundColor,
    Widget? trailing,
    VoidCallback? onTap,
    bool isEnabled = true,
    Color? backgroundColor,
    Color? borderColor,
    double borderRadius = 12,
  }) {
    return SelectionListTile(
      key: key,
      title: title,
      subtitle: subtitle,
      leading: CircleAvatar(
        backgroundColor:
            iconBackgroundColor ?? iconColor.withValues(alpha: 0.1),
        child: Icon(icon, color: iconColor),
      ),
      trailing: trailing,
      onTap: onTap,
      isEnabled: isEnabled,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      borderRadius: borderRadius,
    );
  }

  /// CircleAvatar ile metin içeren versiyon
  factory SelectionListTile.withText({
    Key? key,
    required String title,
    required String subtitle,
    required String text,
    required Color textColor,
    Color? textBackgroundColor,
    double fontSize = 12,
    Widget? trailing,
    VoidCallback? onTap,
    bool isEnabled = true,
    Color? backgroundColor,
    Color? borderColor,
    double borderRadius = 12,
  }) {
    return SelectionListTile(
      key: key,
      title: title,
      subtitle: subtitle,
      leading: CircleAvatar(
        backgroundColor:
            textBackgroundColor ?? textColor.withValues(alpha: 0.1),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      isEnabled: isEnabled,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      borderRadius: borderRadius,
    );
  }

  /// Kilitli (read-only) versiyon
  factory SelectionListTile.locked({
    Key? key,
    required String title,
    required String subtitle,
    Widget? leading,
    Color? backgroundColor,
    Color? borderColor,
    double borderRadius = 12,
  }) {
    return SelectionListTile(
      key: key,
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: Icon(Icons.lock_outline, size: 18, color: Colors.grey[500]),
      isEnabled: false,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      borderRadius: borderRadius,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context);

    final effectiveBackgroundColor =
        backgroundColor ??
        (isEnabled ? appTheme.colorScheme.surface : Colors.grey[100]);

    final effectiveBorderColor = borderColor ?? Colors.grey.shade300;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        decoration: BoxDecoration(
          color: effectiveBackgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: effectiveBorderColor),
        ),
        child: ListTile(
          leading: leading,
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: trailing ?? const Icon(Icons.keyboard_arrow_down),
        ),
      ),
    );
  }
}

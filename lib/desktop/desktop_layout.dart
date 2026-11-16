/// Keep artwork a useful size as the content pane (not the window) resizes.
/// The existing horizontal column preference controls the gallery density.
int desktopGridColumns(
  double width, {
  int preferredColumns = 4,
  double? preferredWidth,
}) {
  final target = preferredWidth ?? 960 / preferredColumns.clamp(1, 12);
  return (width / target.clamp(50, 2160)).floor().clamp(1, 12);
}

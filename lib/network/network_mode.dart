enum NetworkMode {
  compat('compat'),
  ech('ech'),
  standard('standard');

  const NetworkMode(this.code);

  final String code;

  /// Modes the user can pick. Compatibility mode is hidden and existing users
  /// are migrated to the enhanced (ech) mode.
  static const List<NetworkMode> selectableValues = [
    NetworkMode.ech,
    NetworkMode.standard,
  ];

  static NetworkMode fromCode(String? code) {
    // Compatibility mode has been merged into the enhanced (ech) mode.
    if (code == NetworkMode.compat.code) return NetworkMode.ech;
    for (final mode in NetworkMode.values) {
      if (mode.code == code) return mode;
    }
    return NetworkMode.standard;
  }

  bool get usesCompatibleConnection => this != NetworkMode.standard;
  bool get allowsImageSource => this != NetworkMode.standard;
}

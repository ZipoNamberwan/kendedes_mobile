class InteractionMode {
  final String key;
  final String label;

  InteractionMode({required this.key, required this.label});

  const InteractionMode._(this.key, this.label);

  static const tag = InteractionMode._('tag', 'Mode Tagging');
  static const browse = InteractionMode._('browse', 'Mode Jelajah');

  static const values = [tag, browse];

  static InteractionMode? fromKey(String key) {
    return values.where((item) => item.key == key).firstOrNull;
  }

  static List<InteractionMode> getInteractionModes() {
    return values;
  }
}

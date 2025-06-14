class LabelType {
  final String key;
  final String label;

  LabelType({required this.key, required this.label});

  const LabelType._(this.key, this.label);

  static const nameOwner = LabelType._('name_owner', 'Nama Usaha dan Pemilik');
  static const name = LabelType._('name', 'Nama Usaha');
  static const owner = LabelType._('owner', 'Pemilik');
  static const sector = LabelType._('sector', 'Sektor');

  static const values = [nameOwner, name, owner, sector];

  static LabelType? fromKey(String key) {
    return values.where((item) => item.key == key).firstOrNull;
  }

  static List<LabelType> getLabelTypes() {
    return values;
  }
}

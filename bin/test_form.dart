// no import
// Mocking the behavior
void main() {
  final data = <String, dynamic>{};
  final inputs = [
    {'id': 'input-name', 'value': 'test'},
    {'id': 'input-deadline', 'value': '2026'},
  ];
  
  final allowedKeys = {
    'input-name',
    'input-phone',
    'input-university',
    'input-service',
    'input-details'
  };
  List<String> extraInfo = [];

  for (final element in inputs) {
    String? key = element['id'];
    String? val = element['value'];

    if (key != null && key.isNotEmpty && key != 'form-type' && val != null && val.isNotEmpty) {
      if (allowedKeys.contains(key)) {
        data[key] = val;
      } else {
        extraInfo.add('$key: $val');
      }
    }
  }

  if (extraInfo.isNotEmpty) {
    final existingDetails = data['input-details'] ?? '';
    data['input-details'] = '$existingDetails\n\nمعلومات إضافية:\n${extraInfo.join('\n')}';
  }

  print(data);
}

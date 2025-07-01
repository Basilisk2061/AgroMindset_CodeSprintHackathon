class PredictionModel {
  final int? id;
  final String result;
  final String imagePath;
  final String timestamp;

  PredictionModel({
    this.id,
    required this.result,
    required this.imagePath,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'result': result,
      'imagePath': imagePath,
      'timestamp': timestamp,
    };
  }

  factory PredictionModel.fromMap(Map<String, dynamic> map) {
    return PredictionModel(
      id: map['id'],
      result: map['result'],
      imagePath: map['imagePath'],
      timestamp: map['timestamp'],
    );
  }
}
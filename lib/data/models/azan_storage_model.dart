import 'dart:convert';

class AzanStorageModel {
  String? fileName;
  String? path;

  AzanStorageModel({this.fileName, this.path});

  factory AzanStorageModel.fromJson(Map<String, dynamic> jsonData) {
    return AzanStorageModel(
      fileName: jsonData['fileName'],
      path: jsonData['path'],
    );
  }

  static Map<String, dynamic> toMap(AzanStorageModel azanStorageModel) => {
        'fileName': azanStorageModel.fileName,
        'path': azanStorageModel.path,
      };

  static String encode(List<AzanStorageModel> azans) => json.encode(
        azans
            .map<Map<String, dynamic>>((music) => AzanStorageModel.toMap(music))
            .toList(),
      );

  static List<AzanStorageModel> decode(String azans) =>
      (json.decode(azans) as List<dynamic>)
          .map<AzanStorageModel>((item) => AzanStorageModel.fromJson(item))
          .toList();
}

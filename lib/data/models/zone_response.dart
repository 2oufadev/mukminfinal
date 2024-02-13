class ZoneModel {
  List<String>? states;
  List<Results>? results;

  ZoneModel({this.states, this.results});

  ZoneModel.fromJson(Map<String, dynamic> json) {
    states = json['states'].cast<String>();
    if (json['results'] != null) {
      results = <Results>[];
      json['results'].forEach((v) {
        results!.add(Results.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['states'] = this.states;
    if (this.results != null) {
      data['results'] = this.results!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Results {
  String? zone;
  String? negeri;
  String? lokasi;
  String? lat;
  String? lng;

  Results({this.zone, this.negeri, this.lokasi, this.lat, this.lng});

  Results.fromJson(Map<String, dynamic> json) {
    zone = json['zone'];
    negeri = json['negeri'];
    lokasi = json['lokasi'];
    lat = json['lat'];
    lng = json['lng'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['zone'] = this.zone;
    data['negeri'] = this.negeri;
    data['lokasi'] = this.lokasi;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    return data;
  }
}

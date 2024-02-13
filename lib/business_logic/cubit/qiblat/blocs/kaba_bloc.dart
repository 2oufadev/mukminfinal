import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';

class KabaBloc extends Bloc<double, List<double>> {
  KabaBloc() : super([0, 0]);

  ///functions
  Future<bool> askPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      return await permission.request().isGranted;
    }
  }

  ///fields
  double _lat = 0;
  double _long = 39;
  double pi = 3.141592654;
  double kiblatAngleDegree = 0;
  Location _location = Location();

  @override
  Stream<List<double>> mapEventToState(double event) async* {
    if (event > 10) {
      yield [2, event];
    } else if (event < -10) {
      yield [0, event];
    } else {
      yield [1, event];
    }
  }
}

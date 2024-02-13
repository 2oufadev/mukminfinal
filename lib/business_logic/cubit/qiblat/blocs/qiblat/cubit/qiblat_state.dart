part of 'qiblat_cubit.dart';

abstract class QiblatState {}

class QiblatInitial extends QiblatState {
  final String timeNow;
  final String temperature;
  final List<String> azansTimesList;
  final int nextAzan;
  final String nextAzanDuration;
  final Duration nextAzanTime;
  final String weatherIcon;
  final List<String> weatherIcons;

  QiblatInitial(
      this.timeNow,
      this.temperature,
      this.azansTimesList,
      this.nextAzan,
      this.nextAzanDuration,
      this.nextAzanTime,
      this.weatherIcon,
      this.weatherIcons);
}

class DataChanged extends QiblatState {
  final String timeNow;
  final String temperature;
  final List<String> azansTimesList;
  final int nextAzan;
  final String nextAzanDuration;
  final Duration nextAzanTime;
  final String weatherIcon;
  final List<String> weatherIcons;

  DataChanged(
      this.timeNow,
      this.temperature,
      this.azansTimesList,
      this.nextAzan,
      this.nextAzanDuration,
      this.nextAzanTime,
      this.weatherIcon,
      this.weatherIcons);
}

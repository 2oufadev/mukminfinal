class MainState {
  String timeNow;
  String temperature;
  List<String> azansTimesList;
  int nextAzan;
  String nextAzanDuration;
  Duration nextAzanTime;
  String weatherIcon;
  List<String> weatherIcons;

  MainState(
      {this.timeNow = 'waiting..',
      this.temperature = 'waiting..',
      this.azansTimesList = const [
        'waiting..',
        'waiting..',
        'waiting..',
        'waiting..',
        'waiting..',
        'waiting..',
        'waiting..',
        'waiting..',
      ],
      this.nextAzan = 0,
      this.nextAzanDuration = 'waiting..',
      this.nextAzanTime = const Duration(seconds: 0),
      this.weatherIcon = '',
      required this.weatherIcons});
}

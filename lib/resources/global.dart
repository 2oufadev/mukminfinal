import 'package:flutter/material.dart';
import 'package:mukim_app/presentation/screens/zikir/changeColorScreen.dart';
import 'package:mukim_app/presentation/screens/zikir/homeScreen.dart';
import 'package:mukim_app/presentation/screens/zikir/homeScreen2.dart';
import 'package:mukim_app/presentation/screens/zikir/homeScreen3.dart';
import 'package:mukim_app/presentation/screens/zikir/homeScreen5.dart';

class Globals {
  Globals._();

  static List<LinearGradient> gradientList = [];
  static LinearGradient? selectedGradient1;
  static LinearGradient? selectedGradient2;
  static LinearGradient? selectedGradient3;
  static LinearGradient? selectedGradient4;
  static int count = 0;
  static int maximum = 100;
  static String selectedValue = "Design 1";
  static double? latitude;
  static double? longitude;
  static const images_url = 'https://salam.mukminapps.com/images/';
  static var globalInd = 0;
  static var autoScroll = false;
  static var repeat = false;
  static var verseKey = '';
  static var globalIndex;
  static var globalIndWord = 0;
  static var aazz = [];
  static var numberOfWords = 1;
  static var playingUrl = '';
  static var wordIndex = 0;
  static var wordVerseKey = '1:1';
  static bool wordPlaying = false;
  static Color color1 = Color(0xffA2CC80);
  static Map<String, String> zonesCode = {
    'Pulau Aur': 'JHR01',
    'Pemanggil': 'JHR01',
    'Kota Tinggi': 'JHR02',
    'Mersing': 'JHR02',
    'Johor Bahru': 'JHR02',
    'Kluang': 'JHR03',
    'Pontian': 'JHR03',
    'Batu Pahat': 'JHR04',
    'Muar': 'JHR04',
    'Segamat': 'JHR04',
    'Gemas': 'JHR04',
    'Kota Setar': 'KDH01',
    'Kubang Pasu': 'KDH01',
    'Pokok Sena': 'KDH01',
    'Pendang': 'KDH02',
    'Kuala Muda': 'KDH02',
    'Yan': 'KDH02',
    'Pedang Terap': 'KDH03',
    'Sik': 'KDH03',
    'Baling': 'KDH04',
    'Kulim': 'KDH05',
    'Bandar Bahru': 'KDH05',
    'Langkawi': 'KDH06',
    'Gunung Jerai': 'KDH07',
    'Kota Bahru': 'KTN01',
    'Bachok': 'KTN01',
    'Pasir Puteh': 'KTN01',
    'Tumpat': 'KTN01',
    'Pasir Mas': 'KTN01',
    'Tanah Merah': 'KTN01',
    'Machang': 'KTN01',
    'Kuala Krai': 'KTN01',
    'Mukim Chiku': 'KTN01',
    'Jeli': 'KTN02',
    'Gua Musang': 'KTN02',
    'Mukim Galas': 'KTN02',
    'Bertam': 'KTN02',
    'Bandar Melaka': 'MLK01',
    'Alor Gajah': 'MLK01',
    'Jasin': 'MLK01',
    'Masjid Tanah': 'MLK01',
    'Merlimau': 'MLK01',
    'Nyalas': 'MLK01',
    'Jempol': 'NGS01',
    'Tampin': 'NGS01',
    'Port Dickson': 'NGS02',
    'Seremban': 'NGS02',
    'Kuala Pilah': 'NGS02',
    'Jelebu': 'NGS02',
    'Rembau': 'NGS02',
    'Pulau Tioman': 'PHG01',
    'Kuantan': 'PHG02',
    'Pekan': 'PHG02',
    'Rompin': 'PHG02',
    'Muadzam Shah': 'PHG02',
    'Maran': 'PHG03',
    'Chenor': 'PHG03',
    'Temerloh': 'PHG03',
    'Bera': 'PHG03',
    'Jerantut': 'PHG03',
    'Bentong': 'PHG04',
    'Raub': 'PHG04',
    'Kuala Lipis': 'PHG04',
    'Genting Sempah': 'PHG05',
    'Janda Baik': 'PHG05',
    'Bukit Tinggi': 'PHG05',
    'Bukit Fraser': 'PHG06',
    'Genting Highlands': 'PHG06',
    'Cameron Highlands': 'PHG06',
    'Jengka': 'PHG03',
    'Tapah': 'PRK01',
    'Slim River': 'PRK01',
    'Tanjung Malim': 'PRK01',
    'Ipoh': 'PRK02',
    'Batu Gajah': 'PRK02',
    'Kampar': 'PRK02',
    'Sungai Siput': 'PRK02',
    'Kuala Kangsar': 'PRK02',
    'Pengkalan Hulu': 'PRK03',
    'Grik': 'PRK03',
    'Lenggong': 'PRK03',
    'Temengor': 'PRK04',
    'Belum': 'PRK04',
    'Teluk Intan': 'PRK05',
    'Bagan Datuk': 'PRK05',
    'Kampung Gajah': 'PRK05',
    'Seri Iskandar': 'PRK05',
    'Beruas': 'PRK05',
    'Parit': 'PRK05',
    'Lumut': 'PRK05',
    'Sitiawan': 'PRK05',
    'Pulau Pangkor': 'PRK05',
    'Selama': 'PRK06',
    'Taiping': 'PRK06',
    'Bagan Serai': 'PRK06',
    'Parit Buntar': 'PRK06',
    'Bukit Larut': 'PRK07',
    'Kangar': 'PLS01',
    'Padang Besar': 'PLS01',
    'Arau': 'PLS01',
    'Pulau Pinang': 'PNG01',
    'Sandakan Timur': 'SBH01',
    'Bukit Garam': 'SBH01',
    'Semawang': 'SBH01',
    'Temanggong': 'SBH01',
    'Tambisan': 'SBH01',
    'Pinangah': 'SBH02',
    'Terusan': 'SBH02',
    'Beluran': 'SBH02',
    'Kuamut': 'SBH02',
    'Telupid': 'SBH02',
    'Lahad Datu': 'SBH03',
    'Kunak': 'SBH03',
    'Silabukan': 'SBH03',
    'Tungku': 'SBH03',
    'Sahabat': 'SBH03',
    'Semporna': 'SBH03',
    'Bandar Tawau': 'SBH04',
    'Balong': 'SBH04',
    'Merotal': 'SBH04',
    'Kalabakan': 'SBH04',
    'Kudat': 'SBH05',
    'Pitas': 'SBH05',
    'Kota Marudu': 'SBH05',
    'Pulau Banggi': 'SBH05',
    'Gunung Kinabalu': 'SBH06',
    'Papar': 'SBH07',
    'Ranau': 'SBH07',
    'Kota Belud': 'SBH07',
    'Tuaran': 'SBH07',
    'Penampang': 'SBH07',
    'Kota Kinabalu': 'SBH07',
    'Pensiangan': 'SBH08',
    'Keningau': 'SBH08',
    'Tambunan': 'SBH08',
    'Nabawan': 'SBH08',
    'Sipitang': 'SBH09',
    'Membakut': 'SBH09',
    'beaufort': 'SBH09',
    'Kuala Penyu': 'SBH09',
    'Weston': 'SBH09',
    'Tenom': 'SBH09',
    'Long Pa Sia': 'SBH09',
    'Sukau': 'SBH01',
    'Sandakan Barat': 'SBH02',
    'Tawau Timur': 'SBH03',
    'Tawau Barat': 'SBH04',
    'Putatan': 'SBH07',
    'Pantai Barat': 'SBH07',
    'Limbang': 'SWK01',
    'Sundar': 'SWK01',
    'Trusan': 'SWK01',
    'Lawas': 'SWK01',
    'Niah': 'SWK02',
    'Sibuti': 'SWK02',
    'Miri': 'SWK02',
    'Bekenu': 'SWK02',
    'Marudi': 'SWK02',
    'Belaga': 'SWK03',
    'Bintulu': 'SWK03',
    'Tatau': 'SWK03',
    'Song': 'SWK04',
    'Balingian': 'SWK04',
    'Sebauh': 'SWK04',
    'Kapit': 'SWK04',
    'Igan': 'SWK04',
    'Kanowit': 'SWK04',
    'Sibu': 'SWK04',
    'Dalat': 'SWK04',
    'Oya': 'SWK04',
    'Belawai': 'SWK05',
    'Matu': 'SWK05',
    'Daro': 'SWK05',
    'Sarikei': 'SWK05',
    'Julau': 'SWK05',
    'Bitangor': 'SWK05',
    'Rajang': 'SWK05',
    'Kabong': 'SWK06',
    'Lingga': 'SWK06',
    'Sri Aman': 'SWK06',
    'Engkelili': 'SWK06',
    'Betong': 'SWK06',
    'Spaoh': 'SWK06',
    'Pusa': 'SWK06',
    'Saratok': 'SWK06',
    'Roban': 'SWK06',
    'Debak': 'SWK06',
    'Samarahan': 'SWK07',
    'Simunjan': 'SWK07',
    'Serian': 'SWK07',
    'Sebuyau': 'SWK07',
    'Meludam': 'SWK07',
    'Kuching': 'SWK08',
    'Bau': 'SWK08',
    'Lundu': 'SWK08',
    'Sematan': 'SWK08',
    'Zon Khas': 'SWK09',
    'Gombak': 'SGR01',
    'Hulu Selangor': 'SGR01',
    'Rawang': 'SGR01',
    'Hulu Langat': 'SGR01',
    'Sepang': 'SGR01',
    'Petaling': 'SGR01',
    'Shah Alam': 'SGR01',
    'Sabak Bernam': 'SGR01',
    'Kuala Selangor': 'SGR02',
    'Klang': 'SGR03',
    'Kuala Langat': 'SGR03',
    'Kuala Terengganu': 'TRG01',
    'Marang': 'TRG01',
    'Besut': 'TRG02',
    'Setiu': 'TRG02',
    'Hulu Terengganu': 'TRG03',
    'Kemaman': 'TRG04',
    'Dungun': 'TRG04',
    'Kuala Nerus': 'TRG01',
    'Putrajaya': 'WLY01',
    'Kuala Lumpur': 'WLY01',
    'Labuan': 'WLY01'
  };

  static List<String> statesList = [
    'Johor',
    'Kedah',
    'Kelantan',
    'Melaka',
    'Negeri Sembilan',
    'Pahang',
    'Perak',
    'Perlis',
    'Pulau Pinang',
    'Sabah',
    'Sarawak',
    'Selangor',
    'Terengganu',
    'Putrajaya',
    'Kuala Lumpur',
    'Labuan',
  ];

  static List<List<String>> zonesLists = [
    johor,
    kedah,
    kelantan,
    melaka,
    negeriSembilan,
    pahang,
    perak,
    perlis,
    pulauPinang,
    sabah,
    sarawak,
    selangor,
    terengganu,
    putrajaya,
    kualaLampur,
    labuan
  ];

  static List<String> putrajaya = ['Putrajaya'];
  static List<String> kualaLampur = ['Kuala Lumpur'];
  static List<String> labuan = ['Labuan'];

  static List<String> johor = [
    'Pulau Aur',
    'Pemanggil',
    'Kota Tinggi',
    'Mersing',
    'Johor Bahru',
    'Kluang',
    'Pontian',
    'Batu Pahat',
    'Muar',
    'Segamat',
    'Gemas'
  ];

  static List<String> kedah = [
    'Kota Setar',
    'Kubang Pasu',
    'Pokok Sena',
    'Pendang',
    'Kuala Muda',
    'Yan',
    'Pedang Terap',
    'Sik',
    'Baling',
    'Kulim',
    'Bandar Bahru',
    'Langkawi',
    'Gunung Jerai'
  ];

  static List<String> kelantan = [
    'Kota Bahru',
    'Bachok',
    'Pasir Puteh',
    'Tumpat',
    'Pasir Mas',
    'Tanah Merah',
    'Machang',
    'Kuala Krai',
    'Mukim Chiku',
    'Jeli',
    'Gua Musang',
    'Mukim Galas',
    'Bertam'
  ];

  static List<String> melaka = [
    'Bandar Melaka',
    'Alor Gajah',
    'Jasin',
    'Masjid Tanah',
    'Merlimau',
    'Nyalas'
  ];

  static List<String> negeriSembilan = [
    'Jempol',
    'Tampin',
    'Port Dickson',
    'Seremban',
    'Kuala Pilah',
    'Jelebu',
    'Rembau'
  ];

  static List<String> pahang = [
    'Pulau Tioman',
    'Kuantan',
    'Pekan',
    'Rompin',
    'Muadzam Shah',
    'Maran',
    'Chenor',
    'Temerloh',
    'Bera',
    'Jerantut',
    'Bentong',
    'Raub',
    'Kuala Lipis',
    'Genting Sempah',
    'Janda Baik',
    'Bukit Tinggi',
    'Bukit Fraser',
    'Genting Highlands',
    'Cameron Highlands',
    'Jengka'
  ];

  static List<String> perak = [
    'Tapah',
    'Slim River',
    'Tanjung Malim',
    'Ipoh',
    'Batu Gajah',
    'Kampar',
    'Sungai Siput',
    'Kuala Kangsar',
    'Pengkalan Hulu',
    'Grik',
    'Lenggong',
    'Temengor',
    'Belum',
    'Teluk Intan',
    'Bagan Datuk',
    'Kampung Gajah',
    'Seri Iskandar',
    'Beruas',
    'Parit',
    'Lumut',
    'Sitiawan',
    'Pulau Pangkor',
    'Selama',
    'Taiping',
    'Bagan Serai',
    'Parit Buntar',
    'Bukit Larut'
  ];

  static List<String> perlis = ['Kangar', 'Padang Besar', 'Arau'];
  static List<String> pulauPinang = ['Pulau Pinang'];
  static List<String> sabah = [
    'Sandakan Timur',
    'Bukit Garam',
    'Semawang',
    'Temanggong',
    'Tambisan',
    'Pinangah',
    'Trusan',
    'Beluran',
    'Kuamut',
    'Telupid',
    'Lahad Datu',
    'Kunak',
    'Silabukan',
    'Tungku',
    'Sahabat',
    'Semporna',
    'Bandar Tawau',
    'Balong',
    'Merotal',
    'Kalabakan',
    'Kudat',
    'Pitas',
    'Kota Marudu',
    'Pulau Banggi',
    'Gunung Kinabalu',
    'Papar',
    'Ranau',
    'Kota Belud',
    'Tuaran',
    'Penampang',
    'Kota Kinabalu',
    'Pensiangan',
    'Keningau',
    'Tambunan',
    'Nabawan',
    'Sipitang',
    'Membakut',
    'beaufort',
    'Kuala Penyu',
    'Weston',
    'Tenom',
    'Long Pa Sia',
    'Sukau',
    'Sandakan Barat',
    'Tawau Timur',
    'Tawau Barat',
    'Putatan',
    'Pantai Barat'
  ];

  static List<String> sarawak = [
    'Limbang',
    'Sundar',
    'Terusan',
    'Lawas',
    'Niah',
    'Belaga',
    'Sibuti',
    'Miri',
    'Bekenu',
    'Marudi',
    'Song',
    'Balingian',
    'Sebauh',
    'Bintulu',
    'Tatau',
    'Kapit',
    'Igan',
    'Kanowit',
    'Sibu',
    'Dalat',
    'Oya',
    'Belawai',
    'Matu',
    'Daro',
    'Sarikei',
    'Julau',
    'Bitangor',
    'Rajang',
    'Kabong',
    'Lingga',
    'Sri Aman',
    'Engkelili',
    'Betong',
    'Spaoh',
    'Pusa',
    'Saratok',
    'Roban',
    'Debak',
    'Samarahan',
    'Simunjan',
    'Serian',
    'Sebuyau',
    'Meludam',
    'Kuching',
    'Bau',
    'Lundu',
    'Sematan',
    'Zon Khas'
  ];

  static List<String> selangor = [
    'Gombak',
    'Hulu Selangor',
    'Rawang',
    'Hulu Langat',
    'Sepang',
    'Petaling',
    'Shah Alam',
    'Sabak Bernam',
    'Kuala Selangor',
    'Klang',
    'Kuala Langat'
  ];

  static List<String> terengganu = [
    'Kuala Terengganu',
    'Marang',
    'Besut',
    'Setiu',
    'Hulu Terengganu',
    'Kemaman',
    'Dungun',
    'Kuala Nerus'
  ];

  static List surahUrdu = [
    '!',
    '"',
    '#',
    '\$',
    '%',
    '&',
    '\'',
    '(',
    ')',
    '*',
    '+',
    ',',
    '-',
    '.',
    '/',
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    ':',
    ';',
    '<',
    '=',
    '>',
    '?',
    '@',
    'a',
    'A',
    'b',
    'B',
    'c',
    'C',
    'd',
    'D',
    'E',
    'e',
    'F',
    'f',
    'g',
    'G',
    'H',
    'h',
    'I',
    'i',
    'J',
    'j',
    'K',
    'k',
    'l',
    'L',
    'M',
    'm',
    'n',
    'N',
    'O',
    'o',
    'p',
    'P',
    'Q',
    'q',
    'R',
    'r',
    's',
    'S',
    't',
    'T',
    'u',
    'U',
    'v',
    'V',
    'W',
    'w',
    'x',
    'X',
    'y',
    'Y',
    'Z',
    'z',
    '[',
    '\'',
    ']',
    '^',
    '_',
    '`',
    '{',
    '|',
    '}',
    '~',
    '¡',
    '¢',
    '£',
    '¤',
    '¥',
    '¦',
    '§',
    '¨',
    '©',
    'ª',
    '«',
    '¬',
    '®',
    '¯',
    '°',
    '±',
    '²',
    '³',
    '´',
    'µ'
  ];

  static void initGridient() {
    gradientList.add(LinearGradient(colors: [
      Color(0xffEC008C),
      Color(0xffFC6767),
    ]));
    gradientList.add(LinearGradient(colors: [
      Color(0xff16A085),
      Color(0xffF4D03F),
    ]));
    gradientList.add(LinearGradient(colors: [
      Color(0xff1EAAD7),
      Color(0xff3FE9F4),
    ]));
    selectedGradient1 = gradientList[0];
    selectedGradient2 = gradientList[0];
    selectedGradient3 = gradientList[0];
    selectedGradient4 = gradientList[0];
  }

  static void changeGradient(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (builder) => ChangeColorScreen(
                  selectedValue: selectedValue,
                ))).then((value) {
      changeRoute(context);
    });
  }

  static void changeRoute(BuildContext context) {
    if (selectedValue == "Design 4") {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => Zikir(),
          transitionDuration: Duration.zero,
        ),
      );
    } else if (selectedValue == "Design 2") {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => HomeScreen2(),
          transitionDuration: Duration.zero,
        ),
      );
    } else if (selectedValue == "Design 3") {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => HomeScreen3(),
          transitionDuration: Duration.zero,
        ),
      );
    } else if (selectedValue == "Design 1") {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => HomeScreen5(),
          transitionDuration: Duration.zero,
        ),
      );
    }
  }
}

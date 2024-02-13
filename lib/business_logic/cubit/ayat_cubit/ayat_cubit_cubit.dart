import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mukim_app/data/models/hadith_model.dart';
import 'package:mukim_app/data/models/home_screen_model.dart';
import 'package:mukim_app/data/repository/ayat_repository.dart';

part 'ayat_cubit_state.dart';

class AyatCubitCubit extends Cubit<AyatCubitState> {
  final AyatRepository ayatRepository;
  List<HomeScreenModel>? homeAyatList;
  List<ReadyHadithModel>? ayatList;

  AyatCubitCubit(this.ayatRepository) : super(AyatCubitInitial());

  List<HomeScreenModel> fetchAyat() {
    emit(AyatImagesLoading());
    ayatRepository.fetchAyatHomeScreen().then((ayatList) {
      this.homeAyatList = ayatList;
      emit(AyatImagesLoaded(ayatList));
    });
    return this.homeAyatList != null ? this.homeAyatList! : [];
  }

  List<ReadyHadithModel> fetchAyatList(List<int> likedList) {
    ayatRepository.fetchArangedAyat(likedList).then((ayatList) {
      emit(AyatListLoaded(ayatList));
      this.ayatList = ayatList;
    });

    return this.ayatList != null ? this.ayatList! : [];
  }
}

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mukim_app/data/models/hadith_model.dart';
import 'package:mukim_app/data/models/home_screen_model.dart';
import 'package:mukim_app/data/repository/motivation_repository.dart';

part 'motivation_cubit_state.dart';

class MotivationCubitCubit extends Cubit<MotivationCubitState> {
  final MotivationRepository motivationRepository;
  List<HomeScreenModel> homeMotivasiList = [];
  List<Data> motivasiList = [];

  MotivationCubitCubit(this.motivationRepository)
      : super(MotivationCubitInitial());

  List<HomeScreenModel> fetchMotivasi() {
    emit(MotivasiImagesLoading());
    motivationRepository.fetchMotivasiHomeScreen().then((motivasiList) {
      this.homeMotivasiList = motivasiList;
      emit(MotivasiImagesLoaded(motivasiList));
    });
    return this.homeMotivasiList;
  }

  List<Data> fetchMotivasiList(List<int> likedList) {
    emit(MotivasiListLoading());
    motivationRepository.fetchArangedMotivasi(likedList).then((motivasiList) {
      emit(MotivasiListLoaded(motivasiList));
      this.motivasiList = motivasiList;
    });

    return this.motivasiList;
  }
}

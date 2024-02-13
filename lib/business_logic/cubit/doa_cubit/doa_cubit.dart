import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mukim_app/data/models/doa_category_model.dart';
import 'package:mukim_app/data/models/hadith_model.dart';
import 'package:mukim_app/data/models/home_screen_model.dart';
import 'package:mukim_app/data/repository/doa_repository.dart';
part 'doa_state.dart';

class DoaCubit extends Cubit<DoaState> {
  final DoaRepository doaRepository;
  List<ReadyHadithModel>? doaList;
  List<HomeScreenModel>? homeDoaList;
  List<DoaCategoryModel>? doaCategoriesList;

  DoaCubit(this.doaRepository) : super(HomeScreenInitial());

  List<HomeScreenModel> fetchDoa() {
    emit(DoaImagesLoading());
    doaRepository.fetchDoaHomeScreen().then((doaList) {
      this.homeDoaList = doaList;
      emit(DoaImagesLoaded(doaList));
    });
    return this.homeDoaList != null ? this.homeDoaList! : [];
  }

  List<DoaCategoryModel> fetchDoaCategories() {
    emit(DoaCategoriesLoading());
    doaRepository.fetchArangedDoaCategories().then((doaCategories) {
      emit(DoaCategoriesLoaded(doaCategories));
      doaCategoriesList = doaCategories;
    });

    return doaCategoriesList != null ? doaCategoriesList! : [];
  }

  List<ReadyHadithModel> fetchDoaList(String category, List<int> likedList) {
    emit(DoaListLoading());
    doaRepository.fetchArangedDoa(category, likedList).then((doaList) {
      emit(DoaListLoaded(doaList));
      this.doaList = doaList;
    });

    return this.doaList != null ? this.doaList! : [];
  }
}

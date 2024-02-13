import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mukim_app/data/models/azan_model.dart';
import 'package:mukim_app/data/models/doa_category_model.dart';
import 'package:mukim_app/data/models/hadith_model.dart';
import 'package:mukim_app/data/repository/mukmin_repository.dart';
part 'hadith_state.dart';

class HadithCubit extends Cubit<HadithState> {
  final MukminRepository mukminRepository;
  List<DoaCategoryModel>? infaqCategoriesList;
  List<ReadyHadithModel>? ayatList;
  List<Data>? motivasiList;
  List<AzanModel>? azansList;

  HadithCubit(this.mukminRepository) : super(HadithInitial());

  List<DoaCategoryModel> fetchInfaqCategories() {
    mukminRepository.fetchArangedInfaqCategories().then((infaqCategories) {
      emit(InfaqCategoriesLoaded(infaqCategories));

      infaqCategoriesList = infaqCategories;
    });

    return infaqCategoriesList != null ? infaqCategoriesList! : [];
  }

  List<AzanModel> fetchAzans() {
    mukminRepository.fetchAzans().then((azansList) {
      emit(AzansListLoaded(azansList));
      this.azansList = azansList;
    });
    return this.azansList != null ? this.azansList! : [];
  }
}

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mukim_app/data/models/infaq_details_module.dart';
import 'package:mukim_app/data/repository/mukmin_repository.dart';

part 'screens_details_state.dart';

class ScreensDetailsCubit extends Cubit<ScreensDetailsState> {
  final MukminRepository mukminRepository;
  List<InfaqDetailsModel> infaqList = [];

  ScreensDetailsCubit(this.mukminRepository) : super(ScreensDetailsInitial());

  List<InfaqDetailsModel> fetchInfaqDetails(String category, bool filter) {
    mukminRepository.fetchArrangedInfaq(category, filter).then((infaqList) {
      emit(InfaqListLoaded(infaqList));
      this.infaqList = infaqList;
    });
    return this.infaqList;
  }
}

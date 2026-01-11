import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  void increment() {
    emit(state.copyWith(counter: state.counter + 1));
  }

  void reset() {
    emit(const HomeState());
  }
}

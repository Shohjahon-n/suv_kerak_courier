import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talker/talker.dart';

class AppBlocObserver extends BlocObserver {
  AppBlocObserver(this._talker);

  final Talker _talker;

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    _talker.info('[${bloc.runtimeType}] created');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    _talker.info('[${bloc.runtimeType}] event: $event');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    _talker.info('[${bloc.runtimeType}] transition: $transition');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    _talker.handle(error, stackTrace);
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    _talker.info('[${bloc.runtimeType}] closed');
    super.onClose(bloc);
  }
}

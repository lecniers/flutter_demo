part of 'todos_cubit.dart';

@freezed
class TodosState with _$TodosState {
  const factory TodosState({
    @Default([]) List<String> todos,
  }) = _TodosState;
}

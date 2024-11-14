import 'package:api_repo/api_repo.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'todos_state.dart';
part 'todos_cubit.freezed.dart';

class TodosCubit extends Cubit<TodosState> {
  TodosCubit(
    this._apiRepo,
  ) : super(const _TodosState());

  final ApiRepo _apiRepo;

  void fetchTodos() {
    final todos = _apiRepo.fetchTodos();
    emit(state.copyWith(todos: todos));
  }
}

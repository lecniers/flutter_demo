/// {@template api_repo}
/// A fake API repo
/// {@endtemplate}
class ApiRepo {
  /// {@macro api_repo}
  const ApiRepo();

  List<String> fetchTodos() => ['todo1', 'todo2', 'todo3'];
}

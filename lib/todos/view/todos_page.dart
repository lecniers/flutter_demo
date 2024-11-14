import 'package:api_repo/api_repo.dart';
import 'package:demo_app/todos/todos.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TodosPage extends StatelessWidget {
  const TodosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TodosCubit(const ApiRepo()),
      child: const TodosView(),
    );
  }
}

class TodosView extends StatelessWidget {
  const TodosView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodosCubit, TodosState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Todos'),
          ),
          body: Column(
            children: [
              if (state.todos.isEmpty)
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<TodosCubit>().fetchTodos();
                    },
                    child: const Text('Fetch Todos'),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: state.todos.length,
                    itemBuilder: (context, index) {
                      final todo = state.todos[index];
                      return Text(
                        todo,
                        style: Theme.of(context).textTheme.headlineSmall,
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/coffees/business_logic/coffee_bloc.dart';
import 'data/data_sources/coffee_local_data_source.dart';
import 'data/data_sources/coffee_remote_data_source.dart';
import 'data/repositories/coffee_repository.dart';
import 'presentation/home_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Dependency injection setup
    final remoteDataSource = CoffeeRemoteDataSource();
    final localDataSource = CoffeeLocalDataSource();
    final repository = CoffeeRepository(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
    );

    return BlocProvider(
      create: (context) => CoffeeBloc(repository: repository),
      child: MaterialApp(
        title: 'Very Good Coffee',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 109, 67, 52),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

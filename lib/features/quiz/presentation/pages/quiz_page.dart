
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/quiz_bloc.dart';
import 'quiz_setup_page.dart';
import 'quiz_question_page.dart';
import 'quiz_results_page.dart';

class QuizPage extends StatelessWidget {
  final String topic;
  const QuizPage({super.key, this.topic = 'Data Structures'});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuizBloc(),
      child: BlocBuilder<QuizBloc, QuizState>(
        builder: (context, state) {
          if (state is QuizInProgress) return const QuizQuestionPage();
          if (state is QuizFinished) return const QuizResultsPage();
          return QuizSetupPage(topic: topic);
        },
      ),
    );
  }
}

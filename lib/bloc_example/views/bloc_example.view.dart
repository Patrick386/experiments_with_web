import 'package:experiments_with_web/app_level/components/stream/custom_stream_builder.component.dart';
import 'package:experiments_with_web/app_level/widgets/desktop/column_spacer.dart';
import 'package:experiments_with_web/app_level/widgets/desktop/custom_scaffold.dart';
import 'package:experiments_with_web/app_level/widgets/desktop/spacer_view.dart';
import 'package:experiments_with_web/bloc_example/bloc/search.bloc.dart';
import 'package:experiments_with_web/bloc_example/bloc/states.bloc.dart';
import 'package:experiments_with_web/bloc_example/utilities/strings.dart';
import 'package:experiments_with_web/bloc_example/utilities/widgets.dart';
import 'package:experiments_with_web/locator.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart' show Provider;

class BlocExampleScreen extends StatefulWidget {
  const BlocExampleScreen({Key key}) : super(key: key);

  @override
  _BlocExampleScreenState createState() => _BlocExampleScreenState();
}

class _BlocExampleScreenState extends State<BlocExampleScreen> {
  SearchBloc searchBloc;

  @override
  void initState() {
    super.initState();
    searchBloc = locator<SearchBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      titleText: BlocExampleStrings.title,
      enableDarkMode: true,
      child: SpacerView(
        child: CustomStreamBuilder<SearchState>(
          builder: (context, model) {
            final state = model.state;

            if (state == States.loading) {
              return Center(
                child: ColumnSpacer(
                  children: const [LoadingWidget(), _Internal()],
                ),
              );
            } else if (state == States.empty || state == States.noTerm) {
              return Center(
                child: ColumnSpacer(
                  children: const [_Internal(), EmptyWidget()],
                ),
              );
            } else if (state == States.error) {
              return Center(
                child: ColumnSpacer(
                  children: const [_Internal(), SearchErrorWidget()],
                ),
              );
            } else if (state == States.populated) {
              // If accesed the state here, throws an error
              return const _DisplayWidget();
            }

            return const _Internal();
          },
          initialData: SearchNoTerm(),
          stream: searchBloc.state,
        ),
      ),
      // child: StreamProvider<SearchState>.value(
      //   initialData: SearchNoTerm(),
      //   value: searchBloc.state,
      //   // updateShouldNotify: (_, __) => true,
      //   child: _Internal(),
      // ),
      // child: StreamBuilder<SearchState>(
      //   stream: searchBloc.state,
      //   initialData: SearchNoTerm(),
      //   builder: (_, snapshot) {
      //     final state = snapshot.data;

      //     print('>>> S $state');

      //     return _Internal();
      //   },
      // ),
    );
  }
}

class _DisplayWidget extends StatelessWidget {
  const _DisplayWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<SearchState>(context);
    final results = (state as SearchPopulated).result;

    return SingleChildScrollView(
      child: ColumnSpacer(
        children: [_Internal(), SearchResultWidget(items: results.items)],
      ),
    );
  }
}

class _Internal extends StatelessWidget {
  const _Internal({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = locator<SearchBloc>();

    return Center(
      child: TextField(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Search Github...',
        ),
        style: const TextStyle(
          fontSize: 36.0,
          decoration: TextDecoration.none,
        ),
        onChanged: bloc.onTextChanged.add,
      ),
    );
  }
}

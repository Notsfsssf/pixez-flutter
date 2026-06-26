import 'package:benchmark/benchmark.dart';
import 'package:flutter/material.dart';

class BenchmarkCard extends StatelessWidget {
  final BenchmarkMetadata benchmark;
  final Map<BenchmarkMetadata, BenchmarkState> state;
  final void Function() rebuild;

  const BenchmarkCard({
    super.key,
    required this.benchmark,
    required this.state,
    required this.rebuild,
  });

  @override
  Widget build(BuildContext context) {
    final state = this.state[benchmark] ??
        const BenchmarkState(
          running: false,
          time: null,
        );

    return SizedBox(
      width: 300,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          title: Text(benchmark.library),
          subtitle: Row(
            children: benchmark.tags
                .map(
                  (tag) => Container(
                    margin: const EdgeInsets.only(right: 5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(tag),
                  ),
                )
                .toList(),
          ),
          trailing: state.running
              ? const CircularProgressIndicator()
              : Text('${state.time ?? '-'} ms'),
          onTap: state.running
              ? null
              : () async {
                  this.state[benchmark] = BenchmarkState(
                    running: true,
                    time: state.time,
                  );
                  rebuild();
                  final result = await benchmark.run();
                  this.state[benchmark] = BenchmarkState(
                    running: false,
                    time: result,
                  );
                  rebuild();
                },
        ),
      ),
    );
  }
}

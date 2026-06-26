import 'dart:typed_data';

enum DownloadType {
  small(
    iterations: 10000,
    url: 'https://localhost:3000/small',
  ),
  large(
    iterations: 100,
    url: 'https://localhost:3000/large',
  ),
  ;

  const DownloadType({
    required this.iterations,
    required this.url,
  });

  final int iterations;
  final String url;
}

class BenchmarkMetadata {
  final String library;
  final List<String> tags;
  final DownloadType? downloadType;
  final bool upload;
  final BenchmarkExecutor executor;

  BenchmarkMetadata.download({
    required this.library,
    required this.tags,
    required this.downloadType,
    required this.executor,
  }) : upload = false;

  BenchmarkMetadata.upload({
    required this.library,
    required this.tags,
    required this.executor,
  })  : downloadType = null,
        upload = true;

  Future<int> run() async {
    return await executor.run(this);
  }

  @override
  int get hashCode =>
      library.hashCode ^
      tags.hashCode ^
      downloadType.hashCode ^
      upload.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BenchmarkMetadata &&
          runtimeType == other.runtimeType &&
          library == other.library &&
          tags == other.tags &&
          downloadType == other.downloadType &&
          upload == other.upload;

  @override
  String toString() {
    return 'BenchmarkMetadata($library, $tags, ${downloadType?.name}, $upload)';
  }
}

class BenchmarkState {
  final bool running;
  final int? time;

  const BenchmarkState({
    required this.running,
    required this.time,
  });
}

sealed class BenchmarkExecutor<T, U, R> {
  final Future<T> Function() createClient;
  final U Function(String) urlEncoder;
  final Future<R> Function(T client, U url) runIteration;

  BenchmarkExecutor({
    required this.createClient,
    required this.urlEncoder,
    required this.runIteration,
  });

  static BenchmarkExecutor downloadBytes<T, U>({
    required Future<T> Function() createClient,
    required U Function(String) urlEncoder,
    required Future<Uint8List> Function(T client, U url) runIteration,
  }) => _BenchmarkExecutorDownloadBytes<T, U>._(
        createClient: createClient,
        urlEncoder: urlEncoder,
        runIteration: runIteration,
      );

  static BenchmarkExecutor downloadStream<T, U>({
    required Future<T> Function() createClient,
    required U Function(String) urlEncoder,
    required Future<Stream<List<int>>> Function(T client, U url) runIteration,
  }) => _BenchmarkExecutorDownloadStream<T, U>._(
        createClient: createClient,
        urlEncoder: urlEncoder,
        runIteration: runIteration,
      );

  static BenchmarkExecutor upload<T, U>({
    required Future<T> Function() createClient,
    required U Function(String) urlEncoder,
    required Future<String> Function(T client, U url) runIteration,
  }) => _BenchmarkExecutorUpload<T, U>._(
        createClient: createClient,
        urlEncoder: urlEncoder,
        runIteration: runIteration,
      );

  Future<int> run(BenchmarkMetadata metadata) async {
    print(
      'Starting Benchmark for ${metadata.library} (${metadata.tags.join(', ')}) ...',
    );

    final client = await createClient();
    final url = urlEncoder(
      metadata.upload
          ? 'https://localhost:3000/upload'
          : metadata.downloadType!.url,
    );
    final count = metadata.upload ? 100 : metadata.downloadType!.iterations;
    final padLeft = count.toString().length;

    final stopwatch = Stopwatch()..start();
    for (var i = 0; i < count; i++) {
      await runIterationWrapper(
        client: client,
        url: url,
        i: i,
        padLeft: padLeft,
      );
    }

    final time = stopwatch.elapsedMilliseconds;
    print('Elapsed time: $time ms');
    return stopwatch.elapsedMilliseconds;
  }

  Future<void> runIterationWrapper({
    required T client,
    required U url,
    required int i,
    required int padLeft,
  });
}

class _BenchmarkExecutorDownloadBytes<T, U>
    extends BenchmarkExecutor<T, U, Uint8List> {
  _BenchmarkExecutorDownloadBytes._({
    required super.createClient,
    required super.urlEncoder,
    required super.runIteration,
  });

  Future<void> runIterationWrapper({
    required T client,
    required U url,
    required int i,
    required int padLeft,
  }) async {
    final response = await runIteration(client, url);
    print('[${'${i + 1}'.padLeft(padLeft)}] ${response.length}');
  }
}

class _BenchmarkExecutorDownloadStream<T, U>
    extends BenchmarkExecutor<T, U, Stream<List<int>>> {
  _BenchmarkExecutorDownloadStream._({
    required super.createClient,
    required super.urlEncoder,
    required super.runIteration,
  });

  Future<void> runIterationWrapper({
    required T client,
    required U url,
    required int i,
    required int padLeft,
  }) async {
    final response = await runIteration(client, url);
    int bytes = 0;
    await for (final event in response) {
      bytes += event.length;
    }
    print('[${'${i + 1}'.padLeft(padLeft)}] $bytes');
  }
}

class _BenchmarkExecutorUpload<T, U>
    extends BenchmarkExecutor<T, U, String> {
  _BenchmarkExecutorUpload._({
    required super.createClient,
    required super.urlEncoder,
    required super.runIteration,
  });

  Future<void> runIterationWrapper({
    required T client,
    required U url,
    required int i,
    required int padLeft,
  }) async {
    final status = await runIteration(client, url);
    print('[${'${i + 1}'.padLeft(padLeft)}] $status');
  }
}

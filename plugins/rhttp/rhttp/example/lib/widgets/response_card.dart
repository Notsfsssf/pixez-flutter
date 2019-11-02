import 'package:flutter/material.dart';
import 'package:rhttp/rhttp.dart';

class ResponseCard extends StatelessWidget {
  final HttpResponse response;

  const ResponseCard({
    super.key,
    required this.response,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${response.version.name} / ${response.statusCode}'),
            const SizedBox(height: 8),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    SelectableText('Remote IP: ${response.remoteIp}'),
                    SelectableText(response.bodyLabel),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on HttpResponse {
  String get bodyLabel {
    return switch (this) {
      HttpTextResponse r =>
        r.body.length > 100 ? r.body.substring(0, 100) : r.body,
      HttpBytesResponse r => r.body.length > 100
          ? r.body.sublist(0, 100).toString()
          : r.body.toString(),
      HttpStreamResponse _ => '<Stream>',
    };
  }
}

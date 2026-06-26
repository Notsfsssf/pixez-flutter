import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:rhttp/rhttp.dart';

import '../mocks.dart';

void main() {
  final mockRhttpClient = MockRhttpClient.createAndRegister();

  test('Should join multiple header values with the same key', () async {
    mockRhttpClient.mockStreamResponse(
      headers: [
        ('set-cookie', 'cookie1=value1; Path=/'),
        ('set-cookie', 'cookie2=value2; Path=/'),
      ],
    );

    final client = RhttpCompatibleClient.of(mockRhttpClient);

    final Response response = await client.post(
      Uri.parse('https://example.com'),
    );

    expect(response.headers, {
      'set-cookie': 'cookie1=value1; Path=/, cookie2=value2; Path=/',
    });
    expect(response.headersSplitValues, {
      'set-cookie': [
        'cookie1=value1; Path=/',
        'cookie2=value2; Path=/',
      ],
    });

    // Also test client.send()
    final StreamedResponse streamedResponse = await client.send(
      Request('POST', Uri.parse('https://example.com')),
    );

    expect(streamedResponse.headers, {
      'set-cookie': 'cookie1=value1; Path=/, cookie2=value2; Path=/',
    });
    expect(streamedResponse.headersSplitValues, {
      'set-cookie': [
        'cookie1=value1; Path=/',
        'cookie2=value2; Path=/',
      ],
    });
  });
}

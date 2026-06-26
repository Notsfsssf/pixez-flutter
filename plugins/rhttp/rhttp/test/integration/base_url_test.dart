import 'package:flutter_test/flutter_test.dart';
import 'package:rhttp/rhttp.dart';
import 'package:rhttp/src/rust/frb_generated.dart';

import '../mocks.dart';

void main() {
  late MockRustLibApi mockApi;

  setUpAll(() async {
    mockApi = MockRustLibApi.createAndRegister();

    RustLib.initMock(api: mockApi);
  });

  test('Should add base url on client request', () async {
    mockApi.mockCreateClient();

    String? observedUrl;
    mockApi.mockDefaultResponse(
      onAnswer: (requestUri) {
        observedUrl = requestUri;
      },
    );

    final client = await RhttpClient.create(
      settings: const ClientSettings(
        baseUrl: 'https://mydomain.com/abc',
      ),
    );

    await client.get('/def');

    expect(observedUrl, 'https://mydomain.com/abc/def');
  });

  test('Should add base url on ad-hoc request', () async {
    mockApi.mockCreateClient();

    String? observedUrl;
    mockApi.mockDefaultResponse(
      onAnswer: (requestUri) {
        observedUrl = requestUri;
      },
    );

    await Rhttp.get(
      '/456',
      settings: const ClientSettings(
        baseUrl: 'https://mydomain.com/123',
      ),
    );

    expect(observedUrl, 'https://mydomain.com/123/456');
  });
}

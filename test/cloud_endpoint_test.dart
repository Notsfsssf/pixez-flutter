/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:pixez/translation/cloud_endpoint.dart';

void main() {
  group('normalizeCloudBaseUrl', () {
    test('缺 scheme 的局域网地址补 http', () {
      expect(
        normalizeCloudBaseUrl('192.168.1.5:8080/v1'),
        'http://192.168.1.5:8080/v1',
      );
    });

    test('无点主机名（NAS 别名）补 http', () {
      expect(normalizeCloudBaseUrl('nas:8080/v1'), 'http://nas:8080/v1');
    });

    test('公网域名默认 https', () {
      expect(
        normalizeCloudBaseUrl('api.example.com/v1'),
        'https://api.example.com/v1',
      );
    });

    test('去掉尾部斜杠', () {
      expect(
        normalizeCloudBaseUrl('http://192.168.1.5:8080/v1/'),
        'http://192.168.1.5:8080/v1',
      );
    });

    test('误粘的 /chat/completions 被剥掉', () {
      expect(
        normalizeCloudBaseUrl('http://192.168.1.5:8080/v1/chat/completions'),
        'http://192.168.1.5:8080/v1',
      );
    });

    test('保留端口与 IPv6 字面量', () {
      expect(
        normalizeCloudBaseUrl('http://[::1]:8080/v1'),
        'http://[::1]:8080/v1',
      );
    });

    test('非 http/https 与空值返回 null', () {
      expect(normalizeCloudBaseUrl('ftp://192.168.1.5/v1'), isNull);
      expect(normalizeCloudBaseUrl('   '), isNull);
    });
  });
}

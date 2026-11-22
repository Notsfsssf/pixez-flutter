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

/// Runs async tasks one after another, in the order they were submitted.
class SerialExecutor {
  SerialExecutor({this.maxWait});

  /// When set, a task that has been running for this long no longer holds
  /// back the tasks after it, e.g. when a platform call never replies.
  final Duration? maxWait;

  Future<void> _tail = Future.value();

  Future<T> run<T>(Future<T> Function() task) {
    final previous = _tail;
    final result = previous.then((_) => task());
    _tail = previous.then((_) {
      final done = result.then<void>((_) {}, onError: (_) {});
      final limit = maxWait;
      return limit == null ? done : done.timeout(limit, onTimeout: () {});
    });
    return result;
  }
}

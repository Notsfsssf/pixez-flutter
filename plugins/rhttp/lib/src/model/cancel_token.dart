import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rhttp/src/rust/api/http.dart' as rust;
import 'package:rhttp/src/rust/lib.dart' as rust_lib;

enum CancelState {
  /// No cancellation is happening.
  /// This is the default state.
  idle,

  /// The token is waiting for the first reference
  /// of the cancellation token on the Rust side.
  waitingForRef,

  /// One or more requests are being cancelled.
  cancelling,

  /// The cancellation process has finished.
  done,
}

/// A token that can be used to cancel an HTTP request.
/// This token should be passed to the request method.
///
/// If the same token is passed to multiple requests,
/// all of them will be cancelled when [cancel] is called.
///
/// If a **cancelled** token is passed to a request method,
/// the request is cancelled immediately.
class CancelToken {
  final _refController = StreamController<rust_lib.CancellationToken>();
  final _firstRef = Completer<rust_lib.CancellationToken>();
  final _refs = <rust_lib.CancellationToken>[];

  CancelState _state = CancelState.idle;

  /// The current state of the token.
  CancelState get state => _state;

  /// Whether the request has been successfully cancelled.
  bool get isCancelled => _state == CancelState.done;

  CancelToken() {
    _refController.stream.listen((ref) {
      switch (_state) {
        case CancelState.idle:
          _refs.add(ref);
          break;
        case CancelState.waitingForRef:
          // "complete" adds a microtask,
          // so we need to set the state first to avoid completing twice.
          _state = CancelState.cancelling;
          _firstRef.complete(ref);
          break;
        case CancelState.cancelling:
        case CancelState.done:
          rust.cancelRequest(token: ref);
          break;
      }
    });
  }

  @internal
  void addRef(rust_lib.CancellationToken ref) {
    if (_refController.isClosed) {
      rust.cancelRequest(token: ref);
      return;
    }
    _refController.add(ref);
  }

  /// Cancels the HTTP request.
  /// If the [CancelToken] is not passed to the request method,
  /// this method never finishes.
  Future<void> cancel() async {
    if (_state != CancelState.idle) {
      return;
    }

    if (_refs.isNotEmpty) {
      _state = CancelState.cancelling;
      for (final ref in _refs) {
        await rust.cancelRequest(token: ref);
      }
    } else {
      // We need to wait for the ref to be set.
      _state = CancelState.waitingForRef;
      final ref = await _firstRef.future;
      await rust.cancelRequest(token: ref);
    }

    _state = CancelState.done;
    _refController.close();
    _refs.clear();
  }
}

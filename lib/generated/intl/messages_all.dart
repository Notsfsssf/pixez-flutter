// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that looks up messages for specific locales by
// delegating to the appropriate library.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:implementation_imports, file_names, unnecessary_new
// ignore_for_file:unnecessary_brace_in_string_interps, directives_ordering
// ignore_for_file:argument_type_not_assignable, invalid_assignment
// ignore_for_file:prefer_single_quotes, prefer_generic_function_type_aliases
// ignore_for_file:comment_references

import 'dart:async';

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';
import 'package:intl/src/intl_helpers.dart';

import 'messages_en-US.dart' as messages_en_us;
import 'messages_ja-JP.dart' as messages_ja_jp;
import 'messages_zh-CN.dart' as messages_zh_cn;
import 'messages_zh-TW.dart' as messages_zh_tw;

typedef Future<dynamic> LibraryLoader();
Map<String, LibraryLoader> _deferredLibraries = {
  'en_US': () => new Future.value(null),
  'ja_JP': () => new Future.value(null),
  'zh_CN': () => new Future.value(null),
  'zh_TW': () => new Future.value(null),
};

MessageLookupByLibrary _findExact(String localeName) {
  switch (localeName) {
    case 'en_US':
      return messages_en_us.messages;
    case 'ja_JP':
      return messages_ja_jp.messages;
    case 'zh_CN':
      return messages_zh_cn.messages;
    case 'zh_TW':
      return messages_zh_tw.messages;
    default:
      return null;
  }
}

/// User programs should call this before using [localeName] for messages.
Future<bool> initializeMessages(String localeName) async {
  var availableLocale = Intl.verifiedLocale(
    localeName,
    (locale) => _deferredLibraries[locale] != null,
    onFailure: (_) => null);
  if (availableLocale == null) {
    return new Future.value(false);
  }
  var lib = _deferredLibraries[availableLocale];
  await (lib == null ? new Future.value(false) : lib());
  initializeInternalMessageLookup(() => new CompositeMessageLookup());
  messageLookup.addLocale(availableLocale, _findGeneratedMessagesFor);
  return new Future.value(true);
}

bool _messagesExistFor(String locale) {
  try {
    return _findExact(locale) != null;
  } catch (e) {
    return false;
  }
}

MessageLookupByLibrary _findGeneratedMessagesFor(String locale) {
  var actualLocale = Intl.verifiedLocale(locale, _messagesExistFor,
      onFailure: (_) => null);
  if (actualLocale == null) return null;
  return _findExact(actualLocale);
}

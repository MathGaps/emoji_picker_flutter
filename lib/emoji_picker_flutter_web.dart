// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

/// A web implementation of the EmojiPickerFlutter plugin.
class EmojiPickerFlutterPluginWeb {
  ///
  static void registerWith(Registrar registrar) {
    final channel = MethodChannel(
      'emoji_picker_flutter',
      const StandardMethodCodec(),
      registrar,
    );

    final pluginInstance = EmojiPickerFlutterPluginWeb();
    channel.setMethodCallHandler(pluginInstance.handleMethodCall);
  }

  /// Handles method calls over the MethodChannel of this plugin.
  /// Note: Check the "federated" architecture for a new way of doing this:
  /// https://flutter.dev/go/federated-plugins
  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'getPlatformVersion':
        return getPlatformVersion();
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details:
              'emoji_picker_flutter for web doesn\'t implement \'${call.method}\'',
        );
    }
  }

  /// Returns a [String] containing the version of the platform.
  Future<String> getPlatformVersion() {
    final version = web.window.navigator.userAgent;
    return Future.value(version);
  }
}

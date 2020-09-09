class Constants {
  static String tagName = "0.2.0";
  static bool isGooglePlay =
      bool.fromEnvironment("IS_GOOGLEPLAY", defaultValue: false);
}

class Inw {
  void a1() {}
}

class Wo {
  void a2() {}
}

class We  implements Inw,Wo {
  @override
  void a1() {
    // TODO: implement a1
  }

  @override
  void a2() {
    // TODO: implement a2
  }

}

mixin Pe {
  void a1() {}
}
mixin Pe1 {
  void a1() {}
}
class Implements {
  int a = 1;

  void base() {
    print('base');
  }

  void log() {
    print('extends');
  }
}

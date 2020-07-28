class Constrains {
  static String tagName = "0.1.2";
  static bool isGooglePlay = true;
}

class B {
  void name() {}
}

class A {
  String string = '';
  void name() {}
}

class D {
  String string = '';
  void name() {}
}

class C extends B with A, Musical implements D {
  C() {
    super.name();
    
  }

  @override
  String string = '';
}

mixin Musical {
  bool canPlayPiano = false;
  bool canCompose = false;
  bool canConduct = false;

  void entertainMe() {
    if (canPlayPiano) {
      print('Playing piano');
    } else if (canConduct) {
      print('Waving hands');
    } else {
      print('Humming to self');
    }
  }
}

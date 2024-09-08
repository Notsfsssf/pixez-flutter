import 'dart:ui';

class Sponsor {
  final String name;
  final String avatar;
  final String uri;
  const Sponsor({
    required this.name,
    required this.avatar,
    required this.uri,
  });
}

class Language {
  final String language;
  final Locale locale;
  final List<Sponsor> sponsors;

  const Language({
    required this.language,
    required this.locale,
    required this.sponsors,
  });
}

const Languages = const [
  Language(
    language: 'en-US',
    locale: Locale('en', 'US'),
    sponsors: [
      Sponsor(
        name: 'Xian',
        avatar: 'https://avatars.githubusercontent.com/u/34748039?v=4',
        uri: 'https://github.com/itzXian',
      ),
      Sponsor(
        name: 'Takase',
        avatar: 'https://avatars.githubusercontent.com/u/20792268?v=4',
        uri: 'https://github.com/takase1121',
      ),
    ],
  ),
  Language(
    language: 'zh-CN',
    locale: Locale('zh', 'CN'),
    sponsors: [
      Sponsor(
        name: 'Skimige',
        avatar: 'https://avatars.githubusercontent.com/u/9017470?v=4',
        uri: 'https://github.com/Skimige',
      ),
    ],
  ),
  Language(
    language: 'zh-TW',
    locale: Locale('zh', 'TW'),
    sponsors: [
      Sponsor(
        name: 'Tragic Life',
        avatar: 'https://avatars.githubusercontent.com/u/16817202?v=4',
        uri: 'https://github.com/TragicLifeHu',
      ),
    ],
  ),
  Language(
    language: 'ja',
    locale: Locale('ja'),
    sponsors: [
      Sponsor(
        name: 'karin722',
        avatar: 'https://avatars.githubusercontent.com/u/54385201?v=4',
        uri: 'https://github.com/karin722',
      ),
      Sponsor(
        name: 'arrow2nd',
        avatar: 'https://avatars.githubusercontent.com/u/44780846?v=4',
        uri: 'https://github.com/arrow2nd',
      ),
    ],
  ),
  Language(
    language: 'ko',
    locale: Locale('ko'),
    sponsors: [
      Sponsor(
        name: 'San Kang',
        avatar: 'https://avatars.githubusercontent.com/u/40086827?v=4',
        uri: 'https://github.com/RivMt',
      ),
    ],
  ),
  Language(
    language: 'ru',
    locale: Locale('ru'),
    sponsors: [
      Sponsor(
        name: 'Vlad Afonin',
        avatar: 'https://avatars.githubusercontent.com/u/20505643?v=4',
        uri: 'https://github.com/mytecor',
      ),
    ],
  ),
  Language(
    language: 'es',
    locale: Locale('es'),
    sponsors: [
      Sponsor(
        name: 'SugarBlank',
        avatar: 'https://avatars.githubusercontent.com/u/64178604?v=4',
        uri: 'https://github.com/SugarBlank',
      ),
    ],
  ),
  Language(
    language: 'tr',
    locale: Locale('tr'),
    sponsors: [
      Sponsor(
        name: 'KYOYA',
        avatar: 'https://avatars.githubusercontent.com/u/63583961?v=4',
        uri: 'https://github.com/kyoyacchi',
      ),
    ],
  ),
  Language(language: 'id', locale: Locale('id', 'ID'), sponsors: [
    Sponsor(
        name: 'ReikiAigawara',
        avatar: 'https://avatars.githubusercontent.com/u/66962815?v=4',
        uri: 'https://github.com/ReikiAigawara')
  ])
];

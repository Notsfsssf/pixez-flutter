import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'i18n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('en', 'US'),
    Locale('es'),
    Locale('id'),
    Locale('id', 'ID'),
    Locale('ja'),
    Locale('ko'),
    Locale('ru'),
    Locale('tr'),
    Locale('zh'),
    Locale('zh', 'CN'),
    Locale('zh', 'TW')
  ];

  /// No description provided for @about.
  ///
  /// In en_US, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @about_picture.
  ///
  /// In en_US, this message translates to:
  /// **'Related illusts'**
  String get about_picture;

  /// No description provided for @account_change.
  ///
  /// In en_US, this message translates to:
  /// **'Switch account'**
  String get account_change;

  /// No description provided for @account_message.
  ///
  /// In en_US, this message translates to:
  /// **'Account info'**
  String get account_message;

  /// No description provided for @ai_generated.
  ///
  /// In en_US, this message translates to:
  /// **'AI-generated'**
  String get ai_generated;

  /// No description provided for @all.
  ///
  /// In en_US, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @already_in_query.
  ///
  /// In en_US, this message translates to:
  /// **'Already in queue'**
  String get already_in_query;

  /// No description provided for @already_saved.
  ///
  /// In en_US, this message translates to:
  /// **'Already saved'**
  String get already_saved;

  /// No description provided for @android_special_setting.
  ///
  /// In en_US, this message translates to:
  /// **'Android-specific Settings'**
  String get android_special_setting;

  /// No description provided for @append_to_query.
  ///
  /// In en_US, this message translates to:
  /// **'Added to queue'**
  String get append_to_query;

  /// No description provided for @apply.
  ///
  /// In en_US, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @attempting_to_log_in.
  ///
  /// In en_US, this message translates to:
  /// **'Logging in'**
  String get attempting_to_log_in;

  /// No description provided for @ban.
  ///
  /// In en_US, this message translates to:
  /// **'Mute'**
  String get ban;

  /// No description provided for @birthday.
  ///
  /// In en_US, this message translates to:
  /// **'Birthday'**
  String get birthday;

  /// No description provided for @block_user.
  ///
  /// In en_US, this message translates to:
  /// **'Mute this user'**
  String get block_user;

  /// No description provided for @bookmark.
  ///
  /// In en_US, this message translates to:
  /// **'Collections'**
  String get bookmark;

  /// No description provided for @bookmarked.
  ///
  /// In en_US, this message translates to:
  /// **'Bookmarked'**
  String get bookmarked;

  /// No description provided for @cancel.
  ///
  /// In en_US, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @canceled.
  ///
  /// In en_US, this message translates to:
  /// **'Cancelled'**
  String get canceled;

  /// No description provided for @check_for_updates.
  ///
  /// In en_US, this message translates to:
  /// **'Check for updates'**
  String get check_for_updates;

  /// No description provided for @choice_you_like.
  ///
  /// In en_US, this message translates to:
  /// **'Visible tags'**
  String get choice_you_like;

  /// No description provided for @choose_directory.
  ///
  /// In en_US, this message translates to:
  /// **'Select folder'**
  String get choose_directory;

  /// No description provided for @clear.
  ///
  /// In en_US, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @clear_all_cache.
  ///
  /// In en_US, this message translates to:
  /// **'Clear all cache'**
  String get clear_all_cache;

  /// No description provided for @clear_completed_tasks.
  ///
  /// In en_US, this message translates to:
  /// **'Clear completed tasks'**
  String get clear_completed_tasks;

  /// No description provided for @clearn_cache.
  ///
  /// In en_US, this message translates to:
  /// **'Clear cache'**
  String get clearn_cache;

  /// No description provided for @clearn_cache_hint.
  ///
  /// In en_US, this message translates to:
  /// **'Try this when you have problems with playing GIFs'**
  String get clearn_cache_hint;

  /// No description provided for @complete.
  ///
  /// In en_US, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @copied_to_clipboard.
  ///
  /// In en_US, this message translates to:
  /// **'Copied to clipboard'**
  String get copied_to_clipboard;

  /// No description provided for @copymessage.
  ///
  /// In en_US, this message translates to:
  /// **'Copy illust info'**
  String get copymessage;

  /// No description provided for @crosscount.
  ///
  /// In en_US, this message translates to:
  /// **'Number of illusts per page'**
  String get crosscount;

  /// No description provided for @current_password.
  ///
  /// In en_US, this message translates to:
  /// **'Current password'**
  String get current_password;

  /// No description provided for @date_asc.
  ///
  /// In en_US, this message translates to:
  /// **'Older'**
  String get date_asc;

  /// No description provided for @date_desc.
  ///
  /// In en_US, this message translates to:
  /// **'Newer'**
  String get date_desc;

  /// No description provided for @date_duration.
  ///
  /// In en_US, this message translates to:
  /// **'Date range'**
  String get date_duration;

  /// No description provided for @delete.
  ///
  /// In en_US, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @detail.
  ///
  /// In en_US, this message translates to:
  /// **'User info'**
  String get detail;

  /// No description provided for @disable_sni_bypass.
  ///
  /// In en_US, this message translates to:
  /// **'Disable SNI Bypassing'**
  String get disable_sni_bypass;

  /// No description provided for @disable_sni_bypass_message.
  ///
  /// In en_US, this message translates to:
  /// **'Decreases DoH time on startup'**
  String get disable_sni_bypass_message;

  /// No description provided for @display_mode.
  ///
  /// In en_US, this message translates to:
  /// **'Display refresh rate'**
  String get display_mode;

  /// No description provided for @display_mode_message.
  ///
  /// In en_US, this message translates to:
  /// **'Select refresh rate (experimental)'**
  String get display_mode_message;

  /// No description provided for @display_mode_warning.
  ///
  /// In en_US, this message translates to:
  /// **'Do not change it unless your device supports it.'**
  String get display_mode_warning;

  /// No description provided for @donate_message.
  ///
  /// In en_US, this message translates to:
  /// **'Thank you!'**
  String get donate_message;

  /// No description provided for @donate_title.
  ///
  /// In en_US, this message translates to:
  /// **'Buy me a coffee'**
  String get donate_title;

  /// No description provided for @donation.
  ///
  /// In en_US, this message translates to:
  /// **'Buy me a coffee'**
  String get donation;

  /// No description provided for @dont_have_account.
  ///
  /// In en_US, this message translates to:
  /// **'Don\'t have an account yet?'**
  String get dont_have_account;

  /// No description provided for @download_address.
  ///
  /// In en_US, this message translates to:
  /// **'Download link'**
  String get download_address;

  /// No description provided for @encode.
  ///
  /// In en_US, this message translates to:
  /// **'Encoding'**
  String get encode;

  /// No description provided for @encode_message.
  ///
  /// In en_US, this message translates to:
  /// **'This may take some time and might fail'**
  String get encode_message;

  /// No description provided for @enqueued.
  ///
  /// In en_US, this message translates to:
  /// **'Enqueued'**
  String get enqueued;

  /// No description provided for @exact_match_for_tag.
  ///
  /// In en_US, this message translates to:
  /// **'Tag exact matches'**
  String get exact_match_for_tag;

  /// No description provided for @failed.
  ///
  /// In en_US, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @feedback.
  ///
  /// In en_US, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @filter.
  ///
  /// In en_US, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @follow.
  ///
  /// In en_US, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @followed.
  ///
  /// In en_US, this message translates to:
  /// **'Following'**
  String get followed;

  /// No description provided for @format.
  ///
  /// In en_US, this message translates to:
  /// **'Format'**
  String get format;

  /// No description provided for @gender.
  ///
  /// In en_US, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @go_to_login.
  ///
  /// In en_US, this message translates to:
  /// **'Login'**
  String get go_to_login;

  /// No description provided for @go_to_project_address.
  ///
  /// In en_US, this message translates to:
  /// **'Go to GitHub repo'**
  String get go_to_project_address;

  /// No description provided for @history.
  ///
  /// In en_US, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @history_record.
  ///
  /// In en_US, this message translates to:
  /// **'Browsing history'**
  String get history_record;

  /// No description provided for @home.
  ///
  /// In en_US, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @illust.
  ///
  /// In en_US, this message translates to:
  /// **'Illust'**
  String get illust;

  /// No description provided for @illust_id.
  ///
  /// In en_US, this message translates to:
  /// **'Illust ID'**
  String get illust_id;

  /// No description provided for @illustration_detail_page_quality.
  ///
  /// In en_US, this message translates to:
  /// **'Image quality (Details page)'**
  String get illustration_detail_page_quality;

  /// No description provided for @input_nickname.
  ///
  /// In en_US, this message translates to:
  /// **'Enter nickname'**
  String get input_nickname;

  /// No description provided for @job.
  ///
  /// In en_US, this message translates to:
  /// **'Job'**
  String get job;

  /// No description provided for @key_word.
  ///
  /// In en_US, this message translates to:
  /// **'Keywords'**
  String get key_word;

  /// No description provided for @large.
  ///
  /// In en_US, this message translates to:
  /// **'High'**
  String get large;

  /// No description provided for @large_preview_zoom_quality.
  ///
  /// In en_US, this message translates to:
  /// **'Image quality (Fullscreen)'**
  String get large_preview_zoom_quality;

  /// No description provided for @latest_version.
  ///
  /// In en_US, this message translates to:
  /// **'Latest version'**
  String get latest_version;

  /// No description provided for @let_go_and_load_more.
  ///
  /// In en_US, this message translates to:
  /// **'Release to load more'**
  String get let_go_and_load_more;

  /// No description provided for @load_image_failed_click_to_reload.
  ///
  /// In en_US, this message translates to:
  /// **'Failed to load. Click to retry'**
  String get load_image_failed_click_to_reload;

  /// No description provided for @loading_failed_retry_message.
  ///
  /// In en_US, this message translates to:
  /// **'Failed to load. Click to retry'**
  String get loading_failed_retry_message;

  /// No description provided for @login.
  ///
  /// In en_US, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @login_message.
  ///
  /// In en_US, this message translates to:
  /// **'Discover a whole new world'**
  String get login_message;

  /// No description provided for @logout.
  ///
  /// In en_US, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logout_message.
  ///
  /// In en_US, this message translates to:
  /// **'This will clear account info and return to Login page.'**
  String get logout_message;

  /// No description provided for @manga.
  ///
  /// In en_US, this message translates to:
  /// **'Manga'**
  String get manga;

  /// No description provided for @medium.
  ///
  /// In en_US, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @mode_list.
  ///
  /// In en_US, this message translates to:
  /// **'Daily For_male For_female Original Rookie Weekly Monthly AI XVIII_AI XVIII XVIII_WEEKLY XVIII_G'**
  String get mode_list;

  /// No description provided for @novel_mode_list.
  ///
  /// In en_US, this message translates to:
  /// **'Daily For_male For_female Weekly AI XVIII_AI XVIII XVIII_WEEKLY XVIII_G'**
  String get novel_mode_list;

  /// No description provided for @more.
  ///
  /// In en_US, this message translates to:
  /// **'More'**
  String get more;

  /// A message with a single parameter
  ///
  /// In en_US, this message translates to:
  /// **'More than {starNum} like(s)'**
  String more_then_starnum_bookmark(String starNum);

  /// No description provided for @muti_choice_save.
  ///
  /// In en_US, this message translates to:
  /// **'Save selected'**
  String get muti_choice_save;

  /// No description provided for @my.
  ///
  /// In en_US, this message translates to:
  /// **'Mine'**
  String get my;

  /// No description provided for @need_to_restart_app.
  ///
  /// In en_US, this message translates to:
  /// **'Restart required'**
  String get need_to_restart_app;

  /// No description provided for @news.
  ///
  /// In en_US, this message translates to:
  /// **'Activities'**
  String get news;

  /// No description provided for @new_password.
  ///
  /// In en_US, this message translates to:
  /// **'New password'**
  String get new_password;

  /// No description provided for @new_version_update_information.
  ///
  /// In en_US, this message translates to:
  /// **'Changelog'**
  String get new_version_update_information;

  /// No description provided for @nickname.
  ///
  /// In en_US, this message translates to:
  /// **'Nickname'**
  String get nickname;

  /// No description provided for @nickname_can_be_change_anytime.
  ///
  /// In en_US, this message translates to:
  /// **'Nickname can be changed anytime'**
  String get nickname_can_be_change_anytime;

  /// No description provided for @no_h.
  ///
  /// In en_US, this message translates to:
  /// **'H is not allowed!'**
  String get no_h;

  /// No description provided for @no_more_data.
  ///
  /// In en_US, this message translates to:
  /// **'No more data'**
  String get no_more_data;

  /// No description provided for @not_bookmarked.
  ///
  /// In en_US, this message translates to:
  /// **'Not bookmarked'**
  String get not_bookmarked;

  /// No description provided for @ok.
  ///
  /// In en_US, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @painter.
  ///
  /// In en_US, this message translates to:
  /// **'User'**
  String get painter;

  /// No description provided for @painter_id.
  ///
  /// In en_US, this message translates to:
  /// **'User ID'**
  String get painter_id;

  /// No description provided for @painter_name.
  ///
  /// In en_US, this message translates to:
  /// **'User name'**
  String get painter_name;

  /// No description provided for @partial_match_for_tag.
  ///
  /// In en_US, this message translates to:
  /// **'Tag partial matches'**
  String get partial_match_for_tag;

  /// No description provided for @path.
  ///
  /// In en_US, this message translates to:
  /// **'Path'**
  String get path;

  /// No description provided for @paused.
  ///
  /// In en_US, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @perol_message.
  ///
  /// In en_US, this message translates to:
  /// **'Author of the project. Built with Flutter.'**
  String get perol_message;

  /// No description provided for @personal.
  ///
  /// In en_US, this message translates to:
  /// **'Personal'**
  String get personal;

  /// No description provided for @pixel.
  ///
  /// In en_US, this message translates to:
  /// **'Resolution'**
  String get pixel;

  /// No description provided for @please_note_that.
  ///
  /// In en_US, this message translates to:
  /// **'Notice'**
  String get please_note_that;

  /// No description provided for @please_note_that_content.
  ///
  /// In en_US, this message translates to:
  /// **'This option should be OFF unless you are able to access pixiv.net without any issue.'**
  String get please_note_that_content;

  /// No description provided for @popular_desc.
  ///
  /// In en_US, this message translates to:
  /// **'Popular'**
  String get popular_desc;

  /// No description provided for @private.
  ///
  /// In en_US, this message translates to:
  /// **'Private'**
  String get private;

  /// No description provided for @public.
  ///
  /// In en_US, this message translates to:
  /// **'Public'**
  String get public;

  /// No description provided for @pull_up_to_load_more.
  ///
  /// In en_US, this message translates to:
  /// **'Swipe up to load more'**
  String get pull_up_to_load_more;

  /// No description provided for @quality_setting.
  ///
  /// In en_US, this message translates to:
  /// **'Preferences'**
  String get quality_setting;

  /// No description provided for @quick_view.
  ///
  /// In en_US, this message translates to:
  /// **'Favorites'**
  String get quick_view;

  /// No description provided for @quietly_follow.
  ///
  /// In en_US, this message translates to:
  /// **'Follow privately'**
  String get quietly_follow;

  /// No description provided for @rank.
  ///
  /// In en_US, this message translates to:
  /// **'Rankings'**
  String get rank;

  /// No description provided for @rate_message.
  ///
  /// In en_US, this message translates to:
  /// **'Please give us 5 stars!'**
  String get rate_message;

  /// No description provided for @rate_title.
  ///
  /// In en_US, this message translates to:
  /// **'If you think that PixEz is awesome, please give us a 5-star rating!'**
  String get rate_title;

  /// No description provided for @recommand_tag.
  ///
  /// In en_US, this message translates to:
  /// **'Recommended tags'**
  String get recommand_tag;

  /// No description provided for @recommend.
  ///
  /// In en_US, this message translates to:
  /// **'Recommended'**
  String get recommend;

  /// No description provided for @recommend_for_you.
  ///
  /// In en_US, this message translates to:
  /// **'For you'**
  String get recommend_for_you;

  /// No description provided for @refresh.
  ///
  /// In en_US, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @reply.
  ///
  /// In en_US, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @repo_address.
  ///
  /// In en_US, this message translates to:
  /// **'GitHub'**
  String get repo_address;

  /// No description provided for @report.
  ///
  /// In en_US, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @report_message.
  ///
  /// In en_US, this message translates to:
  /// **'Report this content if it makes you feel uncomfortable, we will remove it ASAP once we confirmed that it\'s harmful.'**
  String get report_message;

  /// No description provided for @retry.
  ///
  /// In en_US, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @retry_failed_tasks.
  ///
  /// In en_US, this message translates to:
  /// **'Retry failed tasks'**
  String get retry_failed_tasks;

  /// No description provided for @right_now_message.
  ///
  /// In en_US, this message translates to:
  /// **'The designer who drew the lovely icon for PixEz'**
  String get right_now_message;

  /// No description provided for @running.
  ///
  /// In en_US, this message translates to:
  /// **'Running'**
  String get running;

  /// No description provided for @save.
  ///
  /// In en_US, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @save_format.
  ///
  /// In en_US, this message translates to:
  /// **'Filename format'**
  String get save_format;

  /// No description provided for @save_path.
  ///
  /// In en_US, this message translates to:
  /// **'Save location'**
  String get save_path;

  /// No description provided for @saved.
  ///
  /// In en_US, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @search.
  ///
  /// In en_US, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @search_word_or_paste_link.
  ///
  /// In en_US, this message translates to:
  /// **'Enter keywords or paste links'**
  String get search_word_or_paste_link;

  /// No description provided for @separate_folder.
  ///
  /// In en_US, this message translates to:
  /// **'Separate folders'**
  String get separate_folder;

  /// No description provided for @separate_folder_message.
  ///
  /// In en_US, this message translates to:
  /// **'Create separate folders for each user'**
  String get separate_folder_message;

  /// No description provided for @setting.
  ///
  /// In en_US, this message translates to:
  /// **'Settings'**
  String get setting;

  /// No description provided for @share.
  ///
  /// In en_US, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @share_this_app_link.
  ///
  /// In en_US, this message translates to:
  /// **'Share this app with others'**
  String get share_this_app_link;

  /// A message with a parameter
  ///
  /// In en_US, this message translates to:
  /// **'{name} has been muted or reported'**
  String shield_message(String name);

  /// No description provided for @shielding_settings.
  ///
  /// In en_US, this message translates to:
  /// **'Mute settings'**
  String get shielding_settings;

  /// No description provided for @skimige_message.
  ///
  /// In en_US, this message translates to:
  /// **'The contributor who wrote the wonderful README'**
  String get skimige_message;

  /// No description provided for @skin.
  ///
  /// In en_US, this message translates to:
  /// **'Skins'**
  String get skin;

  /// No description provided for @skip.
  ///
  /// In en_US, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @source.
  ///
  /// In en_US, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @spotlight.
  ///
  /// In en_US, this message translates to:
  /// **'Highlights'**
  String get spotlight;

  /// No description provided for @support.
  ///
  /// In en_US, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @support_message.
  ///
  /// In en_US, this message translates to:
  /// **'Feedbacks and contributions are welcomed :)'**
  String get support_message;

  /// No description provided for @tag.
  ///
  /// In en_US, this message translates to:
  /// **'Tag'**
  String get tag;

  /// No description provided for @task_progress.
  ///
  /// In en_US, this message translates to:
  /// **'Download progress'**
  String get task_progress;

  /// No description provided for @terms.
  ///
  /// In en_US, this message translates to:
  /// **'Terms of use'**
  String get terms;

  /// No description provided for @thanks.
  ///
  /// In en_US, this message translates to:
  /// **'Thank you'**
  String get thanks;

  /// No description provided for @theme.
  ///
  /// In en_US, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @title.
  ///
  /// In en_US, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @title_and_caption.
  ///
  /// In en_US, this message translates to:
  /// **'Title and description'**
  String get title_and_caption;

  /// No description provided for @total_bookmark.
  ///
  /// In en_US, this message translates to:
  /// **'Likes'**
  String get total_bookmark;

  /// No description provided for @total_follow_users.
  ///
  /// In en_US, this message translates to:
  /// **'Followed users'**
  String get total_follow_users;

  /// No description provided for @total_mypixiv_users.
  ///
  /// In en_US, this message translates to:
  /// **'Total My Pixiv users'**
  String get total_mypixiv_users;

  /// No description provided for @total_view.
  ///
  /// In en_US, this message translates to:
  /// **'Views'**
  String get total_view;

  /// No description provided for @twitter_account.
  ///
  /// In en_US, this message translates to:
  /// **'Twitter'**
  String get twitter_account;

  /// No description provided for @un_follow.
  ///
  /// In en_US, this message translates to:
  /// **'Not following'**
  String get un_follow;

  /// No description provided for @undefined.
  ///
  /// In en_US, this message translates to:
  /// **'Undefined'**
  String get undefined;

  /// No description provided for @unsaved.
  ///
  /// In en_US, this message translates to:
  /// **'Unsaved'**
  String get unsaved;

  /// No description provided for @update.
  ///
  /// In en_US, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @view_comment.
  ///
  /// In en_US, this message translates to:
  /// **'View comments'**
  String get view_comment;

  /// No description provided for @warning.
  ///
  /// In en_US, this message translates to:
  /// **'Clear all cache?'**
  String get warning;

  /// No description provided for @welcome_page.
  ///
  /// In en_US, this message translates to:
  /// **'Welcome page'**
  String get welcome_page;

  /// No description provided for @which_part.
  ///
  /// In en_US, this message translates to:
  /// **'Page'**
  String get which_part;

  /// No description provided for @works.
  ///
  /// In en_US, this message translates to:
  /// **'Works'**
  String get works;

  /// No description provided for @pick_a_color.
  ///
  /// In en_US, this message translates to:
  /// **'Pick a color'**
  String get pick_a_color;

  /// A message with a single parameter
  ///
  /// In en_US, this message translates to:
  /// **'Tap to show {length} results'**
  String tap_to_show_results(String length);

  /// No description provided for @saf_hint.
  ///
  /// In en_US, this message translates to:
  /// **'In order to use SAF you will need to grant SAF access to Pixiv(e.g. Picture/Pixez). This allows you to store illusts to SD cards in modern devices.'**
  String get saf_hint;

  /// No description provided for @what_is_saf.
  ///
  /// In en_US, this message translates to:
  /// **'Why?'**
  String get what_is_saf;

  /// No description provided for @not_the_correct_link.
  ///
  /// In en_US, this message translates to:
  /// **'Not a valid Pixiv link >_<'**
  String get not_the_correct_link;

  /// No description provided for @start.
  ///
  /// In en_US, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @clear_search_tag_history.
  ///
  /// In en_US, this message translates to:
  /// **'Clear search history'**
  String get clear_search_tag_history;

  /// No description provided for @link.
  ///
  /// In en_US, this message translates to:
  /// **'Link'**
  String get link;

  /// No description provided for @step.
  ///
  /// In en_US, this message translates to:
  /// **'Step'**
  String get step;

  /// No description provided for @special_shaped_screen.
  ///
  /// In en_US, this message translates to:
  /// **'Notched screen'**
  String get special_shaped_screen;

  /// No description provided for @platform_special_setting.
  ///
  /// In en_US, this message translates to:
  /// **'Platform-specific settings'**
  String get platform_special_setting;

  /// No description provided for @system.
  ///
  /// In en_US, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en_US, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en_US, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @theme_mode.
  ///
  /// In en_US, this message translates to:
  /// **'Theme'**
  String get theme_mode;

  /// No description provided for @create_folder.
  ///
  /// In en_US, this message translates to:
  /// **'Create folder'**
  String get create_folder;

  /// No description provided for @old_way.
  ///
  /// In en_US, this message translates to:
  /// **'Traditional'**
  String get old_way;

  /// No description provided for @permission_denied.
  ///
  /// In en_US, this message translates to:
  /// **'Permission denied'**
  String get permission_denied;

  /// No description provided for @old_way_message.
  ///
  /// In en_US, this message translates to:
  /// **'In order to use this method, you will need to allow PixEz to access your files and select a folder'**
  String get old_way_message;

  /// No description provided for @return_again_to_exit.
  ///
  /// In en_US, this message translates to:
  /// **'Return again to exit'**
  String get return_again_to_exit;

  /// A message with a parameter
  ///
  /// In en_US, this message translates to:
  /// **'Save format must contain {part}. Otherwise, multipage artworks will not be saved correctly!'**
  String save_format_lose_part_warning(String part);

  /// No description provided for @save_painter_avatar.
  ///
  /// In en_US, this message translates to:
  /// **'Save painter avatar'**
  String get save_painter_avatar;

  /// No description provided for @favorited_tag.
  ///
  /// In en_US, this message translates to:
  /// **'Favorited Tags'**
  String get favorited_tag;

  /// No description provided for @legacy_mode_warning.
  ///
  /// In en_US, this message translates to:
  /// **'Legacy mode is not available since Android9'**
  String get legacy_mode_warning;

  /// No description provided for @clear_old_format_file.
  ///
  /// In en_US, this message translates to:
  /// **'Clear old format file'**
  String get clear_old_format_file;

  /// No description provided for @clear_old_format_file_message.
  ///
  /// In en_US, this message translates to:
  /// **'Without _p0'**
  String get clear_old_format_file_message;

  /// No description provided for @login_error_message.
  ///
  /// In en_US, this message translates to:
  /// **'Incorrect account or password, or using a weak password, may cause login failure'**
  String get login_error_message;

  /// No description provided for @translate.
  ///
  /// In en_US, this message translates to:
  /// **'Translate'**
  String get translate;

  /// No description provided for @retry_seed_task.
  ///
  /// In en_US, this message translates to:
  /// **'Retry init task'**
  String get retry_seed_task;

  /// No description provided for @manga_detail_page_quality.
  ///
  /// In en_US, this message translates to:
  /// **'Manga quality (Details page)'**
  String get manga_detail_page_quality;

  /// No description provided for @follow_after_star.
  ///
  /// In en_US, this message translates to:
  /// **'Follow after star'**
  String get follow_after_star;

  /// No description provided for @default_title.
  ///
  /// In en_US, this message translates to:
  /// **'Default'**
  String get default_title;

  /// No description provided for @image_site.
  ///
  /// In en_US, this message translates to:
  /// **'Image Site'**
  String get image_site;

  /// No description provided for @network.
  ///
  /// In en_US, this message translates to:
  /// **'Network'**
  String get network;

  /// No description provided for @select_language.
  ///
  /// In en_US, this message translates to:
  /// **'Select Language'**
  String get select_language;

  /// No description provided for @network_question.
  ///
  /// In en_US, this message translates to:
  /// **'Is your network environment able to access pixiv normally?'**
  String get network_question;

  /// No description provided for @media_hint.
  ///
  /// In en_US, this message translates to:
  /// **'Illustrations will be saved to the album'**
  String get media_hint;

  /// No description provided for @copy.
  ///
  /// In en_US, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @view_replies.
  ///
  /// In en_US, this message translates to:
  /// **'View reply'**
  String get view_replies;

  /// No description provided for @temporarily_visible.
  ///
  /// In en_US, this message translates to:
  /// **'Temporarily visible'**
  String get temporarily_visible;

  /// No description provided for @unclassified.
  ///
  /// In en_US, this message translates to:
  /// **'Unclassified'**
  String get unclassified;

  /// No description provided for @max_download_task_running_count.
  ///
  /// In en_US, this message translates to:
  /// **'Max download task running count'**
  String get max_download_task_running_count;

  /// No description provided for @export.
  ///
  /// In en_US, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @error_400_hint.
  ///
  /// In en_US, this message translates to:
  /// **'If the error message is [400] error, you may need to log in again, which may be caused by changing the password or api upgrade'**
  String get error_400_hint;

  /// No description provided for @recent_screen_mask.
  ///
  /// In en_US, this message translates to:
  /// **'Recent screen mask'**
  String get recent_screen_mask;

  /// No description provided for @open_by_default.
  ///
  /// In en_US, this message translates to:
  /// **'Open by default'**
  String get open_by_default;

  /// No description provided for @open_by_default_subtitle.
  ///
  /// In en_US, this message translates to:
  /// **'Allow web links to open this app'**
  String get open_by_default_subtitle;

  /// No description provided for @text.
  ///
  /// In en_US, this message translates to:
  /// **'Text'**
  String get text;

  /// No description provided for @search_word_hint.
  ///
  /// In en_US, this message translates to:
  /// **'Search title or name like'**
  String get search_word_hint;

  /// No description provided for @save_effect.
  ///
  /// In en_US, this message translates to:
  /// **'Save effect'**
  String get save_effect;

  /// No description provided for @layout_mode.
  ///
  /// In en_US, this message translates to:
  /// **'Layout mode'**
  String get layout_mode;

  /// No description provided for @share_info_format.
  ///
  /// In en_US, this message translates to:
  /// **'Share info format'**
  String get share_info_format;

  /// No description provided for @account_deletion.
  ///
  /// In en_US, this message translates to:
  /// **'Delete account'**
  String get account_deletion;

  /// No description provided for @account_deletion_subtitle.
  ///
  /// In en_US, this message translates to:
  /// **'This will log you out of your account and go to the webpage to delete your account'**
  String get account_deletion_subtitle;

  /// No description provided for @private_like_by_default.
  ///
  /// In en_US, this message translates to:
  /// **'Private like by default'**
  String get private_like_by_default;

  /// No description provided for @partially_hidden.
  ///
  /// In en_US, this message translates to:
  /// **'Partially hidden'**
  String get partially_hidden;

  /// No description provided for @show.
  ///
  /// In en_US, this message translates to:
  /// **'Show'**
  String get show;

  /// No description provided for @ai_work_display_settings.
  ///
  /// In en_US, this message translates to:
  /// **'AI generated works display settings'**
  String get ai_work_display_settings;

  /// No description provided for @make_works_with_ai_generated_flags_invisible.
  ///
  /// In en_US, this message translates to:
  /// **'Make works with AI generated flags invisible'**
  String get make_works_with_ai_generated_flags_invisible;

  /// No description provided for @script_page_hint.
  ///
  /// In en_US, this message translates to:
  /// **'This function is designed to handle the file name when saving illustrations by customizing the js script. If you don\'t know the principle, please don\'t try it at will. You can restore the default settings by clicking the cross in the upper right corner'**
  String get script_page_hint;

  /// No description provided for @long_press_save_confirm.
  ///
  /// In en_US, this message translates to:
  /// **'Long press to save confirm'**
  String get long_press_save_confirm;

  /// No description provided for @dynamic_color.
  ///
  /// In en_US, this message translates to:
  /// **'Dynamic color'**
  String get dynamic_color;

  /// No description provided for @seed_color.
  ///
  /// In en_US, this message translates to:
  /// **'Seed color'**
  String get seed_color;

  /// No description provided for @app_data.
  ///
  /// In en_US, this message translates to:
  /// **'App data'**
  String get app_data;

  /// No description provided for @export_title.
  ///
  /// In en_US, this message translates to:
  /// **'Export'**
  String get export_title;

  /// No description provided for @import_title.
  ///
  /// In en_US, this message translates to:
  /// **'Import'**
  String get import_title;

  /// No description provided for @export_bookmark_tag.
  ///
  /// In en_US, this message translates to:
  /// **'Export bookmark tags'**
  String get export_bookmark_tag;

  /// No description provided for @export_tag_history.
  ///
  /// In en_US, this message translates to:
  /// **'Export tag history'**
  String get export_tag_history;

  /// No description provided for @export_illust_history.
  ///
  /// In en_US, this message translates to:
  /// **'Export browsing history'**
  String get export_illust_history;

  /// No description provided for @import_bookmark_tag.
  ///
  /// In en_US, this message translates to:
  /// **'Import bookmark tags'**
  String get import_bookmark_tag;

  /// No description provided for @import_tag_history.
  ///
  /// In en_US, this message translates to:
  /// **'Import tag history'**
  String get import_tag_history;

  /// No description provided for @import_illust_history.
  ///
  /// In en_US, this message translates to:
  /// **'Import browsing history'**
  String get import_illust_history;

  /// No description provided for @photo_picker.
  ///
  /// In en_US, this message translates to:
  /// **'Photo picker'**
  String get photo_picker;

  /// No description provided for @photo_picker_subtitle.
  ///
  /// In en_US, this message translates to:
  /// **'Use new system-level image selector'**
  String get photo_picker_subtitle;

  /// No description provided for @swipe_to_switch_artworks.
  ///
  /// In en_US, this message translates to:
  /// **'Swipe to switch artworks'**
  String get swipe_to_switch_artworks;

  /// No description provided for @view_the_latest.
  ///
  /// In en_US, this message translates to:
  /// **'View the latest'**
  String get view_the_latest;

  /// No description provided for @automatically_download_when_bookmarking.
  ///
  /// In en_US, this message translates to:
  /// **'Automatically download when bookmarking'**
  String get automatically_download_when_bookmarking;

  /// No description provided for @automatically_bookmark_when_downloading.
  ///
  /// In en_US, this message translates to:
  /// **'Automatically bookmark when downloading'**
  String get automatically_bookmark_when_downloading;

  /// No description provided for @footer_loading.
  ///
  /// In en_US, this message translates to:
  /// **'Loading...'**
  String get footer_loading;

  /// No description provided for @successed.
  ///
  /// In en_US, this message translates to:
  /// **'Successed'**
  String get successed;

  /// No description provided for @reply_to.
  ///
  /// In en_US, this message translates to:
  /// **'Reply to'**
  String get reply_to;

  /// No description provided for @show_feed_ai_badge.
  ///
  /// In en_US, this message translates to:
  /// **'Show feed AI badge'**
  String get show_feed_ai_badge;

  /// No description provided for @illust_detail_save_skip_confirm.
  ///
  /// In en_US, this message translates to:
  /// **'Skip confirmation when saving on details page'**
  String get illust_detail_save_skip_confirm;

  /// No description provided for @secure_window.
  ///
  /// In en_US, this message translates to:
  /// **'Secure window'**
  String get secure_window;

  /// No description provided for @open_saucenao_using_webview.
  ///
  /// In en_US, this message translates to:
  /// **'Open SauceNao using webview'**
  String get open_saucenao_using_webview;

  /// No description provided for @appwidget_recommend_type.
  ///
  /// In en_US, this message translates to:
  /// **'Appwidget recommend type'**
  String get appwidget_recommend_type;

  /// No description provided for @popular_male_desc.
  ///
  /// In en_US, this message translates to:
  /// **'Popular male desc'**
  String get popular_male_desc;

  /// No description provided for @popular_female_desc.
  ///
  /// In en_US, this message translates to:
  /// **'Popular female desc'**
  String get popular_female_desc;

  /// No description provided for @feed_preview_quality.
  ///
  /// In en_US, this message translates to:
  /// **'Feed preview quality'**
  String get feed_preview_quality;

  /// No description provided for @clean_history.
  ///
  /// In en_US, this message translates to:
  /// **'Clean history?'**
  String get clean_history;

  /// No description provided for @novel.
  ///
  /// In en_US, this message translates to:
  /// **'Novel'**
  String get novel;

  /// No description provided for @bulletin_board.
  ///
  /// In en_US, this message translates to:
  /// **'Bulletin board'**
  String get bulletin_board;

  /// No description provided for @hide.
  ///
  /// In en_US, this message translates to:
  /// **'Hide'**
  String get hide;

  /// No description provided for @reveal.
  ///
  /// In en_US, this message translates to:
  /// **'Reveal'**
  String get reveal;

  /// No description provided for @illust_page.
  ///
  /// In en_US, this message translates to:
  /// **'Illust page'**
  String get illust_page;

  /// No description provided for @novel_page.
  ///
  /// In en_US, this message translates to:
  /// **'Novel page'**
  String get novel_page;

  /// No description provided for @export_mute_data.
  ///
  /// In en_US, this message translates to:
  /// **'Export mute data'**
  String get export_mute_data;

  /// No description provided for @import_mute_data.
  ///
  /// In en_US, this message translates to:
  /// **'Import mute data'**
  String get import_mute_data;

  /// No description provided for @watchlist_added.
  ///
  /// In en_US, this message translates to:
  /// **'Watchlist added'**
  String get watchlist_added;

  /// No description provided for @add_to_watchlist.
  ///
  /// In en_US, this message translates to:
  /// **'Add to watchlist'**
  String get add_to_watchlist;

  /// No description provided for @watchlist.
  ///
  /// In en_US, this message translates to:
  /// **'Watchlist'**
  String get watchlist;

  /// No description provided for @view_latest.
  ///
  /// In en_US, this message translates to:
  /// **'View latest'**
  String get view_latest;

  /// No description provided for @storage_permission_denied.
  ///
  /// In en_US, this message translates to:
  /// **'Storage permission denied'**
  String get storage_permission_denied;

  /// No description provided for @dont_show_again.
  ///
  /// In en_US, this message translates to:
  /// **'Don\'t show again'**
  String get dont_show_again;

  /// No description provided for @custom_host.
  ///
  /// In en_US, this message translates to:
  /// **'Custom Host'**
  String get custom_host;

  /// No description provided for @network_tip.
  ///
  /// In en_US, this message translates to:
  /// **'If you cannot load images, you can try switching image sources, you can return to this page by going to the settings page'**
  String get network_tip;

  /// No description provided for @account.
  ///
  /// In en_US, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @save_wait_time_warning.
  ///
  /// In en_US, this message translates to:
  /// **'It may cause a long waiting time for saving.'**
  String get save_wait_time_warning;

  /// No description provided for @uploading.
  ///
  /// In en_US, this message translates to:
  /// **'Uploading'**
  String get uploading;

  /// No description provided for @parsing.
  ///
  /// In en_US, this message translates to:
  /// **'parsing'**
  String get parsing;

  /// No description provided for @no_more.
  ///
  /// In en_US, this message translates to:
  /// **'No more'**
  String get no_more;

  /// No description provided for @delete_tag.
  ///
  /// In en_US, this message translates to:
  /// **'Delete this tag?'**
  String get delete_tag;

  /// No description provided for @no_result.
  ///
  /// In en_US, this message translates to:
  /// **'0 result'**
  String get no_result;

  /// No description provided for @pre.
  ///
  /// In en_US, this message translates to:
  /// **'Pre'**
  String get pre;

  /// No description provided for @next.
  ///
  /// In en_US, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @submit.
  ///
  /// In en_US, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @thanks_for_your_feedback.
  ///
  /// In en_US, this message translates to:
  /// **'Thanks for your feedback'**
  String get thanks_for_your_feedback;

  /// No description provided for @input.
  ///
  /// In en_US, this message translates to:
  /// **'Input'**
  String get input;

  /// No description provided for @remember_current_selections.
  ///
  /// In en_US, this message translates to:
  /// **'Remember current selections'**
  String get remember_current_selections;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es', 'id', 'ja', 'ko', 'ru', 'tr', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {

  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'en': {
  switch (locale.countryCode) {
    case 'US': return AppLocalizationsEnUs();
   }
  break;
   }
    case 'id': {
  switch (locale.countryCode) {
    case 'ID': return AppLocalizationsIdId();
   }
  break;
   }
    case 'zh': {
  switch (locale.countryCode) {
    case 'CN': return AppLocalizationsZhCn();
case 'TW': return AppLocalizationsZhTw();
   }
  break;
   }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'id': return AppLocalizationsId();
    case 'ja': return AppLocalizationsJa();
    case 'ko': return AppLocalizationsKo();
    case 'ru': return AppLocalizationsRu();
    case 'tr': return AppLocalizationsTr();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}

// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars

class I18n {
  I18n();
  
  static I18n current;
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<I18n> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      I18n.current = I18n();
      
      return I18n.current;
    });
  } 

  static I18n of(BuildContext context) {
    return Localizations.of<I18n>(context, I18n);
  }

  /// `About`
  String get About {
    return Intl.message(
      'About',
      name: 'About',
      desc: '',
      args: [],
    );
  }

  /// `Related illusts`
  String get About_Picture {
    return Intl.message(
      'Related illusts',
      name: 'About_Picture',
      desc: '',
      args: [],
    );
  }

  /// `Switch account`
  String get Account_change {
    return Intl.message(
      'Switch account',
      name: 'Account_change',
      desc: '',
      args: [],
    );
  }

  /// `Account info`
  String get Account_Message {
    return Intl.message(
      'Account info',
      name: 'Account_Message',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get All {
    return Intl.message(
      'All',
      name: 'All',
      desc: '',
      args: [],
    );
  }

  /// `Already in queue`
  String get Already_in_query {
    return Intl.message(
      'Already in queue',
      name: 'Already_in_query',
      desc: '',
      args: [],
    );
  }

  /// `Already saved`
  String get Already_Saved {
    return Intl.message(
      'Already saved',
      name: 'Already_Saved',
      desc: '',
      args: [],
    );
  }

  /// `Android special setting`
  String get Android_Special_Setting {
    return Intl.message(
      'Android special setting',
      name: 'Android_Special_Setting',
      desc: '',
      args: [],
    );
  }

  /// `Appended to queue`
  String get Append_to_query {
    return Intl.message(
      'Appended to queue',
      name: 'Append_to_query',
      desc: '',
      args: [],
    );
  }

  /// `Apply`
  String get Apply {
    return Intl.message(
      'Apply',
      name: 'Apply',
      desc: '',
      args: [],
    );
  }

  /// `Mute`
  String get Ban {
    return Intl.message(
      'Mute',
      name: 'Ban',
      desc: '',
      args: [],
    );
  }

  /// `Birthday`
  String get birthday {
    return Intl.message(
      'Birthday',
      name: 'birthday',
      desc: '',
      args: [],
    );
  }

  /// `Collections`
  String get BookMark {
    return Intl.message(
      'Collections',
      name: 'BookMark',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get Cancel {
    return Intl.message(
      'Cancel',
      name: 'Cancel',
      desc: '',
      args: [],
    );
  }

  /// `Tags will be showing`
  String get Choice_you_like {
    return Intl.message(
      'Tags will be showing',
      name: 'Choice_you_like',
      desc: '',
      args: [],
    );
  }

  /// `Select folder`
  String get Choose_directory {
    return Intl.message(
      'Select folder',
      name: 'Choose_directory',
      desc: '',
      args: [],
    );
  }

  /// `Clear`
  String get Clear {
    return Intl.message(
      'Clear',
      name: 'Clear',
      desc: '',
      args: [],
    );
  }

  /// `Clear cache`
  String get Clearn_cache {
    return Intl.message(
      'Clear cache',
      name: 'Clearn_cache',
      desc: '',
      args: [],
    );
  }

  /// `Try this when you have problems while playing gifs`
  String get Clearn_cache_hint {
    return Intl.message(
      'Try this when you have problems while playing gifs',
      name: 'Clearn_cache_hint',
      desc: '',
      args: [],
    );
  }

  /// `Older`
  String get date_asc {
    return Intl.message(
      'Older',
      name: 'date_asc',
      desc: '',
      args: [],
    );
  }

  /// `Newer`
  String get date_desc {
    return Intl.message(
      'Newer',
      name: 'date_desc',
      desc: '',
      args: [],
    );
  }

  /// `Date range`
  String get Date_duration {
    return Intl.message(
      'Date range',
      name: 'Date_duration',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get Delete {
    return Intl.message(
      'Delete',
      name: 'Delete',
      desc: '',
      args: [],
    );
  }

  /// `User info`
  String get Detail {
    return Intl.message(
      'User info',
      name: 'Detail',
      desc: '',
      args: [],
    );
  }

  /// `Buy me a coffee`
  String get Donation {
    return Intl.message(
      'Buy me a coffee',
      name: 'Donation',
      desc: '',
      args: [],
    );
  }

  /// `Don't have an account?`
  String get Dont_have_account {
    return Intl.message(
      'Don\'t have an account?',
      name: 'Dont_have_account',
      desc: '',
      args: [],
    );
  }

  /// `Tag perfect match`
  String get Exact_Match_for_tag {
    return Intl.message(
      'Tag perfect match',
      name: 'Exact_Match_for_tag',
      desc: '',
      args: [],
    );
  }

  /// `Feedback`
  String get FeedBack {
    return Intl.message(
      'Feedback',
      name: 'FeedBack',
      desc: '',
      args: [],
    );
  }

  /// `Follow`
  String get Follow {
    return Intl.message(
      'Follow',
      name: 'Follow',
      desc: '',
      args: [],
    );
  }

  /// `Format`
  String get Format {
    return Intl.message(
      'Format',
      name: 'Format',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get Go_to_Login {
    return Intl.message(
      'Login',
      name: 'Go_to_Login',
      desc: '',
      args: [],
    );
  }

  /// `History`
  String get History {
    return Intl.message(
      'History',
      name: 'History',
      desc: '',
      args: [],
    );
  }

  /// `Browsing history`
  String get History_record {
    return Intl.message(
      'Browsing history',
      name: 'History_record',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get Home {
    return Intl.message(
      'Home',
      name: 'Home',
      desc: '',
      args: [],
    );
  }

  /// `Illust`
  String get Illust {
    return Intl.message(
      'Illust',
      name: 'Illust',
      desc: '',
      args: [],
    );
  }

  /// `Illust ID`
  String get Illust_id {
    return Intl.message(
      'Illust ID',
      name: 'Illust_id',
      desc: '',
      args: [],
    );
  }

  /// `Enter nickname`
  String get Input_Nickname {
    return Intl.message(
      'Enter nickname',
      name: 'Input_Nickname',
      desc: '',
      args: [],
    );
  }

  /// `Preview`
  String get Large {
    return Intl.message(
      'Preview',
      name: 'Large',
      desc: '',
      args: [],
    );
  }

  /// `Images loading quality`
  String get Large_preview_zoom_quality {
    return Intl.message(
      'Images loading quality',
      name: 'Large_preview_zoom_quality',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get Login {
    return Intl.message(
      'Login',
      name: 'Login',
      desc: '',
      args: [],
    );
  }

  /// `Enter dark side of the world`
  String get Login_message {
    return Intl.message(
      'Enter dark side of the world',
      name: 'Login_message',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get Logout {
    return Intl.message(
      'Logout',
      name: 'Logout',
      desc: '',
      args: [],
    );
  }

  /// `See you~`
  String get Logout_message {
    return Intl.message(
      'See you~',
      name: 'Logout_message',
      desc: '',
      args: [],
    );
  }

  /// `More`
  String get More {
    return Intl.message(
      'More',
      name: 'More',
      desc: '',
      args: [],
    );
  }

  /// `More than {starNum} likes`
  String More_then_starNum_Bookmark(Object starNum) {
    return Intl.message(
      'More than $starNum likes',
      name: 'More_then_starNum_Bookmark',
      desc: '',
      args: [starNum],
    );
  }

  /// `Save selected ones`
  String get Muti_Choice_save {
    return Intl.message(
      'Save selected ones',
      name: 'Muti_Choice_save',
      desc: '',
      args: [],
    );
  }

  /// `Mine`
  String get My {
    return Intl.message(
      'Mine',
      name: 'My',
      desc: '',
      args: [],
    );
  }

  /// `Activities`
  String get New {
    return Intl.message(
      'Activities',
      name: 'New',
      desc: '',
      args: [],
    );
  }

  /// `Nickname`
  String get Nickname {
    return Intl.message(
      'Nickname',
      name: 'Nickname',
      desc: '',
      args: [],
    );
  }

  /// `Nickname can be changed at any time`
  String get Nickname_can_be_change_anytime {
    return Intl.message(
      'Nickname can be changed at any time',
      name: 'Nickname_can_be_change_anytime',
      desc: '',
      args: [],
    );
  }

  /// `H are not allowed!`
  String get No_H {
    return Intl.message(
      'H are not allowed!',
      name: 'No_H',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get OK {
    return Intl.message(
      'Confirm',
      name: 'OK',
      desc: '',
      args: [],
    );
  }

  /// `User`
  String get Painter {
    return Intl.message(
      'User',
      name: 'Painter',
      desc: '',
      args: [],
    );
  }

  /// `User ID`
  String get Painter_id {
    return Intl.message(
      'User ID',
      name: 'Painter_id',
      desc: '',
      args: [],
    );
  }

  /// `User name`
  String get Painter_Name {
    return Intl.message(
      'User name',
      name: 'Painter_Name',
      desc: '',
      args: [],
    );
  }

  /// `Tag partial match`
  String get Partial_Match_for_tag {
    return Intl.message(
      'Tag partial match',
      name: 'Partial_Match_for_tag',
      desc: '',
      args: [],
    );
  }

  /// `Path`
  String get Path {
    return Intl.message(
      'Path',
      name: 'Path',
      desc: '',
      args: [],
    );
  }

  /// `Personal`
  String get Personal {
    return Intl.message(
      'Personal',
      name: 'Personal',
      desc: '',
      args: [],
    );
  }

  /// `Resolution`
  String get Pixel {
    return Intl.message(
      'Resolution',
      name: 'Pixel',
      desc: '',
      args: [],
    );
  }

  /// `Popular`
  String get popular_desc {
    return Intl.message(
      'Popular',
      name: 'popular_desc',
      desc: '',
      args: [],
    );
  }

  /// `Private`
  String get private {
    return Intl.message(
      'Private',
      name: 'private',
      desc: '',
      args: [],
    );
  }

  /// `Private`
  String get Private {
    return Intl.message(
      'Private',
      name: 'Private',
      desc: '',
      args: [],
    );
  }

  /// `Public`
  String get public {
    return Intl.message(
      'Public',
      name: 'public',
      desc: '',
      args: [],
    );
  }

  /// `Public`
  String get Public {
    return Intl.message(
      'Public',
      name: 'Public',
      desc: '',
      args: [],
    );
  }

  /// `Preferences`
  String get Quality_Setting {
    return Intl.message(
      'Preferences',
      name: 'Quality_Setting',
      desc: '',
      args: [],
    );
  }

  /// `Favorites`
  String get Quick_View {
    return Intl.message(
      'Favorites',
      name: 'Quick_View',
      desc: '',
      args: [],
    );
  }

  /// `Rankings`
  String get Rank {
    return Intl.message(
      'Rankings',
      name: 'Rank',
      desc: '',
      args: [],
    );
  }

  /// `Recommend tags`
  String get Recommand_Tag {
    return Intl.message(
      'Recommend tags',
      name: 'Recommand_Tag',
      desc: '',
      args: [],
    );
  }

  /// `Recommended`
  String get Recommend {
    return Intl.message(
      'Recommended',
      name: 'Recommend',
      desc: '',
      args: [],
    );
  }

  /// `For you`
  String get Recommend_for_you {
    return Intl.message(
      'For you',
      name: 'Recommend_for_you',
      desc: '',
      args: [],
    );
  }

  /// `Reply`
  String get Reply {
    return Intl.message(
      'Reply',
      name: 'Reply',
      desc: '',
      args: [],
    );
  }

  /// `Report`
  String get report {
    return Intl.message(
      'Report',
      name: 'report',
      desc: '',
      args: [],
    );
  }

  /// `Report this content if it makes you feel uncomfortable, we will remove it ASAP once we confirmed that it's harmful.`
  String get Report_Message {
    return Intl.message(
      'Report this content if it makes you feel uncomfortable, we will remove it ASAP once we confirmed that it\'s harmful.',
      name: 'Report_Message',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get Save {
    return Intl.message(
      'Save',
      name: 'Save',
      desc: '',
      args: [],
    );
  }

  /// `Saved`
  String get Saved {
    return Intl.message(
      'Saved',
      name: 'Saved',
      desc: '',
      args: [],
    );
  }

  /// `Naming format`
  String get Save_format {
    return Intl.message(
      'Naming format',
      name: 'Save_format',
      desc: '',
      args: [],
    );
  }

  /// `Save location`
  String get Save_path {
    return Intl.message(
      'Save location',
      name: 'Save_path',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get Search {
    return Intl.message(
      'Search',
      name: 'Search',
      desc: '',
      args: [],
    );
  }

  /// `Enter keywords or paste links`
  String get Search_word_or_paste_link {
    return Intl.message(
      'Enter keywords or paste links',
      name: 'Search_word_or_paste_link',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get Setting {
    return Intl.message(
      'Settings',
      name: 'Setting',
      desc: '',
      args: [],
    );
  }

  /// `Share`
  String get Share {
    return Intl.message(
      'Share',
      name: 'Share',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get Share_this_app_link {
    return Intl.message(
      '',
      name: 'Share_this_app_link',
      desc: '',
      args: [],
    );
  }

  /// `Mute settings`
  String get Shielding_settings {
    return Intl.message(
      'Mute settings',
      name: 'Shielding_settings',
      desc: '',
      args: [],
    );
  }

  /// `{name} has been muted by you`
  String Shield_message(Object name) {
    return Intl.message(
      '$name has been muted by you',
      name: 'Shield_message',
      desc: '',
      args: [name],
    );
  }

  /// `Skip`
  String get Skip {
    return Intl.message(
      'Skip',
      name: 'Skip',
      desc: '',
      args: [],
    );
  }

  /// `Source`
  String get Source {
    return Intl.message(
      'Source',
      name: 'Source',
      desc: '',
      args: [],
    );
  }

  /// `Highlights`
  String get Spotlight {
    return Intl.message(
      'Highlights',
      name: 'Spotlight',
      desc: '',
      args: [],
    );
  }

  /// `Support`
  String get Support {
    return Intl.message(
      'Support',
      name: 'Support',
      desc: '',
      args: [],
    );
  }

  /// `Tag`
  String get Tag {
    return Intl.message(
      'Tag',
      name: 'Tag',
      desc: '',
      args: [],
    );
  }

  /// `Task progress`
  String get Task_progress {
    return Intl.message(
      'Task progress',
      name: 'Task_progress',
      desc: '',
      args: [],
    );
  }

  /// `Terms of use`
  String get Terms {
    return Intl.message(
      'Terms of use',
      name: 'Terms',
      desc: '',
      args: [],
    );
  }

  /// `Thanks`
  String get Thanks {
    return Intl.message(
      'Thanks',
      name: 'Thanks',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get Theme {
    return Intl.message(
      'Theme',
      name: 'Theme',
      desc: '',
      args: [],
    );
  }

  /// `Title`
  String get Title {
    return Intl.message(
      'Title',
      name: 'Title',
      desc: '',
      args: [],
    );
  }

  /// `Title and description`
  String get title_and_caption {
    return Intl.message(
      'Title and description',
      name: 'title_and_caption',
      desc: '',
      args: [],
    );
  }

  /// `Total likes`
  String get total_bookmark {
    return Intl.message(
      'Total likes',
      name: 'total_bookmark',
      desc: '',
      args: [],
    );
  }

  /// `Likes`
  String get Total_bookmark {
    return Intl.message(
      'Likes',
      name: 'Total_bookmark',
      desc: '',
      args: [],
    );
  }

  /// `Total viewers`
  String get total_view {
    return Intl.message(
      'Total viewers',
      name: 'total_view',
      desc: '',
      args: [],
    );
  }

  /// `Viewers`
  String get Total_view {
    return Intl.message(
      'Viewers',
      name: 'Total_view',
      desc: '',
      args: [],
    );
  }

  /// `Not following`
  String get Un_Follow {
    return Intl.message(
      'Not following',
      name: 'Un_Follow',
      desc: '',
      args: [],
    );
  }

  /// `View comments`
  String get View_Comment {
    return Intl.message(
      'View comments',
      name: 'View_Comment',
      desc: '',
      args: [],
    );
  }

  /// `Clear all cache?`
  String get Warning {
    return Intl.message(
      'Clear all cache?',
      name: 'Warning',
      desc: '',
      args: [],
    );
  }

  /// `Index`
  String get Which_part {
    return Intl.message(
      'Index',
      name: 'Which_part',
      desc: '',
      args: [],
    );
  }

  /// `Works`
  String get Works {
    return Intl.message(
      'Works',
      name: 'Works',
      desc: '',
      args: [],
    );
  }

  /// `Daily For_male For_female Original Rookie Weekly Monthly XVIII XVIII_WEEKLY XVIII_G`
  String get Mode_List {
    return Intl.message(
      'Daily For_male For_female Original Rookie Weekly Monthly XVIII XVIII_WEEKLY XVIII_G',
      name: 'Mode_List',
      desc: '',
      args: [],
    );
  }

  /// `Copy illust info`
  String get CopyMessage {
    return Intl.message(
      'Copy illust info',
      name: 'CopyMessage',
      desc: '',
      args: [],
    );
  }

  /// `Following`
  String get Followed {
    return Intl.message(
      'Following',
      name: 'Followed',
      desc: '',
      args: [],
    );
  }

  /// `Manga`
  String get Manga {
    return Intl.message(
      'Manga',
      name: 'Manga',
      desc: '',
      args: [],
    );
  }

  /// `Follow privately`
  String get Quietly_Follow {
    return Intl.message(
      'Follow privately',
      name: 'Quietly_Follow',
      desc: '',
      args: [],
    );
  }

  /// `Mute this user`
  String get Block_User {
    return Intl.message(
      'Mute this user',
      name: 'Block_User',
      desc: '',
      args: [],
    );
  }

  /// `Separate folders`
  String get Separate_Folder {
    return Intl.message(
      'Separate folders',
      name: 'Separate_Folder',
      desc: '',
      args: [],
    );
  }

  /// `Create separate folders for each user`
  String get Separate_Folder_Message {
    return Intl.message(
      'Create separate folders for each user',
      name: 'Separate_Folder_Message',
      desc: '',
      args: [],
    );
  }

  /// `Current password`
  String get Current_Password {
    return Intl.message(
      'Current password',
      name: 'Current_Password',
      desc: '',
      args: [],
    );
  }

  /// `New password`
  String get New_Password {
    return Intl.message(
      'New password',
      name: 'New_Password',
      desc: '',
      args: [],
    );
  }

  /// `Keywords`
  String get Key_Word {
    return Intl.message(
      'Keywords',
      name: 'Key_Word',
      desc: '',
      args: [],
    );
  }

  /// `Copied to clipboard`
  String get Copied_To_Clipboard {
    return Intl.message(
      'Copied to clipboard',
      name: 'Copied_To_Clipboard',
      desc: '',
      args: [],
    );
  }

  /// `Display mode`
  String get Display_Mode {
    return Intl.message(
      'Display mode',
      name: 'Display_Mode',
      desc: '',
      args: [],
    );
  }

  /// `Select display mode (experimental)`
  String get Display_Mode_Message {
    return Intl.message(
      'Select display mode (experimental)',
      name: 'Display_Mode_Message',
      desc: '',
      args: [],
    );
  }

  /// `It is intended to solve the problem of some whitelist mechanisms that support high refresh rate models. If there is no problem, please do not change it at will`
  String get Display_Mode_Warning {
    return Intl.message(
      'It is intended to solve the problem of some whitelist mechanisms that support high refresh rate models. If there is no problem, please do not change it at will',
      name: 'Display_Mode_Warning',
      desc: '',
      args: [],
    );
  }

  /// `Unsaved`
  String get Unsaved {
    return Intl.message(
      'Unsaved',
      name: 'Unsaved',
      desc: '',
      args: [],
    );
  }

  /// `Latest version`
  String get Latest_Version {
    return Intl.message(
      'Latest version',
      name: 'Latest_Version',
      desc: '',
      args: [],
    );
  }

  /// `Download address`
  String get Download_Address {
    return Intl.message(
      'Download address',
      name: 'Download_Address',
      desc: '',
      args: [],
    );
  }

  /// `New version update information`
  String get New_Version_Update_Information {
    return Intl.message(
      'New version update information',
      name: 'New_Version_Update_Information',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get Update {
    return Intl.message(
      'Update',
      name: 'Update',
      desc: '',
      args: [],
    );
  }

  /// `Check for updates`
  String get Check_For_Updates {
    return Intl.message(
      'Check for updates',
      name: 'Check_For_Updates',
      desc: '',
      args: [],
    );
  }

  /// `Please note that`
  String get Please_Note_That {
    return Intl.message(
      'Please note that',
      name: 'Please_Note_That',
      desc: '',
      args: [],
    );
  }

  /// `Only when you make sure that your agent or area can access pixiv, you can turn on this switch. After the switch is turned on, all network problems have nothing to do with the application. Don't feed back the problem that you can't connect`
  String get Please_Note_That_Content {
    return Intl.message(
      'Only when you make sure that your agent or area can access pixiv, you can turn on this switch. After the switch is turned on, all network problems have nothing to do with the application. Don\'t feed back the problem that you can\'t connect',
      name: 'Please_Note_That_Content',
      desc: '',
      args: [],
    );
  }

  /// `Disable Sni Bypass`
  String get Disable_Sni_Bypass {
    return Intl.message(
      'Disable Sni Bypass',
      name: 'Disable_Sni_Bypass',
      desc: '',
      args: [],
    );
  }

  /// `Save time of DNS over HTTPS during cold start`
  String get Disable_Sni_Bypass_Message {
    return Intl.message(
      'Save time of DNS over HTTPS during cold start',
      name: 'Disable_Sni_Bypass_Message',
      desc: '',
      args: [],
    );
  }

  /// `Go to project address`
  String get Go_To_Project_Address {
    return Intl.message(
      'Go to project address',
      name: 'Go_To_Project_Address',
      desc: '',
      args: [],
    );
  }

  /// `Welcome Page`
  String get Welcome_Page {
    return Intl.message(
      'Welcome Page',
      name: 'Welcome_Page',
      desc: '',
      args: [],
    );
  }

  /// `Encode`
  String get Encode {
    return Intl.message(
      'Encode',
      name: 'Encode',
      desc: '',
      args: [],
    );
  }

  /// `This will take time and may fail`
  String get Encode_Message {
    return Intl.message(
      'This will take time and may fail',
      name: 'Encode_Message',
      desc: '',
      args: [],
    );
  }

  /// `Filter`
  String get Filter {
    return Intl.message(
      'Filter',
      name: 'Filter',
      desc: '',
      args: [],
    );
  }

  /// `Attempting to log in`
  String get Attempting_To_Log_In {
    return Intl.message(
      'Attempting to log in',
      name: 'Attempting_To_Log_In',
      desc: '',
      args: [],
    );
  }

  /// `Bookmarked`
  String get Bookmarked {
    return Intl.message(
      'Bookmarked',
      name: 'Bookmarked',
      desc: '',
      args: [],
    );
  }

  /// `Not_Bookmarked`
  String get Not_Bookmarked {
    return Intl.message(
      'Not_Bookmarked',
      name: 'Not_Bookmarked',
      desc: '',
      args: [],
    );
  }

  /// `Total follow users`
  String get Total_Follow_Users {
    return Intl.message(
      'Total follow users',
      name: 'Total_Follow_Users',
      desc: '',
      args: [],
    );
  }

  /// `Total mypixiv users`
  String get Total_Mypixiv_Users {
    return Intl.message(
      'Total mypixiv users',
      name: 'Total_Mypixiv_Users',
      desc: '',
      args: [],
    );
  }

  /// `Twitter account`
  String get Twitter_Account {
    return Intl.message(
      'Twitter account',
      name: 'Twitter_Account',
      desc: '',
      args: [],
    );
  }

  /// `Gender`
  String get Gender {
    return Intl.message(
      'Gender',
      name: 'Gender',
      desc: '',
      args: [],
    );
  }

  /// `Job`
  String get Job {
    return Intl.message(
      'Job',
      name: 'Job',
      desc: '',
      args: [],
    );
  }

  /// `Clear all cache`
  String get Clear_All_Cache {
    return Intl.message(
      'Clear all cache',
      name: 'Clear_All_Cache',
      desc: '',
      args: [],
    );
  }

  /// `Undefined`
  String get Undefined {
    return Intl.message(
      'Undefined',
      name: 'Undefined',
      desc: '',
      args: [],
    );
  }

  /// `Enqueued`
  String get Enqueued {
    return Intl.message(
      'Enqueued',
      name: 'Enqueued',
      desc: '',
      args: [],
    );
  }

  /// `Running`
  String get Running {
    return Intl.message(
      'Running',
      name: 'Running',
      desc: '',
      args: [],
    );
  }

  /// `Complete`
  String get Complete {
    return Intl.message(
      'Complete',
      name: 'Complete',
      desc: '',
      args: [],
    );
  }

  /// `Failed`
  String get Failed {
    return Intl.message(
      'Failed',
      name: 'Failed',
      desc: '',
      args: [],
    );
  }

  /// `Canceled`
  String get Canceled {
    return Intl.message(
      'Canceled',
      name: 'Canceled',
      desc: '',
      args: [],
    );
  }

  /// `Paused`
  String get Paused {
    return Intl.message(
      'Paused',
      name: 'Paused',
      desc: '',
      args: [],
    );
  }

  /// `Pull up to load more`
  String get Pull_Up_To_Load_More {
    return Intl.message(
      'Pull up to load more',
      name: 'Pull_Up_To_Load_More',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load. Click to try again`
  String get Loading_Failed_Retry_Message {
    return Intl.message(
      'Failed to load. Click to try again',
      name: 'Loading_Failed_Retry_Message',
      desc: '',
      args: [],
    );
  }

  /// `Let go and load more`
  String get Let_Go_And_Load_More {
    return Intl.message(
      'Let go and load more',
      name: 'Let_Go_And_Load_More',
      desc: '',
      args: [],
    );
  }

  /// `There is no more data`
  String get No_More_Data {
    return Intl.message(
      'There is no more data',
      name: 'No_More_Data',
      desc: '',
      args: [],
    );
  }

  /// `Retry failed tasks`
  String get Retry_Failed_Tasks {
    return Intl.message(
      'Retry failed tasks',
      name: 'Retry_Failed_Tasks',
      desc: '',
      args: [],
    );
  }

  /// `Clear completed tasks`
  String get Clear_Completed_Tasks {
    return Intl.message(
      'Clear completed tasks',
      name: 'Clear_Completed_Tasks',
      desc: '',
      args: [],
    );
  }

  /// `Crosscount`
  String get Crosscount {
    return Intl.message(
      'Crosscount',
      name: 'Crosscount',
      desc: '',
      args: [],
    );
  }

  /// `Need to restart app`
  String get Need_To_Restart_App {
    return Intl.message(
      'Need to restart app',
      name: 'Need_To_Restart_App',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get refresh {
    return Intl.message(
      'Refresh',
      name: 'refresh',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get Retry {
    return Intl.message(
      'Retry',
      name: 'Retry',
      desc: '',
      args: [],
    );
  }

  /// `load image failed, click to reload`
  String get LoadImageFailedClickToReload {
    return Intl.message(
      'load image failed, click to reload',
      name: 'LoadImageFailedClickToReload',
      desc: '',
      args: [],
    );
  }

  /// `中等`
  String get medium {
    return Intl.message(
      '中等',
      name: 'medium',
      desc: '',
      args: [],
    );
  }

  /// `Illust detail page quality`
  String get Illustration_detail_page_quality {
    return Intl.message(
      'Illust detail page quality',
      name: 'Illustration_detail_page_quality',
      desc: '',
      args: [],
    );
  }

  /// `Skin`
  String get skin {
    return Intl.message(
      'Skin',
      name: 'skin',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<I18n> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'CN'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'TW'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<I18n> load(Locale locale) => I18n.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}
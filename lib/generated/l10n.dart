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
  String get about {
    return Intl.message(
      'About',
      name: 'about',
      desc: '',
      args: [],
    );
  }

  /// `Related illusts`
  String get about_picture {
    return Intl.message(
      'Related illusts',
      name: 'about_picture',
      desc: '',
      args: [],
    );
  }

  /// `Switch account`
  String get account_change {
    return Intl.message(
      'Switch account',
      name: 'account_change',
      desc: '',
      args: [],
    );
  }

  /// `Account info`
  String get account_message {
    return Intl.message(
      'Account info',
      name: 'account_message',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get all {
    return Intl.message(
      'All',
      name: 'all',
      desc: '',
      args: [],
    );
  }

  /// `Already in queue`
  String get already_in_query {
    return Intl.message(
      'Already in queue',
      name: 'already_in_query',
      desc: '',
      args: [],
    );
  }

  /// `Already saved`
  String get already_saved {
    return Intl.message(
      'Already saved',
      name: 'already_saved',
      desc: '',
      args: [],
    );
  }

  /// `Android-specific Settings`
  String get android_special_setting {
    return Intl.message(
      'Android-specific Settings',
      name: 'android_special_setting',
      desc: '',
      args: [],
    );
  }

  /// `Added to queue`
  String get append_to_query {
    return Intl.message(
      'Added to queue',
      name: 'append_to_query',
      desc: '',
      args: [],
    );
  }

  /// `Apply`
  String get apply {
    return Intl.message(
      'Apply',
      name: 'apply',
      desc: '',
      args: [],
    );
  }

  /// `Logging in`
  String get attempting_to_log_in {
    return Intl.message(
      'Logging in',
      name: 'attempting_to_log_in',
      desc: '',
      args: [],
    );
  }

  /// `Mute`
  String get ban {
    return Intl.message(
      'Mute',
      name: 'ban',
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

  /// `Mute this user`
  String get block_user {
    return Intl.message(
      'Mute this user',
      name: 'block_user',
      desc: '',
      args: [],
    );
  }

  /// `Collections`
  String get bookmark {
    return Intl.message(
      'Collections',
      name: 'bookmark',
      desc: '',
      args: [],
    );
  }

  /// `Bookmarked`
  String get bookmarked {
    return Intl.message(
      'Bookmarked',
      name: 'bookmarked',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Cancelled`
  String get canceled {
    return Intl.message(
      'Cancelled',
      name: 'canceled',
      desc: '',
      args: [],
    );
  }

  /// `Check for updates`
  String get check_for_updates {
    return Intl.message(
      'Check for updates',
      name: 'check_for_updates',
      desc: '',
      args: [],
    );
  }

  /// `Visible tags`
  String get choice_you_like {
    return Intl.message(
      'Visible tags',
      name: 'choice_you_like',
      desc: '',
      args: [],
    );
  }

  /// `Select folder`
  String get choose_directory {
    return Intl.message(
      'Select folder',
      name: 'choose_directory',
      desc: '',
      args: [],
    );
  }

  /// `Clear`
  String get clear {
    return Intl.message(
      'Clear',
      name: 'clear',
      desc: '',
      args: [],
    );
  }

  /// `Clear all cache`
  String get clear_all_cache {
    return Intl.message(
      'Clear all cache',
      name: 'clear_all_cache',
      desc: '',
      args: [],
    );
  }

  /// `Clear completed tasks`
  String get clear_completed_tasks {
    return Intl.message(
      'Clear completed tasks',
      name: 'clear_completed_tasks',
      desc: '',
      args: [],
    );
  }

  /// `Clear cache`
  String get clearn_cache {
    return Intl.message(
      'Clear cache',
      name: 'clearn_cache',
      desc: '',
      args: [],
    );
  }

  /// `Try this when you have problems with playing GIFs`
  String get clearn_cache_hint {
    return Intl.message(
      'Try this when you have problems with playing GIFs',
      name: 'clearn_cache_hint',
      desc: '',
      args: [],
    );
  }

  /// `Complete`
  String get complete {
    return Intl.message(
      'Complete',
      name: 'complete',
      desc: '',
      args: [],
    );
  }

  /// `Copied to clipboard`
  String get copied_to_clipboard {
    return Intl.message(
      'Copied to clipboard',
      name: 'copied_to_clipboard',
      desc: '',
      args: [],
    );
  }

  /// `Copy illust info`
  String get copymessage {
    return Intl.message(
      'Copy illust info',
      name: 'copymessage',
      desc: '',
      args: [],
    );
  }

  /// `Number of illusts per page`
  String get crosscount {
    return Intl.message(
      'Number of illusts per page',
      name: 'crosscount',
      desc: '',
      args: [],
    );
  }

  /// `Current password`
  String get current_password {
    return Intl.message(
      'Current password',
      name: 'current_password',
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
  String get date_duration {
    return Intl.message(
      'Date range',
      name: 'date_duration',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `User info`
  String get detail {
    return Intl.message(
      'User info',
      name: 'detail',
      desc: '',
      args: [],
    );
  }

  /// `Disable SNI Bypassing`
  String get disable_sni_bypass {
    return Intl.message(
      'Disable SNI Bypassing',
      name: 'disable_sni_bypass',
      desc: '',
      args: [],
    );
  }

  /// `Decreases DoH time on startup`
  String get disable_sni_bypass_message {
    return Intl.message(
      'Decreases DoH time on startup',
      name: 'disable_sni_bypass_message',
      desc: '',
      args: [],
    );
  }

  /// `Display refresh rate`
  String get display_mode {
    return Intl.message(
      'Display refresh rate',
      name: 'display_mode',
      desc: '',
      args: [],
    );
  }

  /// `Select refresh rate (experimental)`
  String get display_mode_message {
    return Intl.message(
      'Select refresh rate (experimental)',
      name: 'display_mode_message',
      desc: '',
      args: [],
    );
  }

  /// `Do not change it unless your device supports it.`
  String get display_mode_warning {
    return Intl.message(
      'Do not change it unless your device supports it.',
      name: 'display_mode_warning',
      desc: '',
      args: [],
    );
  }

  /// `Thank you!`
  String get donate_message {
    return Intl.message(
      'Thank you!',
      name: 'donate_message',
      desc: '',
      args: [],
    );
  }

  /// `Buy me a coffee`
  String get donate_title {
    return Intl.message(
      'Buy me a coffee',
      name: 'donate_title',
      desc: '',
      args: [],
    );
  }

  /// `Buy me a coffee`
  String get donation {
    return Intl.message(
      'Buy me a coffee',
      name: 'donation',
      desc: '',
      args: [],
    );
  }

  /// `Don't have an account yet?`
  String get dont_have_account {
    return Intl.message(
      'Don\'t have an account yet?',
      name: 'dont_have_account',
      desc: '',
      args: [],
    );
  }

  /// `Download link`
  String get download_address {
    return Intl.message(
      'Download link',
      name: 'download_address',
      desc: '',
      args: [],
    );
  }

  /// `Encoding`
  String get encode {
    return Intl.message(
      'Encoding',
      name: 'encode',
      desc: '',
      args: [],
    );
  }

  /// `This may take some time and might fail`
  String get encode_message {
    return Intl.message(
      'This may take some time and might fail',
      name: 'encode_message',
      desc: '',
      args: [],
    );
  }

  /// `Enqueued`
  String get enqueued {
    return Intl.message(
      'Enqueued',
      name: 'enqueued',
      desc: '',
      args: [],
    );
  }

  /// `Tag exact matches`
  String get exact_match_for_tag {
    return Intl.message(
      'Tag exact matches',
      name: 'exact_match_for_tag',
      desc: '',
      args: [],
    );
  }

  /// `Failed`
  String get failed {
    return Intl.message(
      'Failed',
      name: 'failed',
      desc: '',
      args: [],
    );
  }

  /// `Feedback`
  String get feedback {
    return Intl.message(
      'Feedback',
      name: 'feedback',
      desc: '',
      args: [],
    );
  }

  /// `Filter`
  String get filter {
    return Intl.message(
      'Filter',
      name: 'filter',
      desc: '',
      args: [],
    );
  }

  /// `Follow`
  String get follow {
    return Intl.message(
      'Follow',
      name: 'follow',
      desc: '',
      args: [],
    );
  }

  /// `Following`
  String get followed {
    return Intl.message(
      'Following',
      name: 'followed',
      desc: '',
      args: [],
    );
  }

  /// `Format`
  String get format {
    return Intl.message(
      'Format',
      name: 'format',
      desc: '',
      args: [],
    );
  }

  /// `Gender`
  String get gender {
    return Intl.message(
      'Gender',
      name: 'gender',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get go_to_login {
    return Intl.message(
      'Login',
      name: 'go_to_login',
      desc: '',
      args: [],
    );
  }

  /// `Go to GitHub repo`
  String get go_to_project_address {
    return Intl.message(
      'Go to GitHub repo',
      name: 'go_to_project_address',
      desc: '',
      args: [],
    );
  }

  /// `History`
  String get history {
    return Intl.message(
      'History',
      name: 'history',
      desc: '',
      args: [],
    );
  }

  /// `Browsing history`
  String get history_record {
    return Intl.message(
      'Browsing history',
      name: 'history_record',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message(
      'Home',
      name: 'home',
      desc: '',
      args: [],
    );
  }

  /// `Illust`
  String get illust {
    return Intl.message(
      'Illust',
      name: 'illust',
      desc: '',
      args: [],
    );
  }

  /// `Illust ID`
  String get illust_id {
    return Intl.message(
      'Illust ID',
      name: 'illust_id',
      desc: '',
      args: [],
    );
  }

  /// `Image quality (Details page)`
  String get illustration_detail_page_quality {
    return Intl.message(
      'Image quality (Details page)',
      name: 'illustration_detail_page_quality',
      desc: '',
      args: [],
    );
  }

  /// `Enter nickname`
  String get input_nickname {
    return Intl.message(
      'Enter nickname',
      name: 'input_nickname',
      desc: '',
      args: [],
    );
  }

  /// `Job`
  String get job {
    return Intl.message(
      'Job',
      name: 'job',
      desc: '',
      args: [],
    );
  }

  /// `Keywords`
  String get key_word {
    return Intl.message(
      'Keywords',
      name: 'key_word',
      desc: '',
      args: [],
    );
  }

  /// `High`
  String get large {
    return Intl.message(
      'High',
      name: 'large',
      desc: '',
      args: [],
    );
  }

  /// `Image quality (Fullscreen)`
  String get large_preview_zoom_quality {
    return Intl.message(
      'Image quality (Fullscreen)',
      name: 'large_preview_zoom_quality',
      desc: '',
      args: [],
    );
  }

  /// `Latest version`
  String get latest_version {
    return Intl.message(
      'Latest version',
      name: 'latest_version',
      desc: '',
      args: [],
    );
  }

  /// `Release to load more`
  String get let_go_and_load_more {
    return Intl.message(
      'Release to load more',
      name: 'let_go_and_load_more',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load. Click to retry`
  String get load_image_failed_click_to_reload {
    return Intl.message(
      'Failed to load. Click to retry',
      name: 'load_image_failed_click_to_reload',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load. Click to retry`
  String get loading_failed_retry_message {
    return Intl.message(
      'Failed to load. Click to retry',
      name: 'loading_failed_retry_message',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Discover a whole new world`
  String get login_message {
    return Intl.message(
      'Discover a whole new world',
      name: 'login_message',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message(
      'Logout',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `This will clear account info and return to Login page.`
  String get logout_message {
    return Intl.message(
      'This will clear account info and return to Login page.',
      name: 'logout_message',
      desc: '',
      args: [],
    );
  }

  /// `Manga`
  String get manga {
    return Intl.message(
      'Manga',
      name: 'manga',
      desc: '',
      args: [],
    );
  }

  /// `Medium`
  String get medium {
    return Intl.message(
      'Medium',
      name: 'medium',
      desc: '',
      args: [],
    );
  }

  /// `Daily For_male For_female Original Rookie Weekly Monthly XVIII XVIII_WEEKLY XVIII_G`
  String get mode_list {
    return Intl.message(
      'Daily For_male For_female Original Rookie Weekly Monthly XVIII XVIII_WEEKLY XVIII_G',
      name: 'mode_list',
      desc: '',
      args: [],
    );
  }

  /// `Daily For_male For_female Weekly XVIII XVIII_WEEKLY XVIII_G`
  String get novel_mode_list {
    return Intl.message(
      'Daily For_male For_female Weekly XVIII XVIII_WEEKLY XVIII_G',
      name: 'novel_mode_list',
      desc: '',
      args: [],
    );
  }

  /// `More`
  String get more {
    return Intl.message(
      'More',
      name: 'more',
      desc: '',
      args: [],
    );
  }

  /// `More than {starNum} like(s)`
  String more_then_starnum_bookmark(Object starNum) {
    return Intl.message(
      'More than $starNum like(s)',
      name: 'more_then_starnum_bookmark',
      desc: '',
      args: [starNum],
    );
  }

  /// `Save selected`
  String get muti_choice_save {
    return Intl.message(
      'Save selected',
      name: 'muti_choice_save',
      desc: '',
      args: [],
    );
  }

  /// `Mine`
  String get my {
    return Intl.message(
      'Mine',
      name: 'my',
      desc: '',
      args: [],
    );
  }

  /// `Restart required`
  String get need_to_restart_app {
    return Intl.message(
      'Restart required',
      name: 'need_to_restart_app',
      desc: '',
      args: [],
    );
  }

  /// `Activities`
  String get news {
    return Intl.message(
      'Activities',
      name: 'news',
      desc: '',
      args: [],
    );
  }

  /// `New password`
  String get new_password {
    return Intl.message(
      'New password',
      name: 'new_password',
      desc: '',
      args: [],
    );
  }

  /// `Changelog`
  String get new_version_update_information {
    return Intl.message(
      'Changelog',
      name: 'new_version_update_information',
      desc: '',
      args: [],
    );
  }

  /// `Nickname`
  String get nickname {
    return Intl.message(
      'Nickname',
      name: 'nickname',
      desc: '',
      args: [],
    );
  }

  /// `Nickname can be changed anytime`
  String get nickname_can_be_change_anytime {
    return Intl.message(
      'Nickname can be changed anytime',
      name: 'nickname_can_be_change_anytime',
      desc: '',
      args: [],
    );
  }

  /// `H is not allowed!`
  String get no_h {
    return Intl.message(
      'H is not allowed!',
      name: 'no_h',
      desc: '',
      args: [],
    );
  }

  /// `No more data`
  String get no_more_data {
    return Intl.message(
      'No more data',
      name: 'no_more_data',
      desc: '',
      args: [],
    );
  }

  /// `Not bookmarked`
  String get not_bookmarked {
    return Intl.message(
      'Not bookmarked',
      name: 'not_bookmarked',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `User`
  String get painter {
    return Intl.message(
      'User',
      name: 'painter',
      desc: '',
      args: [],
    );
  }

  /// `User ID`
  String get painter_id {
    return Intl.message(
      'User ID',
      name: 'painter_id',
      desc: '',
      args: [],
    );
  }

  /// `User name`
  String get painter_name {
    return Intl.message(
      'User name',
      name: 'painter_name',
      desc: '',
      args: [],
    );
  }

  /// `Tag partial matches`
  String get partial_match_for_tag {
    return Intl.message(
      'Tag partial matches',
      name: 'partial_match_for_tag',
      desc: '',
      args: [],
    );
  }

  /// `Path`
  String get path {
    return Intl.message(
      'Path',
      name: 'path',
      desc: '',
      args: [],
    );
  }

  /// `Paused`
  String get paused {
    return Intl.message(
      'Paused',
      name: 'paused',
      desc: '',
      args: [],
    );
  }

  /// `Author of the project. Built with Flutter.`
  String get perol_message {
    return Intl.message(
      'Author of the project. Built with Flutter.',
      name: 'perol_message',
      desc: '',
      args: [],
    );
  }

  /// `Personal`
  String get personal {
    return Intl.message(
      'Personal',
      name: 'personal',
      desc: '',
      args: [],
    );
  }

  /// `Resolution`
  String get pixel {
    return Intl.message(
      'Resolution',
      name: 'pixel',
      desc: '',
      args: [],
    );
  }

  /// `Notice`
  String get please_note_that {
    return Intl.message(
      'Notice',
      name: 'please_note_that',
      desc: '',
      args: [],
    );
  }

  /// `This option should be ON unless you are able to access pixiv.net without any issue.`
  String get please_note_that_content {
    return Intl.message(
      'This option should be ON unless you are able to access pixiv.net without any issue.',
      name: 'please_note_that_content',
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

  /// `Public`
  String get public {
    return Intl.message(
      'Public',
      name: 'public',
      desc: '',
      args: [],
    );
  }

  /// `Swipe up to load more`
  String get pull_up_to_load_more {
    return Intl.message(
      'Swipe up to load more',
      name: 'pull_up_to_load_more',
      desc: '',
      args: [],
    );
  }

  /// `Preferences`
  String get quality_setting {
    return Intl.message(
      'Preferences',
      name: 'quality_setting',
      desc: '',
      args: [],
    );
  }

  /// `Favorites`
  String get quick_view {
    return Intl.message(
      'Favorites',
      name: 'quick_view',
      desc: '',
      args: [],
    );
  }

  /// `Follow privately`
  String get quietly_follow {
    return Intl.message(
      'Follow privately',
      name: 'quietly_follow',
      desc: '',
      args: [],
    );
  }

  /// `Rankings`
  String get rank {
    return Intl.message(
      'Rankings',
      name: 'rank',
      desc: '',
      args: [],
    );
  }

  /// `Please give us 5 stars!`
  String get rate_message {
    return Intl.message(
      'Please give us 5 stars!',
      name: 'rate_message',
      desc: '',
      args: [],
    );
  }

  /// `If you think that PixEz is awesome, please give us a 5-star rating!`
  String get rate_title {
    return Intl.message(
      'If you think that PixEz is awesome, please give us a 5-star rating!',
      name: 'rate_title',
      desc: '',
      args: [],
    );
  }

  /// `Recommended tags`
  String get recommand_tag {
    return Intl.message(
      'Recommended tags',
      name: 'recommand_tag',
      desc: '',
      args: [],
    );
  }

  /// `Recommended`
  String get recommend {
    return Intl.message(
      'Recommended',
      name: 'recommend',
      desc: '',
      args: [],
    );
  }

  /// `For you`
  String get recommend_for_you {
    return Intl.message(
      'For you',
      name: 'recommend_for_you',
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

  /// `Reply`
  String get reply {
    return Intl.message(
      'Reply',
      name: 'reply',
      desc: '',
      args: [],
    );
  }

  /// `GitHub`
  String get repo_address {
    return Intl.message(
      'GitHub',
      name: 'repo_address',
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
  String get report_message {
    return Intl.message(
      'Report this content if it makes you feel uncomfortable, we will remove it ASAP once we confirmed that it\'s harmful.',
      name: 'report_message',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get retry {
    return Intl.message(
      'Retry',
      name: 'retry',
      desc: '',
      args: [],
    );
  }

  /// `Retry failed tasks`
  String get retry_failed_tasks {
    return Intl.message(
      'Retry failed tasks',
      name: 'retry_failed_tasks',
      desc: '',
      args: [],
    );
  }

  /// `The designer who drew the lovely icon for PixEz`
  String get right_now_message {
    return Intl.message(
      'The designer who drew the lovely icon for PixEz',
      name: 'right_now_message',
      desc: '',
      args: [],
    );
  }

  /// `Running`
  String get running {
    return Intl.message(
      'Running',
      name: 'running',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Filename format`
  String get save_format {
    return Intl.message(
      'Filename format',
      name: 'save_format',
      desc: '',
      args: [],
    );
  }

  /// `Save location`
  String get save_path {
    return Intl.message(
      'Save location',
      name: 'save_path',
      desc: '',
      args: [],
    );
  }

  /// `Saved`
  String get saved {
    return Intl.message(
      'Saved',
      name: 'saved',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message(
      'Search',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  /// `Enter keywords or paste links`
  String get search_word_or_paste_link {
    return Intl.message(
      'Enter keywords or paste links',
      name: 'search_word_or_paste_link',
      desc: '',
      args: [],
    );
  }

  /// `Separate folders`
  String get separate_folder {
    return Intl.message(
      'Separate folders',
      name: 'separate_folder',
      desc: '',
      args: [],
    );
  }

  /// `Create separate folders for each user`
  String get separate_folder_message {
    return Intl.message(
      'Create separate folders for each user',
      name: 'separate_folder_message',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get setting {
    return Intl.message(
      'Settings',
      name: 'setting',
      desc: '',
      args: [],
    );
  }

  /// `Share`
  String get share {
    return Intl.message(
      'Share',
      name: 'share',
      desc: '',
      args: [],
    );
  }

  /// `Share this app with others`
  String get share_this_app_link {
    return Intl.message(
      'Share this app with others',
      name: 'share_this_app_link',
      desc: '',
      args: [],
    );
  }

  /// `{name} has been muted`
  String shield_message(Object name) {
    return Intl.message(
      '$name has been muted',
      name: 'shield_message',
      desc: '',
      args: [name],
    );
  }

  /// `Mute settings`
  String get shielding_settings {
    return Intl.message(
      'Mute settings',
      name: 'shielding_settings',
      desc: '',
      args: [],
    );
  }

  /// `The contributor who wrote the wonderful README`
  String get skimige_message {
    return Intl.message(
      'The contributor who wrote the wonderful README',
      name: 'skimige_message',
      desc: '',
      args: [],
    );
  }

  /// `Skins`
  String get skin {
    return Intl.message(
      'Skins',
      name: 'skin',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get skip {
    return Intl.message(
      'Skip',
      name: 'skip',
      desc: '',
      args: [],
    );
  }

  /// `Source`
  String get source {
    return Intl.message(
      'Source',
      name: 'source',
      desc: '',
      args: [],
    );
  }

  /// `Highlights`
  String get spotlight {
    return Intl.message(
      'Highlights',
      name: 'spotlight',
      desc: '',
      args: [],
    );
  }

  /// `Support`
  String get support {
    return Intl.message(
      'Support',
      name: 'support',
      desc: '',
      args: [],
    );
  }

  /// `Feedbacks and contributions are welcomed :)`
  String get support_message {
    return Intl.message(
      'Feedbacks and contributions are welcomed :)',
      name: 'support_message',
      desc: '',
      args: [],
    );
  }

  /// `Tag`
  String get tag {
    return Intl.message(
      'Tag',
      name: 'tag',
      desc: '',
      args: [],
    );
  }

  /// `Progress`
  String get task_progress {
    return Intl.message(
      'Progress',
      name: 'task_progress',
      desc: '',
      args: [],
    );
  }

  /// `Terms of use`
  String get terms {
    return Intl.message(
      'Terms of use',
      name: 'terms',
      desc: '',
      args: [],
    );
  }

  /// `Thank you`
  String get thanks {
    return Intl.message(
      'Thank you',
      name: 'thanks',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get theme {
    return Intl.message(
      'Theme',
      name: 'theme',
      desc: '',
      args: [],
    );
  }

  /// `Title`
  String get title {
    return Intl.message(
      'Title',
      name: 'title',
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

  /// `Likes`
  String get total_bookmark {
    return Intl.message(
      'Likes',
      name: 'total_bookmark',
      desc: '',
      args: [],
    );
  }

  /// `Followed users`
  String get total_follow_users {
    return Intl.message(
      'Followed users',
      name: 'total_follow_users',
      desc: '',
      args: [],
    );
  }

  /// `Total My Pixiv users`
  String get total_mypixiv_users {
    return Intl.message(
      'Total My Pixiv users',
      name: 'total_mypixiv_users',
      desc: '',
      args: [],
    );
  }

  /// `Views`
  String get total_view {
    return Intl.message(
      'Views',
      name: 'total_view',
      desc: '',
      args: [],
    );
  }

  /// `Twitter`
  String get twitter_account {
    return Intl.message(
      'Twitter',
      name: 'twitter_account',
      desc: '',
      args: [],
    );
  }

  /// `Not following`
  String get un_follow {
    return Intl.message(
      'Not following',
      name: 'un_follow',
      desc: '',
      args: [],
    );
  }

  /// `Undefined`
  String get undefined {
    return Intl.message(
      'Undefined',
      name: 'undefined',
      desc: '',
      args: [],
    );
  }

  /// `Unsaved`
  String get unsaved {
    return Intl.message(
      'Unsaved',
      name: 'unsaved',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get update {
    return Intl.message(
      'Update',
      name: 'update',
      desc: '',
      args: [],
    );
  }

  /// `View comments`
  String get view_comment {
    return Intl.message(
      'View comments',
      name: 'view_comment',
      desc: '',
      args: [],
    );
  }

  /// `Clear all cache?`
  String get warning {
    return Intl.message(
      'Clear all cache?',
      name: 'warning',
      desc: '',
      args: [],
    );
  }

  /// `Welcome page`
  String get welcome_page {
    return Intl.message(
      'Welcome page',
      name: 'welcome_page',
      desc: '',
      args: [],
    );
  }

  /// `Page`
  String get which_part {
    return Intl.message(
      'Page',
      name: 'which_part',
      desc: '',
      args: [],
    );
  }

  /// `Works`
  String get works {
    return Intl.message(
      'Works',
      name: 'works',
      desc: '',
      args: [],
    );
  }

  /// `Pick a color`
  String get pick_a_color {
    return Intl.message(
      'Pick a color',
      name: 'pick_a_color',
      desc: '',
      args: [],
    );
  }

  /// `Tap to show {length} results`
  String tap_to_show_results(Object length) {
    return Intl.message(
      'Tap to show $length results',
      name: 'tap_to_show_results',
      desc: '',
      args: [length],
    );
  }

  /// `In order to use SAF you will need to grant SAF access to Pixiv(e.g. Picture/Pixez). This allows you to store illusts to SD cards in modern devices.`
  String get saf_hint {
    return Intl.message(
      'In order to use SAF you will need to grant SAF access to Pixiv(e.g. Picture/Pixez). This allows you to store illusts to SD cards in modern devices.',
      name: 'saf_hint',
      desc: '',
      args: [],
    );
  }

  /// `Why?`
  String get what_is_saf {
    return Intl.message(
      'Why?',
      name: 'what_is_saf',
      desc: '',
      args: [],
    );
  }

  /// `Not a valid Pixiv link >_<`
  String get not_the_correct_link {
    return Intl.message(
      'Not a valid Pixiv link >_<',
      name: 'not_the_correct_link',
      desc: '',
      args: [],
    );
  }

  /// `Start`
  String get start {
    return Intl.message(
      'Start',
      name: 'start',
      desc: '',
      args: [],
    );
  }

  /// `Clear search history`
  String get clear_search_tag_history {
    return Intl.message(
      'Clear search history',
      name: 'clear_search_tag_history',
      desc: '',
      args: [],
    );
  }

  /// `Link`
  String get link {
    return Intl.message(
      'Link',
      name: 'link',
      desc: '',
      args: [],
    );
  }

  /// `Step`
  String get step {
    return Intl.message(
      'Step',
      name: 'step',
      desc: '',
      args: [],
    );
  }

  /// `Notched screen`
  String get special_shaped_screen {
    return Intl.message(
      'Notched screen',
      name: 'special_shaped_screen',
      desc: '',
      args: [],
    );
  }

  /// `Platform-specific settings`
  String get platform_special_setting {
    return Intl.message(
      'Platform-specific settings',
      name: 'platform_special_setting',
      desc: '',
      args: [],
    );
  }

  /// `System`
  String get system {
    return Intl.message(
      'System',
      name: 'system',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get light {
    return Intl.message(
      'Light',
      name: 'light',
      desc: '',
      args: [],
    );
  }

  /// `Dark`
  String get dark {
    return Intl.message(
      'Dark',
      name: 'dark',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get theme_mode {
    return Intl.message(
      'Theme',
      name: 'theme_mode',
      desc: '',
      args: [],
    );
  }

  /// `Create folder`
  String get create_folder {
    return Intl.message(
      'Create folder',
      name: 'create_folder',
      desc: '',
      args: [],
    );
  }

  /// `Traditional`
  String get old_way {
    return Intl.message(
      'Traditional',
      name: 'old_way',
      desc: '',
      args: [],
    );
  }

  /// `Permission denied`
  String get permission_denied {
    return Intl.message(
      'Permission denied',
      name: 'permission_denied',
      desc: '',
      args: [],
    );
  }

  /// `In order to use this method, you will need to allow PixEz to access your files and select a folder`
  String get old_way_message {
    return Intl.message(
      'In order to use this method, you will need to allow PixEz to access your files and select a folder',
      name: 'old_way_message',
      desc: '',
      args: [],
    );
  }

  /// `Return again to exit`
  String get return_again_to_exit {
    return Intl.message(
      'Return again to exit',
      name: 'return_again_to_exit',
      desc: '',
      args: [],
    );
  }

  /// `保存格式必须包含{part},否则多p作品会保存出错！`
  String save_format_lose_part_warning(Object part) {
    return Intl.message(
      '保存格式必须包含$part,否则多p作品会保存出错！',
      name: 'save_format_lose_part_warning',
      desc: '',
      args: [part],
    );
  }

  /// `save painter avatar`
  String get save_painter_avatar {
    return Intl.message(
      'save painter avatar',
      name: 'save_painter_avatar',
      desc: '',
      args: [],
    );
  }

  /// `favorited tag`
  String get favorited_tag {
    return Intl.message(
      'favorited tag',
      name: 'favorited_tag',
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
      Locale.fromSubtags(languageCode: 'ja'),
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
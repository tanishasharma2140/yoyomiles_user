import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @valid_number.
  ///
  /// In en, this message translates to:
  /// **'With a valid number, you can access deliveries, and our other services'**
  String get valid_number;

  /// No description provided for @mobile_number.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobile_number;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @please_enter_mobile.
  ///
  /// In en, this message translates to:
  /// **'please enter a valid 10 digit number'**
  String get please_enter_mobile;

  /// No description provided for @login_agree.
  ///
  /// In en, this message translates to:
  /// **'By clicking on login you agree to the '**
  String get login_agree;

  /// No description provided for @terms_service.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get terms_service;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get and;

  /// No description provided for @privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_policy;

  /// No description provided for @please_enter_otp.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 4-digit OTP.'**
  String get please_enter_otp;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'CHANGE'**
  String get change;

  /// No description provided for @otp.
  ///
  /// In en, this message translates to:
  /// **'One Time Password (OTP) has been sent to this number'**
  String get otp;

  /// No description provided for @enter_otp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP Manually'**
  String get enter_otp;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @resend_otp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resend_otp;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get seconds;

  /// No description provided for @first_name.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get first_name;

  /// No description provided for @last_name.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get last_name;

  /// No description provided for @email_id.
  ///
  /// In en, this message translates to:
  /// **'Email Id'**
  String get email_id;

  /// No description provided for @please_enter.
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get please_enter;

  /// No description provided for @enter_valid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enter_valid;

  /// No description provided for @requirement.
  ///
  /// In en, this message translates to:
  /// **'Requirement'**
  String get requirement;

  /// No description provided for @select_business.
  ///
  /// In en, this message translates to:
  /// **'Please select Business Usage'**
  String get select_business;

  /// No description provided for @referral_code.
  ///
  /// In en, this message translates to:
  /// **'Referral Code(Optional)'**
  String get referral_code;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @please_enter_name.
  ///
  /// In en, this message translates to:
  /// **'Please enter First Name'**
  String get please_enter_name;

  /// No description provided for @please_enter_last.
  ///
  /// In en, this message translates to:
  /// **'Please enter Last Name'**
  String get please_enter_last;

  /// No description provided for @please_enter_email.
  ///
  /// In en, this message translates to:
  /// **'Please enter Email Address'**
  String get please_enter_email;

  /// No description provided for @number_verification.
  ///
  /// In en, this message translates to:
  /// **'A one time password (OTP) will be sent to this number for verification.'**
  String get number_verification;

  /// No description provided for @mobile_number_not.
  ///
  /// In en, this message translates to:
  /// **'Mobile number not found.'**
  String get mobile_number_not;

  /// No description provided for @something_went_wrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get something_went_wrong;

  /// No description provided for @account_suspicion.
  ///
  /// In en, this message translates to:
  /// **'Account Suspicion Alert!'**
  String get account_suspicion;

  /// No description provided for @account_is_suspected.
  ///
  /// In en, this message translates to:
  /// **'Your account is suspected. Please contact the admin for more details.'**
  String get account_is_suspected;

  /// No description provided for @otp_sent_successfully.
  ///
  /// In en, this message translates to:
  /// **'OTP sent successfully'**
  String get otp_sent_successfully;

  /// No description provided for @exit_app.
  ///
  /// In en, this message translates to:
  /// **'Exit App'**
  String get exit_app;

  /// No description provided for @want_to_exit_app.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit this app?'**
  String get want_to_exit_app;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'  Orders'**
  String get orders;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'payments'**
  String get payments;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @oK.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get oK;

  /// No description provided for @picked_up_from.
  ///
  /// In en, this message translates to:
  /// **'Picked up from'**
  String get picked_up_from;

  /// No description provided for @yoyomiles_reward.
  ///
  /// In en, this message translates to:
  /// **'Explore Yoyomiles Reward'**
  String get yoyomiles_reward;

  /// No description provided for @get.
  ///
  /// In en, this message translates to:
  /// **'Get'**
  String get get;

  /// No description provided for @coins_for_referral.
  ///
  /// In en, this message translates to:
  /// **' coins for each referral!'**
  String get coins_for_referral;

  /// No description provided for @announce.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get announce;

  /// No description provided for @introduce_yoyo.
  ///
  /// In en, this message translates to:
  /// **'Introducing Yoyomiles Enterprise'**
  String get introduce_yoyo;

  /// No description provided for @safety_ki_shart.
  ///
  /// In en, this message translates to:
  /// **'Safety ki shart Lagi!'**
  String get safety_ki_shart;

  /// No description provided for @introduce_load_unload.
  ///
  /// In en, this message translates to:
  /// **'Introducing Loading unloading'**
  String get introduce_load_unload;

  /// No description provided for @past.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get past;

  /// No description provided for @rate_ride.
  ///
  /// In en, this message translates to:
  /// **'Rate Ride'**
  String get rate_ride;

  /// No description provided for @rate_your_ride.
  ///
  /// In en, this message translates to:
  /// **'Rate Your Ride'**
  String get rate_your_ride;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @no_orders.
  ///
  /// In en, this message translates to:
  /// **'No Orders !'**
  String get no_orders;

  /// No description provided for @order_history.
  ///
  /// In en, this message translates to:
  /// **'Order History'**
  String get order_history;

  /// No description provided for @for_older.
  ///
  /// In en, this message translates to:
  /// **'For older orders, contact our support team.'**
  String get for_older;

  /// No description provided for @book_now.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get book_now;

  /// No description provided for @yoyomiles_credit.
  ///
  /// In en, this message translates to:
  /// **'Yoyomiles credits'**
  String get yoyomiles_credit;

  /// No description provided for @add_money.
  ///
  /// In en, this message translates to:
  /// **'Add Money'**
  String get add_money;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @enter_amount.
  ///
  /// In en, this message translates to:
  /// **'Enter Amount'**
  String get enter_amount;

  /// No description provided for @at_least.
  ///
  /// In en, this message translates to:
  /// **'Enter Amount At-least ₹10'**
  String get at_least;

  /// No description provided for @proceed.
  ///
  /// In en, this message translates to:
  /// **'Proceed'**
  String get proceed;

  /// No description provided for @no_transaction.
  ///
  /// In en, this message translates to:
  /// **'No Transactions Found'**
  String get no_transaction;

  /// No description provided for @saved_address.
  ///
  /// In en, this message translates to:
  /// **'Saved Address'**
  String get saved_address;

  /// No description provided for @packer_mover_order.
  ///
  /// In en, this message translates to:
  /// **'Packer Mover Order History'**
  String get packer_mover_order;

  /// No description provided for @benefits.
  ///
  /// In en, this message translates to:
  /// **'Benefits'**
  String get benefits;

  /// No description provided for @yoyomiles_rew.
  ///
  /// In en, this message translates to:
  /// **'Yoyomiles Rewards'**
  String get yoyomiles_rew;

  /// No description provided for @refer_friend.
  ///
  /// In en, this message translates to:
  /// **'Refer your Friends!'**
  String get refer_friend;

  /// No description provided for @invite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get invite;

  /// No description provided for @support_legal.
  ///
  /// In en, this message translates to:
  /// **'Support and Legal'**
  String get support_legal;

  /// No description provided for @help_support.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get help_support;

  /// No description provided for @terms_condition.
  ///
  /// In en, this message translates to:
  /// **'Terms and Condition'**
  String get terms_condition;

  /// No description provided for @setting.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get setting;

  /// No description provided for @log_out.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get log_out;

  /// No description provided for @app_version.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get app_version;

  /// No description provided for @are_you_want_to_log.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get are_you_want_to_log;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

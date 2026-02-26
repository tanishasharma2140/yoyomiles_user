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
  /// **'Change'**
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
  /// **'Something went wrong. Please try again later.'**
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
  /// **'Saved Addresses'**
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

  /// No description provided for @edit_profile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get edit_profile;

  /// No description provided for @add_gst.
  ///
  /// In en, this message translates to:
  /// **'Add GST Details'**
  String get add_gst;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @mob_num.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mob_num;

  /// No description provided for @can_not_change.
  ///
  /// In en, this message translates to:
  /// **'Cannot be changed'**
  String get can_not_change;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @gst_detail.
  ///
  /// In en, this message translates to:
  /// **'GST Details'**
  String get gst_detail;

  /// No description provided for @gst_no.
  ///
  /// In en, this message translates to:
  /// **'GSTIN No'**
  String get gst_no;

  /// No description provided for @gst_address_no.
  ///
  /// In en, this message translates to:
  /// **'GST Registration Address '**
  String get gst_address_no;

  /// No description provided for @add_new_add.
  ///
  /// In en, this message translates to:
  /// **'Add New Address'**
  String get add_new_add;

  /// No description provided for @your_saved_add.
  ///
  /// In en, this message translates to:
  /// **'Your saved addresses'**
  String get your_saved_add;

  /// No description provided for @pin_code.
  ///
  /// In en, this message translates to:
  /// **'Pin code:'**
  String get pin_code;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @no_add_available.
  ///
  /// In en, this message translates to:
  /// **'No Address Available'**
  String get no_add_available;

  /// No description provided for @delete_shop_add.
  ///
  /// In en, this message translates to:
  /// **'Delete Shop address?'**
  String get delete_shop_add;

  /// No description provided for @where_is_pickup.
  ///
  /// In en, this message translates to:
  /// **'Where is your pickup?'**
  String get where_is_pickup;

  /// No description provided for @selected_location.
  ///
  /// In en, this message translates to:
  /// **'Selected Location'**
  String get selected_location;

  /// No description provided for @house_apartment.
  ///
  /// In en, this message translates to:
  /// **'House/ Apartment/ Shop(optional)'**
  String get house_apartment;

  /// No description provided for @pin.
  ///
  /// In en, this message translates to:
  /// **'Pincode(optional)'**
  String get pin;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @con_no.
  ///
  /// In en, this message translates to:
  /// **'Contact Number'**
  String get con_no;

  /// No description provided for @use_my_num.
  ///
  /// In en, this message translates to:
  /// **'Use My Mobile Number: '**
  String get use_my_num;

  /// No description provided for @save_as_opt.
  ///
  /// In en, this message translates to:
  /// **'Save as (optional):'**
  String get save_as_opt;

  /// No description provided for @home_ji.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home_ji;

  /// No description provided for @shop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shop;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @confirm_save.
  ///
  /// In en, this message translates to:
  /// **'Confirm and Save'**
  String get confirm_save;

  /// No description provided for @order_his.
  ///
  /// In en, this message translates to:
  /// **'Order History'**
  String get order_his;

  /// No description provided for @your_moving.
  ///
  /// In en, this message translates to:
  /// **'Your Moving Orders'**
  String get your_moving;

  /// No description provided for @see_all.
  ///
  /// In en, this message translates to:
  /// **'See all your packer & mover orders'**
  String get see_all;

  /// No description provided for @no_order_yet.
  ///
  /// In en, this message translates to:
  /// **'No Orders Yet'**
  String get no_order_yet;

  /// No description provided for @scratch.
  ///
  /// In en, this message translates to:
  /// **'Scratch to reveal'**
  String get scratch;

  /// No description provided for @no_ref_yet.
  ///
  /// In en, this message translates to:
  /// **'No referral rewards yet'**
  String get no_ref_yet;

  /// No description provided for @total_re.
  ///
  /// In en, this message translates to:
  /// **'Total Reward'**
  String get total_re;

  /// No description provided for @you_re_reward.
  ///
  /// In en, this message translates to:
  /// **'Your Referral Reward'**
  String get you_re_reward;

  /// No description provided for @no_referal_yet.
  ///
  /// In en, this message translates to:
  /// **'No referral rewards yet'**
  String get no_referal_yet;

  /// No description provided for @you_rewards.
  ///
  /// In en, this message translates to:
  /// **'Your rewards'**
  String get you_rewards;

  /// No description provided for @claimed.
  ///
  /// In en, this message translates to:
  /// **'CLAIMED'**
  String get claimed;

  /// No description provided for @tap_to_open.
  ///
  /// In en, this message translates to:
  /// **'Tap to open'**
  String get tap_to_open;

  /// No description provided for @contact_support.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contact_support;

  /// No description provided for @need_help.
  ///
  /// In en, this message translates to:
  /// **'Need help with your orders?'**
  String get need_help;

  /// No description provided for @no_data_found.
  ///
  /// In en, this message translates to:
  /// **'No data found'**
  String get no_data_found;

  /// No description provided for @any_other.
  ///
  /// In en, this message translates to:
  /// **'Any Other question?\n'**
  String get any_other;

  /// No description provided for @call_or_mail.
  ///
  /// In en, this message translates to:
  /// **'Call or Mail us!'**
  String get call_or_mail;

  /// No description provided for @emergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergency;

  /// No description provided for @sos.
  ///
  /// In en, this message translates to:
  /// **'SOS'**
  String get sos;

  /// No description provided for @pickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get pickup;

  /// No description provided for @shifting_date.
  ///
  /// In en, this message translates to:
  /// **'Shifting Date:'**
  String get shifting_date;

  /// No description provided for @drop.
  ///
  /// In en, this message translates to:
  /// **'Drop'**
  String get drop;

  /// No description provided for @total_charges.
  ///
  /// In en, this message translates to:
  /// **'Total Charges'**
  String get total_charges;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @view_order_de.
  ///
  /// In en, this message translates to:
  /// **'View Order Details'**
  String get view_order_de;

  /// No description provided for @assigned_soon.
  ///
  /// In en, this message translates to:
  /// **'Assigned Soon'**
  String get assigned_soon;

  /// No description provided for @agent_waiting.
  ///
  /// In en, this message translates to:
  /// **'Agent waiting...'**
  String get agent_waiting;

  /// No description provided for @assigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get assigned;

  /// No description provided for @agent_name.
  ///
  /// In en, this message translates to:
  /// **'Agent Name:'**
  String get agent_name;

  /// No description provided for @mob.
  ///
  /// In en, this message translates to:
  /// **'Mobile:'**
  String get mob;

  /// No description provided for @order_detail.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get order_detail;

  /// No description provided for @order_summary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get order_summary;

  /// No description provided for @order_id.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get order_id;

  /// No description provided for @total_items.
  ///
  /// In en, this message translates to:
  /// **'Total Items'**
  String get total_items;

  /// No description provided for @add_detail.
  ///
  /// In en, this message translates to:
  /// **'Address Details'**
  String get add_detail;

  /// No description provided for @charges_break.
  ///
  /// In en, this message translates to:
  /// **'Charges Breakdown'**
  String get charges_break;

  /// No description provided for @single_layer.
  ///
  /// In en, this message translates to:
  /// **'Single Layer'**
  String get single_layer;

  /// No description provided for @multi_layer.
  ///
  /// In en, this message translates to:
  /// **'Multi Layer'**
  String get multi_layer;

  /// No description provided for @unpackaging.
  ///
  /// In en, this message translates to:
  /// **'Unpacking'**
  String get unpackaging;

  /// No description provided for @dismantle.
  ///
  /// In en, this message translates to:
  /// **'Dismantle/Reassembly'**
  String get dismantle;

  /// No description provided for @lift_charges.
  ///
  /// In en, this message translates to:
  /// **'Lift Charges'**
  String get lift_charges;

  /// No description provided for @total_amount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get total_amount;

  /// No description provided for @hello_support.
  ///
  /// In en, this message translates to:
  /// **'Hello Support, I need help with my ongoing ride.'**
  String get hello_support;

  /// No description provided for @where_is_drop.
  ///
  /// In en, this message translates to:
  /// **'Where is your Drop?'**
  String get where_is_drop;

  /// No description provided for @please_enter_sender.
  ///
  /// In en, this message translates to:
  /// **'Please enter sender\'s name'**
  String get please_enter_sender;

  /// No description provided for @please_enter_valid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 10-digit mobile number'**
  String get please_enter_valid;

  /// No description provided for @your_goods_will_be.
  ///
  /// In en, this message translates to:
  /// **'Your goods will be picked up from here'**
  String get your_goods_will_be;

  /// No description provided for @sender_name.
  ///
  /// In en, this message translates to:
  /// **'Sender\'s Name'**
  String get sender_name;

  /// No description provided for @sender_mob_no.
  ///
  /// In en, this message translates to:
  /// **'Sender\'s Mobile Number'**
  String get sender_mob_no;

  /// No description provided for @confirm_pickup_location.
  ///
  /// In en, this message translates to:
  /// **'Confirm Pickup Location'**
  String get confirm_pickup_location;

  /// No description provided for @confirm_proceed.
  ///
  /// In en, this message translates to:
  /// **'Confirm and proceed'**
  String get confirm_proceed;

  /// No description provided for @enter_contact_detail.
  ///
  /// In en, this message translates to:
  /// **'Enter Contact Details'**
  String get enter_contact_detail;

  /// No description provided for @receiver_name.
  ///
  /// In en, this message translates to:
  /// **'Receiver\'s Name'**
  String get receiver_name;

  /// No description provided for @receiver_mob_no.
  ///
  /// In en, this message translates to:
  /// **'Receiver\'s Mobile Number'**
  String get receiver_mob_no;

  /// No description provided for @confirm_drop_locatio.
  ///
  /// In en, this message translates to:
  /// **'Confirm Drop Location'**
  String get confirm_drop_locatio;

  /// No description provided for @select_vehicle.
  ///
  /// In en, this message translates to:
  /// **'Select a Vehicle'**
  String get select_vehicle;

  /// No description provided for @edit_location.
  ///
  /// In en, this message translates to:
  /// **'EDIT LOCATION'**
  String get edit_location;

  /// No description provided for @choose_the_vehicle.
  ///
  /// In en, this message translates to:
  /// **'Choose the vehicle for your delivery'**
  String get choose_the_vehicle;

  /// No description provided for @no_vehicle.
  ///
  /// In en, this message translates to:
  /// **'No vehicles available.'**
  String get no_vehicle;

  /// No description provided for @invalid_vehicle_selection.
  ///
  /// In en, this message translates to:
  /// **'Invalid vehicle selection'**
  String get invalid_vehicle_selection;

  /// No description provided for @proceed_with.
  ///
  /// In en, this message translates to:
  /// **'Proceed with'**
  String get proceed_with;

  /// No description provided for @review_booking.
  ///
  /// In en, this message translates to:
  /// **'Review Booking'**
  String get review_booking;

  /// No description provided for @view_add_detail.
  ///
  /// In en, this message translates to:
  /// **'View Address detail'**
  String get view_add_detail;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @of_loading_unloading.
  ///
  /// In en, this message translates to:
  /// **'of loading and unloading time include.'**
  String get of_loading_unloading;

  /// No description provided for @mins.
  ///
  /// In en, this message translates to:
  /// **'mins'**
  String get mins;

  /// No description provided for @offer_discount.
  ///
  /// In en, this message translates to:
  /// **'Offers and Discounts'**
  String get offer_discount;

  /// No description provided for @coupon_applied.
  ///
  /// In en, this message translates to:
  /// **'Coupon Applied'**
  String get coupon_applied;

  /// No description provided for @fare_summary.
  ///
  /// In en, this message translates to:
  /// **'Fare Summary'**
  String get fare_summary;

  /// No description provided for @trip_fare.
  ///
  /// In en, this message translates to:
  /// **'Trip Fare'**
  String get trip_fare;

  /// No description provided for @incl_toll.
  ///
  /// In en, this message translates to:
  /// **' (Incl.Toll)'**
  String get incl_toll;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount 🎉🎉'**
  String get discount;

  /// No description provided for @fare_after_discount.
  ///
  /// In en, this message translates to:
  /// **'Fare After Discount'**
  String get fare_after_discount;

  /// No description provided for @booking_fees_conv_charge.
  ///
  /// In en, this message translates to:
  /// **'Booking Fees & Convenience Chagres'**
  String get booking_fees_conv_charge;

  /// No description provided for @net_fare.
  ///
  /// In en, this message translates to:
  /// **'Net Fare'**
  String get net_fare;

  /// No description provided for @amount_payable.
  ///
  /// In en, this message translates to:
  /// **'Amount Payable'**
  String get amount_payable;

  /// No description provided for @exact.
  ///
  /// In en, this message translates to:
  /// **' (Exact)'**
  String get exact;

  /// No description provided for @good_type.
  ///
  /// In en, this message translates to:
  /// **'Goods Type'**
  String get good_type;

  /// No description provided for @read_before_booking.
  ///
  /// In en, this message translates to:
  /// **'Read before booking'**
  String get read_before_booking;

  /// No description provided for @labour_charges.
  ///
  /// In en, this message translates to:
  /// **'• Fare does not include labour charges for loading & unloading'**
  String get labour_charges;

  /// No description provided for @fare_include.
  ///
  /// In en, this message translates to:
  /// **'• Fare includes '**
  String get fare_include;

  /// No description provided for @min_free_loading.
  ///
  /// In en, this message translates to:
  /// **'mins free loading/unloading time.'**
  String get min_free_loading;

  /// No description provided for @parking_charge.
  ///
  /// In en, this message translates to:
  /// **'• Parking charges to be paid by customer.'**
  String get parking_charge;

  /// No description provided for @fare_include_toll.
  ///
  /// In en, this message translates to:
  /// **'• Fare includes toll and permit charges, if any.'**
  String get fare_include_toll;

  /// No description provided for @we_dont_allow.
  ///
  /// In en, this message translates to:
  /// **'• We do not allow overloading.'**
  String get we_dont_allow;

  /// No description provided for @pay_mode.
  ///
  /// In en, this message translates to:
  /// **'Pay Mode'**
  String get pay_mode;

  /// No description provided for @pay_via_cash.
  ///
  /// In en, this message translates to:
  /// **'Pay Via Cash'**
  String get pay_via_cash;

  /// No description provided for @pay_via_online.
  ///
  /// In en, this message translates to:
  /// **'Pay Via Online'**
  String get pay_via_online;

  /// No description provided for @pay_via_wallet.
  ///
  /// In en, this message translates to:
  /// **'Pay Via Wallet'**
  String get pay_via_wallet;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **' Payment'**
  String get payment;

  /// No description provided for @please_select_good.
  ///
  /// In en, this message translates to:
  /// **'Please Select Goods Type'**
  String get please_select_good;

  /// No description provided for @please_select_pay_mode.
  ///
  /// In en, this message translates to:
  /// **'Please select Pay Mode'**
  String get please_select_pay_mode;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @select_good_type.
  ///
  /// In en, this message translates to:
  /// **'Select your goods type'**
  String get select_good_type;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @coupon_offer.
  ///
  /// In en, this message translates to:
  /// **'Coupons & Offers'**
  String get coupon_offer;

  /// No description provided for @enter_code_here.
  ///
  /// In en, this message translates to:
  /// **'Enter code here'**
  String get enter_code_here;

  /// No description provided for @applyy.
  ///
  /// In en, this message translates to:
  /// **'APPLY'**
  String get applyy;

  /// No description provided for @more_offers.
  ///
  /// In en, this message translates to:
  /// **'More Offers:'**
  String get more_offers;

  /// No description provided for @no_coupon_available.
  ///
  /// In en, this message translates to:
  /// **'No Coupons Available'**
  String get no_coupon_available;

  /// No description provided for @applied.
  ///
  /// In en, this message translates to:
  /// **'APPLIED'**
  String get applied;

  /// No description provided for @valid_till.
  ///
  /// In en, this message translates to:
  /// **'valid till:'**
  String get valid_till;

  /// No description provided for @please_ensure_both.
  ///
  /// In en, this message translates to:
  /// **'Please ensure both pickup and drop locations are selected'**
  String get please_ensure_both;

  /// No description provided for @please_wait_fetching.
  ///
  /// In en, this message translates to:
  /// **'Please wait, fetching location coordinates...'**
  String get please_wait_fetching;

  /// No description provided for @pick_up_location.
  ///
  /// In en, this message translates to:
  /// **'Pick up Location'**
  String get pick_up_location;

  /// No description provided for @tap_to_select_pickup.
  ///
  /// In en, this message translates to:
  /// **'Tap to select pickup location'**
  String get tap_to_select_pickup;

  /// No description provided for @drop_location.
  ///
  /// In en, this message translates to:
  /// **'Drop Location'**
  String get drop_location;

  /// No description provided for @tap_to_select_drop.
  ///
  /// In en, this message translates to:
  /// **'Tap to select drop location'**
  String get tap_to_select_drop;

  /// No description provided for @select_pickup.
  ///
  /// In en, this message translates to:
  /// **'Select Pickup'**
  String get select_pickup;

  /// No description provided for @select_drop.
  ///
  /// In en, this message translates to:
  /// **'Select Drop Location'**
  String get select_drop;

  /// No description provided for @search_location.
  ///
  /// In en, this message translates to:
  /// **'Search location...'**
  String get search_location;

  /// No description provided for @recent_searches.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get recent_searches;

  /// No description provided for @no_recent_search.
  ///
  /// In en, this message translates to:
  /// **'No recent searches'**
  String get no_recent_search;

  /// No description provided for @your_recent_location.
  ///
  /// In en, this message translates to:
  /// **'Your recent location searches will appear here'**
  String get your_recent_location;

  /// No description provided for @recent_search.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get recent_search;

  /// No description provided for @search_history.
  ///
  /// In en, this message translates to:
  /// **'Search History'**
  String get search_history;

  /// No description provided for @no_search_history.
  ///
  /// In en, this message translates to:
  /// **'No search history'**
  String get no_search_history;

  /// No description provided for @choose_a_ride.
  ///
  /// In en, this message translates to:
  /// **'Choose a ride'**
  String get choose_a_ride;

  /// No description provided for @approx_fare.
  ///
  /// In en, this message translates to:
  /// **'Approx. fare'**
  String get approx_fare;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @ride.
  ///
  /// In en, this message translates to:
  /// **'Ride'**
  String get ride;

  /// No description provided for @route_detail.
  ///
  /// In en, this message translates to:
  /// **'Route Details'**
  String get route_detail;

  /// No description provided for @continue_ride.
  ///
  /// In en, this message translates to:
  /// **'Continue Ride'**
  String get continue_ride;

  /// No description provided for @please_enter_both.
  ///
  /// In en, this message translates to:
  /// **'Please enter both pickup and drop locations first.'**
  String get please_enter_both;

  /// No description provided for @please_enter_pickup_floor.
  ///
  /// In en, this message translates to:
  /// **'Please enter pickup floor number'**
  String get please_enter_pickup_floor;

  /// No description provided for @please_enter_drop_floor.
  ///
  /// In en, this message translates to:
  /// **'Please enter drop floor number'**
  String get please_enter_drop_floor;

  /// No description provided for @could_not_fetch_city.
  ///
  /// In en, this message translates to:
  /// **'Could not fetch city details. Please check the addresses and try again.'**
  String get could_not_fetch_city;

  /// No description provided for @with_in_city_service.
  ///
  /// In en, this message translates to:
  /// **'Within City service is not available for different cities'**
  String get with_in_city_service;

  /// No description provided for @within_city_service_confirmed.
  ///
  /// In en, this message translates to:
  /// **'Within City service confirmed! Both locations are in'**
  String get within_city_service_confirmed;

  /// No description provided for @between_cities_service.
  ///
  /// In en, this message translates to:
  /// **' Between Cities service is not available for same city.'**
  String get between_cities_service;

  /// No description provided for @between_cities_service_confirmed.
  ///
  /// In en, this message translates to:
  /// **'Between Cities service confirmed! From'**
  String get between_cities_service_confirmed;

  /// No description provided for @please_fill_all_req.
  ///
  /// In en, this message translates to:
  /// **'Please fill all required fields'**
  String get please_fill_all_req;

  /// No description provided for @something_wnt_wrng.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get something_wnt_wrng;

  /// No description provided for @packer_move.
  ///
  /// In en, this message translates to:
  /// **'Packer and Mover'**
  String get packer_move;

  /// No description provided for @moving_detail.
  ///
  /// In en, this message translates to:
  /// **'Moving details'**
  String get moving_detail;

  /// No description provided for @add_items.
  ///
  /// In en, this message translates to:
  /// **'Add items'**
  String get add_items;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @select_lift_available.
  ///
  /// In en, this message translates to:
  /// **'Service lift available at pickup'**
  String get select_lift_available;

  /// No description provided for @floor_number_at_pickup.
  ///
  /// In en, this message translates to:
  /// **'Floor Number at Pickup'**
  String get floor_number_at_pickup;

  /// No description provided for @service_lift_available_drop.
  ///
  /// In en, this message translates to:
  /// **'Service lift available at drop'**
  String get service_lift_available_drop;

  /// No description provided for @floor_number_at_drop.
  ///
  /// In en, this message translates to:
  /// **'Floor Number at Drop'**
  String get floor_number_at_drop;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @check_price.
  ///
  /// In en, this message translates to:
  /// **'Check Price'**
  String get check_price;

  /// No description provided for @sera_locat.
  ///
  /// In en, this message translates to:
  /// **'Search location'**
  String get sera_locat;

  /// No description provided for @within_city.
  ///
  /// In en, this message translates to:
  /// **'Within City'**
  String get within_city;

  /// No description provided for @between_cities.
  ///
  /// In en, this message translates to:
  /// **'Between Cities'**
  String get between_cities;

  /// No description provided for @please_enter_atleast_one.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one item'**
  String get please_enter_atleast_one;

  /// No description provided for @loading_item.
  ///
  /// In en, this message translates to:
  /// **'Loading items...'**
  String get loading_item;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @no_item_available.
  ///
  /// In en, this message translates to:
  /// **'No items available'**
  String get no_item_available;

  /// No description provided for @please_try_again_later.
  ///
  /// In en, this message translates to:
  /// **'Please try again later'**
  String get please_try_again_later;

  /// No description provided for @add_items_to_get_the.
  ///
  /// In en, this message translates to:
  /// **'Add items to get the exact quote, you can edit this later'**
  String get add_items_to_get_the;

  /// No description provided for @item_added.
  ///
  /// In en, this message translates to:
  /// **'Items added'**
  String get item_added;

  /// No description provided for @view_all.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get view_all;

  /// No description provided for @no_item_selected.
  ///
  /// In en, this message translates to:
  /// **'No items selected'**
  String get no_item_selected;

  /// No description provided for @selected_item.
  ///
  /// In en, this message translates to:
  /// **'Selected Items'**
  String get selected_item;

  /// No description provided for @no_item_available_in.
  ///
  /// In en, this message translates to:
  /// **'No items available in this category'**
  String get no_item_available_in;

  /// No description provided for @select_pickup_slot.
  ///
  /// In en, this message translates to:
  /// **'Select Pickup Slot'**
  String get select_pickup_slot;

  /// No description provided for @loading_slot.
  ///
  /// In en, this message translates to:
  /// **'Loading slots for'**
  String get loading_slot;

  /// No description provided for @loading_slot_for.
  ///
  /// In en, this message translates to:
  /// **'Loading slots for selected date...'**
  String get loading_slot_for;

  /// No description provided for @available_time.
  ///
  /// In en, this message translates to:
  /// **'Available Time Slots'**
  String get available_time;

  /// No description provided for @no_slot_available.
  ///
  /// In en, this message translates to:
  /// **'No slots available'**
  String get no_slot_available;

  /// No description provided for @load_slot.
  ///
  /// In en, this message translates to:
  /// **'Load Slots'**
  String get load_slot;

  /// No description provided for @confirm_slot.
  ///
  /// In en, this message translates to:
  /// **'Confirm Slot'**
  String get confirm_slot;

  /// No description provided for @slots.
  ///
  /// In en, this message translates to:
  /// **'slots'**
  String get slots;

  /// No description provided for @not_available.
  ///
  /// In en, this message translates to:
  /// **'Not Available'**
  String get not_available;

  /// No description provided for @payment_summary.
  ///
  /// In en, this message translates to:
  /// **'Payment Summary'**
  String get payment_summary;

  /// No description provided for @shifting_on.
  ///
  /// In en, this message translates to:
  /// **'Shifting on:'**
  String get shifting_on;

  /// No description provided for @pay_booking_amount.
  ///
  /// In en, this message translates to:
  /// **'Pay booking amount'**
  String get pay_booking_amount;

  /// No description provided for @please_make_sure.
  ///
  /// In en, this message translates to:
  /// **'Please make sure to read our '**
  String get please_make_sure;

  /// No description provided for @terms_con.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get terms_con;

  /// No description provided for @select_shifting_date.
  ///
  /// In en, this message translates to:
  /// **'Select shifting date'**
  String get select_shifting_date;

  /// No description provided for @recommended_add_ons.
  ///
  /// In en, this message translates to:
  /// **'Recommended add-ons'**
  String get recommended_add_ons;

  /// No description provided for @we_couldnot_find.
  ///
  /// In en, this message translates to:
  /// **'We Couldn\'t Find a Driver'**
  String get we_couldnot_find;

  /// No description provided for @it_seems_there_are_no_drivers.
  ///
  /// In en, this message translates to:
  /// **'It seems there are no drivers available on this route right now. Please try again in a little while.'**
  String get it_seems_there_are_no_drivers;

  /// No description provided for @cancel_ride.
  ///
  /// In en, this message translates to:
  /// **'Cancel Ride'**
  String get cancel_ride;

  /// No description provided for @go_back.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get go_back;

  /// No description provided for @ride_completed.
  ///
  /// In en, this message translates to:
  /// **'Ride Completed!🎉'**
  String get ride_completed;

  /// No description provided for @your_ride_has_been.
  ///
  /// In en, this message translates to:
  /// **'Your ride has been cancelled by driver'**
  String get your_ride_has_been;

  /// No description provided for @ride_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Ride Cancelled!'**
  String get ride_cancelled;

  /// No description provided for @ride_status_waiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for driver'**
  String get ride_status_waiting;

  /// No description provided for @ride_status_accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted by driver'**
  String get ride_status_accepted;

  /// No description provided for @ride_status_on_the_way.
  ///
  /// In en, this message translates to:
  /// **'On the way to pickup'**
  String get ride_status_on_the_way;

  /// No description provided for @ride_status_arrived.
  ///
  /// In en, this message translates to:
  /// **'Arrived at Pickup Point'**
  String get ride_status_arrived;

  /// No description provided for @ride_status_otp_verified.
  ///
  /// In en, this message translates to:
  /// **'OTP Verified - Ride Started'**
  String get ride_status_otp_verified;

  /// No description provided for @ride_status_reached.
  ///
  /// In en, this message translates to:
  /// **'Reached destination'**
  String get ride_status_reached;

  /// No description provided for @ride_status_completed.
  ///
  /// In en, this message translates to:
  /// **'Ride Completed Successfully'**
  String get ride_status_completed;

  /// No description provided for @ride_status_cancel_user.
  ///
  /// In en, this message translates to:
  /// **'Cancelled by User'**
  String get ride_status_cancel_user;

  /// No description provided for @ride_status_cancel_driver.
  ///
  /// In en, this message translates to:
  /// **'Cancelled by Driver'**
  String get ride_status_cancel_driver;

  /// No description provided for @exit_ride.
  ///
  /// In en, this message translates to:
  /// **'Exit Ride?'**
  String get exit_ride;

  /// No description provided for @are_you_sure_you_want.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit this ride?'**
  String get are_you_sure_you_want;

  /// No description provided for @trip_status.
  ///
  /// In en, this message translates to:
  /// **'Trip Status'**
  String get trip_status;

  /// No description provided for @searching_for_driver.
  ///
  /// In en, this message translates to:
  /// **'Searching for drivers nearby...'**
  String get searching_for_driver;

  /// No description provided for @your_trip_otp.
  ///
  /// In en, this message translates to:
  /// **'Your Trip OTP'**
  String get your_trip_otp;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @payment_method.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get payment_method;

  /// No description provided for @ride_started.
  ///
  /// In en, this message translates to:
  /// **'🚗 Ride Started!'**
  String get ride_started;

  /// No description provided for @trip_comple.
  ///
  /// In en, this message translates to:
  /// **'🎉 Trip Completed!'**
  String get trip_comple;

  /// No description provided for @cash_payment.
  ///
  /// In en, this message translates to:
  /// **'Cash Payment'**
  String get cash_payment;

  /// No description provided for @online_payment.
  ///
  /// In en, this message translates to:
  /// **'Online Payment'**
  String get online_payment;

  /// No description provided for @please_pay_cash_to.
  ///
  /// In en, this message translates to:
  /// **'Please pay cash to the driver'**
  String get please_pay_cash_to;

  /// No description provided for @complete_your_online_payment.
  ///
  /// In en, this message translates to:
  /// **'Complete your online payment below'**
  String get complete_your_online_payment;

  /// No description provided for @pay_now.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get pay_now;

  /// No description provided for @payment_status.
  ///
  /// In en, this message translates to:
  /// **'Payment Status:'**
  String get payment_status;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @pay.
  ///
  /// In en, this message translates to:
  /// **'Pay Mode: '**
  String get pay;

  /// No description provided for @cash_on_delivery.
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery'**
  String get cash_on_delivery;

  /// No description provided for @by_wallet.
  ///
  /// In en, this message translates to:
  /// **'By Wallet'**
  String get by_wallet;

  /// No description provided for @nothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing'**
  String get nothing;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @cancel_by_user.
  ///
  /// In en, this message translates to:
  /// **'Cancel by User'**
  String get cancel_by_user;

  /// No description provided for @cancel_by_driver.
  ///
  /// In en, this message translates to:
  /// **'Cancel by Driver'**
  String get cancel_by_driver;

  /// No description provided for @tap_to_rate_your.
  ///
  /// In en, this message translates to:
  /// **'Tap to rate your experience'**
  String get tap_to_rate_your;

  /// No description provided for @point_zero.
  ///
  /// In en, this message translates to:
  /// **'.0 Star Rating'**
  String get point_zero;

  /// No description provided for @change_language.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get change_language;

  /// No description provided for @select_language.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get select_language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @eng_united_king.
  ///
  /// In en, this message translates to:
  /// **'English (United Kingdom)'**
  String get eng_united_king;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi (भारत)'**
  String get hindi;
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

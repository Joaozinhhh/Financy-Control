import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('es'), Locale('pt')];

  /// Navigate to Reports screen from profile.
  ///
  /// In en, this message translates to:
  /// **'Access Reports'**
  String get accessReports;

  /// CTA to go to transactions page.
  ///
  /// In en, this message translates to:
  /// **'Add or view transactions'**
  String get addOrViewTransactions;

  /// Helper text for empty reports.
  ///
  /// In en, this message translates to:
  /// **'Add some transactions to generate reports'**
  String get addTransactionsToGenerateReports;

  /// Time range selector label: All time.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// Link to sign-in screen from sign-up.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign In'**
  String get alreadyHaveAccountSignIn;

  /// Transaction amount label.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// Navigate back to sign-in screen.
  ///
  /// In en, this message translates to:
  /// **'Back to Sign In'**
  String get backToSignIn;

  /// Current account balance label.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// Cancel action label.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Transaction category label.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// List tile/action to change display name.
  ///
  /// In en, this message translates to:
  /// **'Change Name'**
  String get changeName;

  /// List tile/action to change password.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// Title of delete confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get confirmDeletion;

  /// Body text of delete confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all your data? This action cannot be undone.'**
  String get confirmDeletionBody;

  /// Confirm password input label/placeholder.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Title when creating a transaction.
  ///
  /// In en, this message translates to:
  /// **'Create Transaction'**
  String get createTransaction;

  /// Transaction date label.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Time range selector label: Day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// Delete action label.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Danger action to delete all user data.
  ///
  /// In en, this message translates to:
  /// **'Delete Data'**
  String get deleteData;

  /// Transaction description label.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Link to sign-up screen from sign-in.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign Up'**
  String get dontHaveAccountSignUp;

  /// Edit action label.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Title when editing a transaction.
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get editTransaction;

  /// Email input label/placeholder.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Validation/help text for amount input.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount'**
  String get enterAmount;

  /// Validation/help text for description input.
  ///
  /// In en, this message translates to:
  /// **'Enter a description'**
  String get enterDescription;

  /// Prompt in name change dialog.
  ///
  /// In en, this message translates to:
  /// **'Enter your new name'**
  String get enterNewName;

  /// Prompt in password change dialog.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password'**
  String get enterNewPassword;

  /// Generic error label/prefix.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Splash error message when auth check fails.
  ///
  /// In en, this message translates to:
  /// **'Error checking auth status'**
  String get errorCheckingAuthStatus;

  /// Header for expense categories list.
  ///
  /// In en, this message translates to:
  /// **'Expense Breakdown'**
  String get expenseBreakdown;

  /// Money spent label.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// Button label to export reports as PDF.
  ///
  /// In en, this message translates to:
  /// **'Export Report as PDF'**
  String get exportReportAsPdf;

  /// Marketing/product name on auth screens.
  ///
  /// In en, this message translates to:
  /// **'Finance App'**
  String get financeApp;

  /// Link to reset password screen.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Disabled button label while generating PDF.
  ///
  /// In en, this message translates to:
  /// **'Generating PDF...'**
  String get generatingPdf;

  /// Anonymous user display name.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// Money received label.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// Header for income categories list.
  ///
  /// In en, this message translates to:
  /// **'Income Breakdown'**
  String get incomeBreakdown;

  /// Home section header for recent transactions.
  ///
  /// In en, this message translates to:
  /// **'Latest Transactions'**
  String get latestTransactions;

  /// Logout action label.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Time range selector label: Month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// Name input label/placeholder.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Bottom nav label for Home screen.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom nav label for Profile screen.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Bottom nav label for Statistics screen.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get navStatistics;

  /// Bottom nav label for Wallet/Transactions tab.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get navWallet;

  /// Summary card label for net balance.
  ///
  /// In en, this message translates to:
  /// **'Net Balance'**
  String get netBalance;

  /// Empty state for no recent transactions.
  ///
  /// In en, this message translates to:
  /// **'No recent transactions'**
  String get noRecentTransactions;

  /// Empty state message in Transactions list.
  ///
  /// In en, this message translates to:
  /// **'No transactions available.'**
  String get noTransactionsAvailable;

  /// Empty state message for filtered period.
  ///
  /// In en, this message translates to:
  /// **'No transactions in this period'**
  String get noTransactionsInPeriod;

  /// Divider text between actions.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// Alias for expenses/outflow.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get outcome;

  /// Password input label/placeholder.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Success message after requesting password reset.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent!'**
  String get passwordResetLinkSent;

  /// Print PDF option title.
  ///
  /// In en, this message translates to:
  /// **'Print PDF'**
  String get printPdf;

  /// Print option subtitle.
  ///
  /// In en, this message translates to:
  /// **'Print or preview before saving'**
  String get printPdfSubtitle;

  /// AppBar title for profile screen.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// AppBar title for reports screen.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsTitle;

  /// Section header in Reports screen.
  ///
  /// In en, this message translates to:
  /// **'Report Summary'**
  String get reportSummary;

  /// Title/button text on reset password flow.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// Primary save action.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Save edits action.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// Dropdown hint for choosing category.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// Hint text for picking a date.
  ///
  /// In en, this message translates to:
  /// **'Select a date'**
  String get selectDate;

  /// Share generated PDF option title.
  ///
  /// In en, this message translates to:
  /// **'Share PDF'**
  String get sharePdf;

  /// Share option subtitle.
  ///
  /// In en, this message translates to:
  /// **'Share via apps (email, messaging, etc.)'**
  String get sharePdfSubtitle;

  /// Primary button for login action.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Primary button for sign-up action.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Sign-up header line 1.
  ///
  /// In en, this message translates to:
  /// **'Let\'s'**
  String get signUpHeaderL1;

  /// Sign-up header line 2.
  ///
  /// In en, this message translates to:
  /// **'Create your'**
  String get signUpHeaderL2;

  /// Sign-up header line 3.
  ///
  /// In en, this message translates to:
  /// **'account'**
  String get signUpHeaderL3;

  /// AppBar title for statistics screen.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsTitle;

  /// Section header for top transactions list.
  ///
  /// In en, this message translates to:
  /// **'Top Transactions'**
  String get topTransactions;

  /// Summary card label for total expenses.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get totalExpenses;

  /// Summary card label for total income.
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get totalIncome;

  /// Summary card label for transaction count.
  ///
  /// In en, this message translates to:
  /// **'Total Transactions'**
  String get totalTransactions;

  /// Title when viewing a transaction.
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get transactionDetails;

  /// AppBar title for transactions list.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactionsTitle;

  /// Time range selector label: Week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// Greeting headline on Home header.
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get welcomeBack;

  /// Time range selector label: Year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

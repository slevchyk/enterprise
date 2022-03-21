library constants;

import 'package:enterprise/models/menu.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const String APP_MODE_USER = "user";
const String APP_MODE_TURNSTILE = "turnstile";

const String SERVER_IP = "95.217.41.66:8811";
const String SERVER_USER = "mobile";
const String SERVER_PASSWORD = "Dq4fS^J&^nqQ(fg4";

const String API_URL_TOKEN = "https://bot.barkom.ua/test/hs/mobileApi/login/";
const String API_USER = "test@test";
const String API_PASSWORD = "test";

const String KEY_SERVER_IP = "keyServerIP";
const String KEY_SERVER_DATABASE = "keyServerDatabase";
const String KEY_SERVER_USER = "keyServerUser";
const String KEY_SERVER_PASSWORD = "keyServerPassword";

const String KEY_USER_PHONE = "keyUserPhone";
const String KEY_USER_PIN = "keyUserPin";
const String KEY_USER_ID = "keyUserID";
//const String KEY_USER_PICTURE = "keyUserPicture";

const String KEY_AUTH_PIN = "keyAuthPin";

const String KEY_CHANNEL_UPDATE_ID = "keyChannelUpdateID";

const String KEY_IS_PROTECTION_ENABLED = "keyIsProtectionEnabled";
const String KEY_IS_BIOMETRIC_PROTECTION_ENABLED = "keyIsBiometricProtectionEnabled";

const String APPLICATION_FILE_PATH = "/storage/emulated/0/DCIM/My Enterprise";
const String APPLICATION_FILE_PATH_PAY_DESK_IMAGE = "$APPLICATION_FILE_PATH/Pay Desk Image";

//Civil statuses
const String CIVIL_STATUS_SINGLE = 'Single';
const String CIVIL_STATUS_MARRIED = 'Married';
const String CIVIL_STATUS_DIVORCED = 'Divorced';
const String CIVIL_STATUS_WIDOWED = 'Widowed';
const String CIVIL_STATUS_OTHER = 'Other';

Map<String, String> civilStatusesAlias = {
  CIVIL_STATUS_SINGLE: "Не одружений",
  CIVIL_STATUS_MARRIED: "Одружений",
  CIVIL_STATUS_DIVORCED: "Розлучений",
  CIVIL_STATUS_WIDOWED: "Вдівець",
  CIVIL_STATUS_OTHER: "Інше",
};

//Education
const int EDUCATION_OTHER = 0;
const int EDUCATION_HIGHER = 1;
const int EDUCATION_INCOMPLETE_HIGHER = 2;
const int EDUCATION_PRIMARY_VOCATIONAL = 3;
const int EDUCATION_BASIC_GENERAL = 4;

Map<int, String> educationsAlias = {
  EDUCATION_OTHER: "Інше",
  EDUCATION_HIGHER: "Вища освіта",
  EDUCATION_INCOMPLETE_HIGHER: "Неповна вища освіта",
  EDUCATION_PRIMARY_VOCATIONAL: "Початкова професійна освіта",
  EDUCATION_BASIC_GENERAL: "Основна загальна освіта",
};

//Timing
const String TIMING_STATUS_WORKDAY = 'Workday';
const String TIMING_STATUS_JOB = 'Job';
const String TIMING_STATUS_LUNCH = 'Lanch';
const String TIMING_STATUS_BREAK = 'Break';
const String TIMING_STATUS_STOP = 'Stop';

Map<String, String> timingAlias = {
  TIMING_STATUS_WORKDAY: "Турнікет",
  TIMING_STATUS_JOB: "Робота",
  TIMING_STATUS_LUNCH: "Обід",
  TIMING_STATUS_BREAK: "Перерва",
};

//Channel
const String CHANNEL_TYPE_STATUS = "status";
const String CHANNEL_TYPE_MESSAGE = "message";

//Genders
const String GENDER_MALE = "male";
const String GENDER_FEMALE = "female";

//Menu Items
Map<MenuItem, String> menuList = {
  MenuItem(
      name: "Головна",
      icon: Icons.home,
      path: "/home",
      isDivider: true
  ) : "default",
  MenuItem(
    name: "Каса",
    icon: FontAwesomeIcons.cashRegister,
    path: "/paydesk",
    category: "Каса",
  ) : "Каса",
  MenuItem(
    name: "Баланс",
    icon: Icons.receipt,
    path: "/balance",
    category: "Каса",
  ) : "Каса",
  MenuItem(
    name: "Аналiтика",
    icon: FontAwesomeIcons.chartPie,
    path: "/results",
    category: "Каса",
    isDivider: true,
  ) : "Каса",
  MenuItem(
    name: "Хронометраж",
    icon: Icons.timer,
    category: "Облік робочого часу",
    path: "/timing",
  ) : "Облік робочого часу",
  MenuItem(
    name: "Турнікет",
    icon: Icons.play_circle_outline,
    category: "Облік робочого часу",
    path: "/turnstile",
    isDivider: true,
  ) : "Облік робочого часу",
  MenuItem(
    name: "Склад",
    icon: FontAwesomeIcons.boxes,
    path: "/warehouse/orders",
    isDivider: true,
    category: "Склад",
  ) : "Склад",
  MenuItem(
    name: "HelpDesk",
    icon: Icons.help,
    path: "/helpdesk",
    category: "Help Desk",
  ) : "Help Desk",
  MenuItem(
      name: "Погодження",
      icon: Icons.done_outline,
      path: "/coordination",
      isClearCache: true,
      category: "Help Desk"
  ) : "Help Desk",
  MenuItem(
    name: "Debug",
    icon: Icons.bug_report,
    path: "/debug",
    isDivider: true,
    category: "Help Desk",
  ) : "Help Desk",
  MenuItem(
      name: "Профіль",
      icon: Icons.person,
      path: "/profile",
      category: "Профіль"
  ) : "Профіль",
  MenuItem(
      name: "Налаштування",
      icon: Icons.settings,
      path: "/settings",
      category: "Профіль"
  ) : "Профіль",
  MenuItem(
      path: "/exit",
      category: "Профіль",
      isDivider: true
  ) : "Профіль",
  MenuItem(
    name: "Про додаток",
    icon: Icons.info,
    path: "/about",
  ) : "default",
};

Map<String, String> genderAlias = {
  GENDER_FEMALE: "жіноча",
  GENDER_MALE: "чоловіча",
};

//Passport types
const String PASSPORT_TYPE_ORIGINAL = "original";
const String PASSPORT_TYPE_ID = "id";

Map<String, String> passportTypesAlias = {
  PASSPORT_TYPE_ORIGINAL: "паспорт",
  PASSPORT_TYPE_ID: "ID картка",
};

const String HELP_DESK_STATUS_UNPROCESSED = "unprocessed";
const String HELP_DESK_STATUS_PROCESSED = "processed";

//currency
const int CURRENCY_UAH = 980;
const int CURRENCY_USD = 840;
const int CURRENCY_EUR = 978;

Map<int, String> currencyAlias = {
  CURRENCY_UAH: "грн",
  CURRENCY_USD: "дол",
  CURRENCY_EUR: "євр",
};

const Map<int, String> CURRENCY_SYMBOL = {
  826: '\u00a3', //GBP
  840: '\u0024', //USD
  978: '\u20ac', //EUR
  980: '\u20b4', //UAH
  985: '\u007a', //PLN
  643: '\u0440', //'RUB',
  124: '\u0024', //'CAD',
};

const Map<String, String> CURRENCY_SYMBOL_BY_NAME = {
  'GBP': '\u00a3', //GBP
  'USD': '\u0024', //USD
  'EUR': '\u20ac', //EUR
  'грн': '\u20b4', //UAH
  'PLN': '\u007a',
};

const Map<int, String> CURRENCY_NAME = {
  826: 'GBP', //GBP
  840: 'USD', //USD
  978: 'EUR', //EUR
  980: 'грн', //UAH
  985: 'PLN',
  643: 'RUB',
  124: 'CAD',
  036: 'AUD',
  975: 'BGN',
  410: 'KRW',
  344: 'HKD',
  208: 'DKK',
  392: 'JPY',
  191: 'HRK',
  484: 'MXN',
  554: 'NZD',
  376: 'ILS',
  578: 'NOK',
  702: 'SGD',
  946: 'RON',
  348: 'HUF',
  203: 'CZK',
  752: 'SEK',
  756: 'CHF',
  156: 'CNY',
  960: 'XDR',
  959: 'XAU',
  964: 'XPD',
  962: 'XPT',
  961: 'XAG',
  944: 'AZN',
  012: 'DZD',
  032: 'ARS',
  533: 'AWG',
  044: 'BSD',
  590: 'PAB',
  052: 'BBD',
  764: 'THB',
  048: 'BHD',
  084: 'BZD',
  933: 'BYN',
  937: 'VEF',
  068: 'BOB',
  986: 'BRL',
  096: 'BND',
  548: 'VUV',
  051: 'AMD',
  936: 'GHS',
  328: 'GYD',
  324: 'GNF',
  600: 'PYG',
  332: 'HTG',
  270: 'GMD',
  807: 'MKD',
  262: 'DJF',
  784: 'AED',
  090: 'SBD',
  780: 'TTD',
  214: 'DOP',
  704: 'VND',
  132: 'CVE',
  818: 'EGP',
  886: 'YER',
  967: 'ZMW',
  932: 'ZWL',
  558: 'NIO',
  356: 'INR',
  364: 'IRR',
  352: 'ISK',
  400: 'JOD',
  634: 'QAR',
  404: 'KES',
  320: 'GTQ',
  598: 'PGK',
  170: 'COP',
  174: 'KMF',
  976: 'CDF',
  188: 'CRC',
  414: 'KWD',
  981: 'GEL',
  340: 'HNL',
  694: 'SLL',
  422: 'LBP',
  434: 'LYD',
  748: 'SZL',
  426: 'LSL',
  480: 'MUR',
  454: 'MWK',
  969: 'MGA',
  458: 'MYR',
  504: 'MAD',
  498: 'MDL',
  516: 'NAD',
  524: 'NPR',
  901: 'TWD',
  776: 'TOP',
  586: 'PKR',
  408: 'KPW',
  072: 'BWP',
  710: 'ZAR',
  512: 'OMR',
  116: 'KHR',
  646: 'RWF',
  360: 'IDR',
  144: 'LKR',
  222: 'SVC',
  682: 'SAR',
  690: 'SCR',
  941: 'RSD',
  604: 'PEN',
  417: 'KGS',
  972: 'TJS',
  938: 'SDG',
  968: 'SRD',
  951: 'XCD',
  050: 'BDT',
  882: 'WST',
  834: 'TZS',
  496: 'MNT',
  788: 'TND',
  949: 'TRY',
  398: 'KZT',
  800: 'UGX',
  478: 'MRO',
  860: 'UZS',
  858: 'UYU',
  242: 'FJD',
  608: 'PHP',
  952: 'XOF',
  950: 'XAF',
  152: 'CLP',
  388: 'JMD',
};

//pay desk
enum PayDeskTypes {
  costs,
  income,
  transfer,
}

const Map<PayDeskTypes, String> PAY_DESK_TYPES_ALIAS = {
  PayDeskTypes.costs: "Видаток",
  PayDeskTypes.income: "Надходження",
  PayDeskTypes.transfer: "Переміщення",
};

//period dialog
enum SortControllers {
  reload,
  period,
  reloadByPeriod,
}

//coordination
enum CoordinationTypes {
  none, //до погодження
  approved, //погоджено
  reject, //відхилено
}
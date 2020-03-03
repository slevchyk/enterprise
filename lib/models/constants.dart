library constants;

const String APP_MODE_USER = "user";
const String APP_MODE_TURNSTILE = "turnstile";

const String SERVER_IP = "95.217.41.66:8811";
const String SERVER_USER = "mobile";
const String SERVER_PASSWORD = "Dq4fS^J&^nqQ(fg4";

const String KEY_SERVER_IP = "keyServerIP";
const String KEY_SERVER_DATABASE = "keyServerDatabase";
const String KEY_SERVER_USER = "keyServerUser";
const String KEY_SERVER_PASSWORD = "keyServerPassword";

const String KEY_USER_PHONE = "keyUserPhone";
const String KEY_USER_PIN = "keyUserPin";
const String KEY_USER_ID = "keyUserID";
const String KEY_USER_PICTURE = "keyUserPicture";

const String KEY_CHANNEL_UPDATE_ID = "keyChannelUpdateID";

const String KEY_IS_PROTECTION_ENABLED = "keyIsProtectionEnabled";

//Civil statuses
const String CIVIL_STATUS_SINGLE = 'Single';
const String CIVIL_STATUS_MERRIED = 'Married';
const String CIVIL_STATUS_DIVORCED = 'Divorced';
const String CIVIL_STATUS_WIDOWED = 'Widowed';
const String CIVIL_STATUS_OTHER = 'Other';

Map<String, String> civilStatusesAlias = {
  CIVIL_STATUS_SINGLE: "Не одружений",
  CIVIL_STATUS_MERRIED: "Одружений",
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
const String TIMING_STATUS_LANCH = 'Lanch';
const String TIMING_STATUS_BREAK = 'Break';
const String TIMING_STATUS_STOP = 'Stop';

Map<String, String> timingAlias = {
  TIMING_STATUS_WORKDAY: "Турнікет",
  TIMING_STATUS_JOB: "Робота",
  TIMING_STATUS_LANCH: "Обід",
  TIMING_STATUS_BREAK: "Перерва",
};

//Channel
const String CHANNEL_TYPE_STATUS = "status";
const String CHANNEL_TYPE_MESSAGE = "message";

//Genders
const String GENDER_MALE = "male";
const String GENDER_FEMALE = "female";

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

const String HELPDESK_STATUS_UNPROCESSED = "unprocessed";
const String HELPDESK_STATUS_PROCESSED = "processed";

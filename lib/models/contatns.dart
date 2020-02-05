library constants;

const String KEY_SERVER_IP = "keyServerIP";
const String KEY_SERVER_DATABASE = "keyServerDatabase";
const String KEY_SERVER_USER = "keyServerUser";
const String KEY_SERVER_PASSWORD = "keyServerPassword";

const String KEY_USER_PHONE = "keyUserPhone";
const String KEY_USER_PIN = "keyUserPin";
const String KEY_USER_ID = "keyUserID";
const String KEY_USER_PICTURE = "keyUserPicture";

const String KEY_CHANNEL_OFFSET = "keyChannelOffset";

const String CIVIL_STATUS_SINGLE = 'Single';
const String CIVIL_STATUS_MERRIED = 'Married';
const String CIVIL_STATUS_DIVORCED = 'Divorced';
const String CIVIL_STATUS_WIDOWED = 'Widowed';
const String CIVIL_STATUS_OTHER = 'Other';

const int EDUCATION_OTHER = 0;
const int EDUCATION_HIGHER = 1;
const int EDUCATION_INCOMPLETE_HIGHER = 2;
const int EDUCATION_PRIMARY_VOCATIONAL = 3;
const int EDUCATION_BASIC_GENERAL = 4;

const String TIMING_STATUS_WORKDAY = 'Workday';
const String TIMING_STATUS_JOB = 'Job';
const String TIMING_STATUS_LANCH = 'Lanch';
const String TIMING_STATUS_BREAK = 'Break';
const String TIMING_STATUS_STOP = 'Stop';

const Map<String, String> OPERATION_ALIAS = {
  TIMING_STATUS_WORKDAY: "Турнікет",
  TIMING_STATUS_JOB: "Робота",
  TIMING_STATUS_LANCH: "Обід",
  TIMING_STATUS_BREAK: "Перерва",
};

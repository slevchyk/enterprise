
import 'package:f_logs/f_logs.dart';

class Logs{

  static void setLog(){
    LogsConfig config = FLog.getDefaultConfigurations()
      ..timestampFormat = "dd/MM/yyyy kk:mm:ss"
      ..isDebuggable = true
      ..isDevelopmentDebuggingEnabled = true
      ..isLogsEnabled = true
      ..customOpeningDivider = "{"
      ..customClosingDivider = "}";

    FLog.applyConfigurations(config);
    FLog.info(
      text: "logger started",
    );
  }
}
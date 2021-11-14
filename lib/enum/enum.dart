enum MobileVerificationType {
  order_delivery_confirmation,
  account_registration,
  password_reset,
}

enum RegisterStage {
  enterAccountDetails,
  enterVerificationCode,
}

enum SnackbarType {
  warning,
  error,
  info
}

String extractEnumValue(customEnum){
  return customEnum.toString().substring(customEnum.toString().indexOf('.') + 1);
}
enum LoginStage {
  enterMobile,
  enterPassword,
  setNewPassword,
  enterVerificationCode
}

enum RegisterStage {
  enterAccountDetails,
  enterVerificationCode,
}

enum PasswordResetStage {
  enterMobile,
  setNewPassword,
  enterVerificationCode
}

enum MobileVerificationType {
  order_delivery_confirmation,
  account_ownership,
  password_reset,
}

enum MobileNumberInstructionType {
  login_enter_mobile,
  login_enter_password,
  login_set_new_password,

  password_reset_enter_mobile,
  password_reset_set_new_password,

  mobile_verification_ownership,
  mobile_verification_change_password,
  mobile_verification_order_delivery_confirmation,
}

enum InviteTeamStage {
  enterTeamMobileNumbers,
  selectPermissions,
  acceptGoldenRules,
  inviting,
}

enum SnackbarType {
  warning,
  error,
  info
}

enum TransactionPaymentType {
  fullPayment,
  partialPayment
}

enum TransactionBillingAccountType {
  customerAccount,
  differentAccount
}

String extractEnumValue(customEnum){
  return customEnum.toString().substring(customEnum.toString().indexOf('.') + 1);
}
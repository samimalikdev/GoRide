const authService = require('../services/authService');
const catchAsync = require('../utils/catchAsync');

exports.signup = catchAsync(async (req, res) => {
  const { email, password, fullName, userType } = req.body;
  const data = await authService.signup(email, password, fullName, userType);
  res.status(201).json({ message: 'Signup successful!', data });
});

exports.login = catchAsync(async (req, res) => {
  const { email, password, userType } = req.body;
  const data = await authService.login(email, password, userType);
  res.json({ message: 'Login successful!', data });
});

exports.updateProfile = catchAsync(async (req, res) => {
  const token = req.headers.authorization?.split(' ')[1];
  const { fullName, profilePicBase64 } = req.body;
  const data = await authService.updateProfile(token, req.user.id, fullName, profilePicBase64);
  res.json({ message: 'Profile updated successfully!', data });
});

exports.enrollMfa = catchAsync(async (req, res) => {
  const token = req.headers.authorization?.split(' ')[1];
  const result = await authService.enrollMfa(token);
  res.json(result);
});

exports.challengeMfa = catchAsync(async (req, res) => {
  const token = req.headers.authorization?.split(' ')[1];
  const { factorId } = req.body;
  console.log(`MFA Challenge - Token: ${token?.substring(0, 10)}...`);
  const result = await authService.challengeMfa(token, factorId);
  res.json(result);
});

exports.verifyMfa = catchAsync(async (req, res) => {
  const token = req.headers.authorization?.split(' ')[1];
  const { factorId, challengeId, code } = req.body;
  console.log(`MFA Verify - Token: ${token?.substring(0, 10)}...`);
  const result = await authService.verifyMfa(token, factorId, challengeId, code);
  res.json(result);
});

exports.listMfaFactors = catchAsync(async (req, res) => {
  const token = req.headers.authorization?.split(' ')[1];
  console.log('Listing MFA factors for token:', token ? `${token.substring(0, 10)}...` : 'NONE');
  const result = await authService.listMfaFactors(token);
  res.json(result);
});

exports.unenrollMfa = catchAsync(async (req, res) => {
  const token = req.headers.authorization?.split(' ')[1];
  const { factorId } = req.params;
  const result = await authService.unenrollMfa(token, factorId);
  res.json(result);
});

exports.updateFcmToken = catchAsync(async (req, res) => {
  const token = req.headers.authorization?.split(' ')[1];
  const { userId, fcmToken } = req.body;
  const result = await authService.updateFcmToken(token, userId, fcmToken);
  res.json({ message: 'FCM token updated successfully', result });
});

exports.logout = catchAsync(async (req, res) => {
  const token = req.headers.authorization?.split(' ')[1];
  const { userId } = req.body;
  const result = await authService.logout(token, userId);
  res.json(result);
});

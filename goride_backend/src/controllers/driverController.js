const driverService = require('../services/driverService');
const storageService = require('../services/storageService');
const catchAsync = require('../utils/catchAsync');

exports.submitVerification = catchAsync(async (req, res) => {
  const userId = req.user.id;
  const driver = await driverService.submitVerification(userId, req.body);
  res.status(200).json({
    status: 'success',
    data: driver
  });
});

exports.getDriverStatus = catchAsync(async (req, res) => {
  const userId = req.user.id;
  const driver = await driverService.getDriverByUserId(userId);
  res.status(200).json({
    status: 'success',
    data: driver
  });
});

exports.uploadDocument = catchAsync(async function uploadDocument(req, res, next) {
    try {
      console.log('DRIVER_CONTROLLER: Upload request fields:', req.body);
      console.log('DRIVER_CONTROLLER: Upload file info:', req.file ? req.file.originalname : 'No file');

      if (!req.file) {
        throw new AppError('No file uploaded', 400);
      }

      const { docType } = req.body;
      const finalDocType = docType || 'unknown';
      const fileExt = req.file.originalname.split('.').pop();
      const path = `${req.user.id}/${finalDocType}_${Date.now()}.${fileExt}`;
      
      const fileUrl = await storageService.uploadFile(req.file, path);

      res.status(200).json({
        status: 'success',
        data: { url: fileUrl }
      });
    } catch (error) {
      next(error);
    }
  });

exports.toggleOnline = catchAsync(async (req, res) => {
  const userId = req.user.id;
  const { isOnline, latitude, longitude } = req.body;
  const driver = await driverService.updateOnlineStatus(userId, isOnline, latitude, longitude);
  res.status(200).json({
    status: 'success',
    data: driver
  });
});

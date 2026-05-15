const { supabase } = require('../config/supabase');
const AppError = require('../utils/AppError');

class StorageService {
  async uploadFile(file, path, bucket = 'drivers') {
    if (!file) throw new AppError('No file provided', 400);

    const { data, error } = await supabase.storage
      .from(bucket)
      .upload(path, file.buffer, {
        contentType: file.mimetype,
        upsert: true
      });

    if (error) {
      console.error('SUPABASE STORAGE ERROR:', error);
      throw new AppError(error.message, 400);
    }

    const { data: { publicUrl } } = supabase.storage
      .from(bucket)
      .getPublicUrl(path);

    return publicUrl;
  }
}

module.exports = new StorageService();

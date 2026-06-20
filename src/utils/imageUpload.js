import supabase from '../supabase';

/**
 * Upload an image file to Supabase Storage and return its public URL.
 * @param {File} file - The file object to upload
 * @param {string} folder - The folder path within the 'images' bucket (default: 'general')
 * @returns {Promise<string|null>} The public URL of the uploaded image, or null on failure
 */
export const uploadImage = async (file, folder = 'general') => {
  try {
    if (!file) return null;

    const timestamp = Date.now();
    const randomStr = Math.random().toString(36).substring(2, 10);
    const extension = file.name ? file.name.split('.').pop() : 'png';
    const filename = `${timestamp}_${randomStr}.${extension}`;
    const path = `${folder}/${filename}`;

    const { data, error } = await supabase.storage
      .from('images')
      .upload(path, file);

    if (error) {
      console.error('Image upload error:', error.message);
      return null;
    }

    const { data: urlData } = supabase.storage
      .from('images')
      .getPublicUrl(path);

    return urlData.publicUrl;
  } catch (error) {
    console.error('Image upload failed:', error.message);
    return null;
  }
};

export default uploadImage;

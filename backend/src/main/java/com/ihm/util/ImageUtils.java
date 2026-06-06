package com.ihm.util;

import java.util.Base64;

public class ImageUtils {

    public static String toDataUrl(byte[] image) {
        if (image == null) return null;
        return "data:" + detectMimeType(image) + ";base64," + Base64.getEncoder().encodeToString(image);
    }

    public static String detectMimeType(byte[] image) {
        if (image == null || image.length < 2) return "image/png";
        if (image[0] == (byte) 0xFF && image[1] == (byte) 0xD8) return "image/jpeg";
        if (image[0] == (byte) 0x89 && image[1] == (byte) 0x50) return "image/png";
        if (image[0] == (byte) 0x47 && image[1] == (byte) 0x49) return "image/gif";
        if (image[0] == (byte) 0x42 && image[1] == (byte) 0x4D) return "image/bmp";
        if (image.length >= 4) {
            if (image[0] == (byte) 0x52 && image[1] == (byte) 0x49
                    && image[2] == (byte) 0x46 && image[3] == (byte) 0x46) return "image/webp";
        }
        return "image/png";
    }
}

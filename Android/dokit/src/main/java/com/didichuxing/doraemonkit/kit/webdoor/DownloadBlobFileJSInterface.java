package com.didichuxing.doraemonkit.kit.webdoor;

import android.content.Context;
import android.os.Environment;
import android.util.Base64;
import android.webkit.JavascriptInterface;
import android.widget.Toast;
import java.io.File;
import java.io.FileOutputStream;

public class DownloadBlobFileJSInterface {
    private Context mContext;
    private DownloadPdfSuccessListener mDownloadPdfSuccessListener;

    public DownloadBlobFileJSInterface(Context context) {
        this.mContext = context;
    }

    public void setDownloadPdfSuccessListener(DownloadPdfSuccessListener listener) {
        mDownloadPdfSuccessListener = listener;
    }

    @JavascriptInterface
    public void getBase64FromBlobData(String base64Data) {
        convertToPdfAndProcess(base64Data);
    }

    public static String getBase64StringFromBlobUrl(String blobUrl) {
        if (blobUrl.startsWith("blob")) {
            return "javascript: var xhr = new XMLHttpRequest();" +
                "xhr.open('GET', '" + blobUrl + "', true);" +
                "xhr.setRequestHeader('Content-type','application/pdf');" +
                "xhr.responseType = 'blob';" +
                "xhr.onload = function(e) {" +
                "    if (this.status == 200) {" +
                "        var blobFile = this.response;" +
                "        var reader = new FileReader();" +
                "        reader.readAsDataURL(blobFile);" +
                "        reader.onloadend = function() {" +
                "            base64data = reader.result;" +
                "            Android.getBase64FromBlobData(base64data);" +
                "        }" +
                "    }" +
                "};" +
                "xhr.send();";
        }
        return "javascript: console.log('It is not a Blob URL');";
    }

    private void convertToPdfAndProcess(String base64) {
        File pdfFile = new File(Environment.getExternalStoragePublicDirectory(
            Environment.DIRECTORY_DOWNLOADS) + "/android_check_" + System.currentTimeMillis() + ".pdf");
        savePdfToPath(base64, pdfFile);
        Toast.makeText(mContext, pdfFile.getAbsolutePath(), Toast.LENGTH_LONG).show();
        if (mDownloadPdfSuccessListener != null) {
            mDownloadPdfSuccessListener.downloadPdfSuccess(pdfFile.getAbsolutePath());
        }
    }

    private void savePdfToPath(String base64, File pdfFilePath) {
        try {
            byte[] fileBytes = Base64.decode(base64.replaceFirst(
                "data:application/pdf;base64,", ""), 0);
            FileOutputStream os = new FileOutputStream(pdfFilePath, false);
            os.write(fileBytes);
            os.flush();
            os.close();
        } catch (Exception e) {
            e.printStackTrace();
            Toast.makeText(mContext, e.getMessage(), Toast.LENGTH_LONG).show();
        }
    }

    public interface DownloadPdfSuccessListener {
        void downloadPdfSuccess(String absolutePath);
    }

}

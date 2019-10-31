package io.scer.native_pdf_view;

import android.annotation.TargetApi;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.pdf.PdfRenderer;
import android.os.Build;
import android.os.ParcelFileDescriptor;
import android.util.Log;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * NativePDFViewPlugin
 */
@TargetApi(Build.VERSION_CODES.LOLLIPOP)
public class NativePDFViewPlugin implements MethodCallHandler {

    private PdfRenderer mPdfRenderer;
    private PdfRenderer.Page mCurrentPage;
    private ParcelFileDescriptor mFileDescriptor;
    private Registrar registrar;

    private NativePDFViewPlugin(Registrar registrar) {
        this.registrar = registrar;
    }

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "io.scer.pdf_renderer");
        channel.setMethodCallHandler(new NativePDFViewPlugin(registrar));
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.equals("renderPdf")) {
            try {
                String path = call.argument("path");
                Boolean isAsset = call.argument("isAsset");
                result.success(renderPdf(path, isAsset));
            } catch (IOException e) {
                result.error("RENDER_ERROR", "Can't load file", null);
            }
        } else {
            result.notImplemented();
        }
    }

    private List<String> renderPdf(String filePath, Boolean isAsset) throws IOException {
        InputStream inputStream = isAsset
            ? registrar.context().getAssets().open(registrar.lookupKeyForAsset(filePath))
            : new FileInputStream(filePath);
        PdfRenderer renderer = openRenderer(registrar.context(), inputStream);
        if (renderer == null) {
            return new ArrayList<>();
        }

        List<Bitmap> bitmaps = new ArrayList<>();
        int count = renderer.getPageCount();
        for (int i = 0; i < count; i++) {
            Bitmap bitmap = createBitmapOfPage(registrar.context(), i);
            if (bitmap != null) {
                bitmaps.add(bitmap);
            }
        }
        closeRenderer();

        // Send bitmaps to flutter
        List<String> list = new ArrayList<>();
        for (Bitmap bitmap : bitmaps) {
            String s = saveBitmap(bitmap);
            list.add(s);
        }
        return list;
    }

    private PdfRenderer openRenderer(Context context, InputStream asset) throws IOException {
        File file = new File(context.getCacheDir(), generateRandomFilename() + ".pdf");
        Log.d("openRenderer", "created file: " + file);
        if (!file.exists()) {
            try {
                FileOutputStream output = null;
                output = new FileOutputStream(file);
                final byte[] buffer = new byte[1024];
                int size;

                while ((size = asset.read(buffer)) != -1) {
                    output.write(buffer, 0, size);
                }
                asset.close();
                output.close();

            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        mFileDescriptor = ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY);
        if (mFileDescriptor != null) {
            return mPdfRenderer = new PdfRenderer(mFileDescriptor);
        }

        return null;
    }

    private Bitmap createBitmapOfPage(Context context, int index) {
        // Show the first page.
        if (mPdfRenderer.getPageCount() <= index) {
            return null;
        }

        // Make sure to close the current page before opening another one.
        if (null != mCurrentPage) {
            mCurrentPage.close();
        }

        mCurrentPage = mPdfRenderer.openPage(index);

        final float widthPixels = context.getResources().getDisplayMetrics().widthPixels;
        final float heightPixels = context.getResources().getDisplayMetrics().heightPixels;

        Bitmap bitmap = Bitmap.createBitmap(
            Math.round(mCurrentPage.getWidth() * 2),
            Math.round(mCurrentPage.getHeight() * 2),
            Bitmap.Config.ARGB_8888);

        // Now render the page onto the Bitmap.
        mCurrentPage.render(bitmap, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY);

        if (null != mCurrentPage) {
            mCurrentPage.close();
            mCurrentPage = null;
        }

        return bitmap;
    }

    private void closeRenderer() throws IOException {
        mPdfRenderer.close();
        mFileDescriptor.close();
    }

    private String saveBitmap(Bitmap bitmap) throws IOException {
        File createdPdfBitmap = new File(registrar.context().getCacheDir(), generateRandomFilename() + ".png");
        FileOutputStream fOut = new FileOutputStream(createdPdfBitmap);
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, fOut);
        fOut.flush();
        fOut.close();

        return createdPdfBitmap.getAbsolutePath();
    }

    private String generateRandomFilename() {
        return UUID.randomUUID().toString().replaceAll("-", "");
    }
}

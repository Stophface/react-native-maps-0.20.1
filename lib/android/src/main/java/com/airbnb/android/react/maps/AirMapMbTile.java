package com.airbnb.android.react.maps;

import android.content.Context;

import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.Tile;
import com.google.android.gms.maps.model.TileOverlay;
import com.google.android.gms.maps.model.TileOverlayOptions;
import com.google.android.gms.maps.model.TileProvider;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

import android.os.Environment;
import android.util.Log;
// import java.util.ArrayList;
import android.database.DatabaseUtils;
import android.database.sqlite.SQLiteDatabase;
import android.database.Cursor;

import android.database.sqlite.SQLiteDatabase;

/**
 * Created by Christoph Lambio on 30/03/2018.
 * Based on AirMapLocalTileManager.java
 * Copyright (c) zavadpe
 */

public class AirMapMbTile extends AirMapFeature {

    class AIRMapMbTileProvider implements TileProvider {
        private static final int BUFFER_SIZE = 16 * 1024;
        private int tileSize;
        private String pathTemplate;
        private String tileSpecification;


        public AIRMapMbTileProvider(int tileSizet, String pathTemplate) {
            this.tileSize = tileSizet;
            this.pathTemplate = pathTemplate;
        }

        @Override
        public Tile getTile(int x, int y, int zoom) {
            byte[] image = readTileImage(x, y, zoom);
            return image == null ? TileProvider.NO_TILE : new Tile(this.tileSize, this.tileSize, image);
        }

        public void setPathTemplate(String pathTemplate) {
            this.pathTemplate = pathTemplate;
        }

        public void setTileSpecification(String tileSpecification) {
            this.tileSpecification = tileSpecification;
        }

        public void setTileSize(int tileSize) {
            this.tileSize = tileSize;
        }

        private byte[] readTileImage(int x, int y, int zoom) {
            InputStream in = null;
            ByteArrayOutputStream buffer = null;
            String rawQuery = "SELECT * FROM map INNER JOIN images ON map.tile_id = images.tile_id WHERE map.zoom_level = {z} AND map.tile_column = {x} AND map.tile_row = {y}";
            // File file = new File(getTileFilename(x, y, zoom));
            Log.d("XX", Integer.toString(x));
            Log.d("yy", Integer.toString(y));
            Log.d("zz", Integer.toString(zoom));
            Log.d("Tile Specification", this.tileSpecification);

            try {
                String path = Environment.getExternalStorageDirectory().getAbsolutePath() + File.separator + "dhaka2.mbtiles";
                Log.d("Files", "Path: " + path);
                SQLiteDatabase offlineDataDatabase = SQLiteDatabase.openDatabase(path, null, SQLiteDatabase.OPEN_READONLY);
                // TMS TRANSFORMATION
                // y = (2^z) - y - 1
                Double yDouble = Math.pow(2, zoom) - y - 1;
                y = yDouble.intValue();
                String query = rawQuery.replace("{x}", Integer.toString(x))
                        .replace("{y}", Integer.toString(y))
                        .replace("{z}", Integer.toString(zoom));
                Log.d("Query", query);
                Cursor cursor = offlineDataDatabase.rawQuery(query, null);
                Log.d("Cursor", DatabaseUtils.dumpCursorToString(cursor));

                if(cursor.moveToFirst()){
                    byte[] tile = cursor.getBlob(5);
                    return tile;
                }
                return null;


            } catch (Exception e) {
                e.printStackTrace();
                return null;
            }



            // try {
            // in = new FileInputStream(file);
            // buffer = new ByteArrayOutputStream();

            // int nRead;
            // byte[] data = new byte[BUFFER_SIZE];

            // while ((nRead = in.read(data, 0, BUFFER_SIZE)) != -1) {
            // buffer.write(data, 0, nRead);
            // }
            // buffer.flush();

            // return buffer.toByteArray();
            // } catch (IOException e) {
            // e.printStackTrace();
            // return null;
            // } catch (OutOfMemoryError e) {
            // e.printStackTrace();
            // return null;
            // } finally {
            // if (in != null) try { in.close(); } catch (Exception ignored) {}
            // if (buffer != null) try { buffer.close(); } catch (Exception ignored) {}
            // }
        }

        private String getTileFilename(int x, int y, int zoom) {
            String s = this.pathTemplate
                    .replace("{x}", Integer.toString(x))
                    .replace("{y}", Integer.toString(y))
                    .replace("{z}", Integer.toString(zoom));
            return s;
        }
    }

    private TileOverlayOptions tileOverlayOptions;
    private TileOverlay tileOverlay;
    private AirMapMbTile.AIRMapMbTileProvider tileProvider;

    private String pathTemplate;
    private float tileSize;
    private float zIndex;

    public AirMapMbTile(Context context) {
        super(context);
    }

    public void setPathTemplate(String pathTemplate) {
        this.pathTemplate = pathTemplate;
        if (tileProvider != null) {
            tileProvider.setPathTemplate(pathTemplate);
        }
        if (tileOverlay != null) {
            tileOverlay.clearTileCache();
        }
    }

    public void setZIndex(float zIndex) {
        this.zIndex = zIndex;
        if (tileOverlay != null) {
            tileOverlay.setZIndex(zIndex);
        }
    }

    public void setTileSize(float tileSize) {
        this.tileSize = tileSize;
        if (tileProvider != null) {
            tileProvider.setTileSize((int)tileSize);
        }
    }

    public TileOverlayOptions getTileOverlayOptions() {
        if (tileOverlayOptions == null) {
            tileOverlayOptions = createTileOverlayOptions();
        }
        return tileOverlayOptions;
    }

    private TileOverlayOptions createTileOverlayOptions() {
        TileOverlayOptions options = new TileOverlayOptions();
        options.zIndex(zIndex);
        this.tileProvider = new AirMapMbTile.AIRMapMbTileProvider((int)this.tileSize, this.pathTemplate);
        options.tileProvider(this.tileProvider);
        return options;
    }

    @Override
    public Object getFeature() {
        return tileOverlay;
    }

    @Override
    public void addToMap(GoogleMap map) {
        this.tileOverlay = map.addTileOverlay(getTileOverlayOptions());
    }

    @Override
    public void removeFromMap(GoogleMap map) {
        tileOverlay.remove();
    }
}

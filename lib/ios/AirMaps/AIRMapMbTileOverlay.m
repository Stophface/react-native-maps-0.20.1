//
//  AIRMapMbTileOverlay.m
//  Pods-AirMapsExplorer
//
//  Created by Christoph Lambio on 28/03/2018
//  Based on AIRMapLocalTileOverlay.m
//  Copyright (c) by Peter Zavadsky.
//

#import "AIRMapMbTileOverlay.h"
#import "FMDatabase.h"

@interface AIRMapMbTileOverlay ()

@end

@implementation AIRMapMbTileOverlay


-(void)loadTileAtPath:(MKTileOverlayPath)path result:(void (^)(NSData *, NSError *))result {
    NSMutableString *tileFilePath = [self.URLTemplate mutableCopy];
    // https://gist.github.com/tmcw/4954720
    // http://www.maptiler.org/google-maps-coordinates-tile-bounds-projection/
    NSString *pathDummyData = [[NSBundle mainBundle] pathForResource:@"dhaka2" ofType:@"mbtiles"];
    FMDatabase *offlineDataDatabase = [FMDatabase databaseWithPath:pathDummyData];
    [offlineDataDatabase open];
    NSMutableString *query = [NSMutableString stringWithString: @"SELECT * FROM map INNER JOIN images ON map.tile_id = images.tile_id WHERE map.zoom_level = {z} AND map.tile_column = {x} AND map.tile_row = {y};"];
    [query replaceCharactersInRange: [query rangeOfString: @"{z}"] withString:[NSString stringWithFormat:@"%li", path.z]];
    [query replaceCharactersInRange: [query rangeOfString: @"{x}"] withString:[NSString stringWithFormat:@"%li", path.x]];
    NSInteger y = (int)pow((double)2, (double)path.z) - path.y - 1;
    [query replaceCharactersInRange: [query rangeOfString: @"{y}"] withString:[NSString stringWithFormat:@"%li", y]];
    FMResultSet *databaseResult = [offlineDataDatabase executeQuery:query];
    if ([databaseResult next]) {
        NSData *tile = [databaseResult dataForColumn:@"tile_data"];
        [offlineDataDatabase close];
        result(tile,nil);
    } else {
        result(nil,nil);
    }
    
    
    
    /*
     https://stackoverflow.com/questions/29515323/locks-on-db-queries-fmdb?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
     */
    
    
    // NSLog(@"Logged from MbTile: %@", [NSString stringWithFormat:@"%i", path.x]);
    // NSLog(@"Logged from MbTile: %@", [NSString stringWithFormat:@"%i", path.y]);
    // NSLog(@"Logged from MbTile: %@", [NSString stringWithFormat:@"%i", path.z]);
    // [tileFilePath replaceOccurrencesOfString: @"{x}" withString:[NSString stringWithFormat:@"%i", path.x] options:NULL range:NSMakeRange(0, tileFilePath.length)];
    // [tileFilePath replaceOccurrencesOfString:@"{y}" withString:[NSString stringWithFormat:@"%i", path.y] options:NULL range:NSMakeRange(0, tileFilePath.length)];
    // [tileFilePath replaceOccurrencesOfString:@"{z}" withString:[NSString stringWithFormat:@"%i", path.z] options:NULL range:NSMakeRange(0, tileFilePath.length)];
    // if ([[NSFileManager defaultManager] fileExistsAtPath:tileFilePath]) {
    // NSData* tile = [NSData dataWithContentsOfFile:tileFilePath];
    // result(tile,nil);
    // } else {
    // result(nil, nil);
    // }
}


@end


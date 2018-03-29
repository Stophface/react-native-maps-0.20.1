//
//  AIRMapLocalTileOverlay.m
//  Pods-AirMapsExplorer
//
//  Created by Peter Zavadsky on 04/12/2017.
//

#import "AIRMapLocalTileOverlay.h"
#import "FMDatabase.h"

@interface AIRMapLocalTileOverlay ()

@end

@implementation AIRMapLocalTileOverlay


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
    // FMResultSet *databaseResult = [offlineDataDatabase executeQuery:@"SELECT * FROM map INNER JOIN images ON map.tile_id = images.tile_id WHERE map.zoom_level = 13 AND map.tile_column = 1506 AND map.tile_row = 5376"];
    FMResultSet *databaseResult = [offlineDataDatabase executeQuery:query];
    NSLog(@"%@", databaseResult);
    NSLog(@"Query: %@", query);
    NSLog(@"z: %li", path.z);
    NSLog(@"x: %li", path.x);
    NSLog(@"y: %li", path.y);
    NSLog(@"yy: %li", y);
    
    if ([databaseResult next]) {
        NSDictionary *dict = [databaseResult resultDictionary];
        NSLog(@"Dictionary: %@", dict);
        NSData *tile = [databaseResult dataForColumn:@"tile_data"];
        NSLog(@"Tile: %@", tile);
        NSLog(@"intForCol: %i", [databaseResult intForColumn:@"zoom_level"]);
        [offlineDataDatabase close];
        result(tile,nil);
    } else {
        NSLog(@"#######");
        result(nil,nil);
    }
    
    
    
    /*
     https://stackoverflow.com/questions/29515323/locks-on-db-queries-fmdb?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
     */
    
    
    // NSLog(@"Logged from LocalTile: %@", [NSString stringWithFormat:@"%i", path.x]);
    // NSLog(@"Logged from LocalTile: %@", [NSString stringWithFormat:@"%i", path.y]);
    // NSLog(@"Logged from LocalTile: %@", [NSString stringWithFormat:@"%i", path.z]);
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

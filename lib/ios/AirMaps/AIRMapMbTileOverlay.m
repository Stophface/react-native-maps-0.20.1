//
//  AIRMapMbTileOverlay.m
//  Pods-AirMapsExplorer
//
//  Created by Christoph Lambio on 28/03/2018
//  Based on AIRMapLocalTileOverlay.m
//  Copyright (c) by Peter Zavadsky.
//

#import "AIRMapMbTileOverlay.h"

@interface AIRMapMbTileOverlay ()

@end

@implementation AIRMapMbTileOverlay


-(void)loadTileAtPath:(MKTileOverlayPath)path result:(void (^)(NSData *, NSError *))result {
    NSMutableString *tileFilePath = [self.URLTemplate mutableCopy];
    [tileFilePath replaceOccurrencesOfString: @"{x}" withString:[NSString stringWithFormat:@"%i", path.x] options:NULL range:NSMakeRange(0, tileFilePath.length)];
    [tileFilePath replaceOccurrencesOfString:@"{y}" withString:[NSString stringWithFormat:@"%i", path.y] options:NULL range:NSMakeRange(0, tileFilePath.length)];
    [tileFilePath replaceOccurrencesOfString:@"{z}" withString:[NSString stringWithFormat:@"%i", path.z] options:NULL range:NSMakeRange(0, tileFilePath.length)];
    if ([[NSFileManager defaultManager] fileExistsAtPath:tileFilePath]) {
        NSData* tile = [NSData dataWithContentsOfFile:tileFilePath];
        result(tile,nil);
    } else {
        result(nil, nil);
    }
}


@end

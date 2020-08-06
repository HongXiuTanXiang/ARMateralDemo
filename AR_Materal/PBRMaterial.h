//
//  PBRMaterial.h
//  arkit-by-example
//
//  Created by md on 6/15/17.
//  Copyright © 2017 ruanestudios. All rights reserved.
//  这个用来设置node 的material的

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

@interface PBRMaterial : NSObject
+ (SCNMaterial *)materialNamed:(NSString *)name;
@end

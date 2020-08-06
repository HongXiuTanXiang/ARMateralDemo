//
//  ViewController.h
//  AR_Materal
//
//  Created by 李贺 on 2020/8/6.
//  Copyright © 2020 李贺. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>
#import "Plane.h"
#import "Cube.h"
#import "Config.h"

@interface ViewController : UIViewController

@property (nonatomic, retain) NSMutableDictionary<NSUUID *, Plane *> *planes;
@property (nonatomic, retain) NSMutableArray<Cube *> *cubes;
@property (nonatomic, retain) Config *config;
@property (nonatomic, retain) ARWorldTrackingConfiguration *arConfig;
@property (nonatomic) ARTrackingState currentTrackingState;


@end


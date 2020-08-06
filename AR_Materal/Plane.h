//
//  Plane.h
//  AR_Materal
//
//  Created by 李贺 on 2020/8/6.
//  Copyright © 2020 李贺. All rights reserved.
//  用来创建检测到的平面

#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Plane : SCNNode

- (instancetype)initWithAnchor:(ARPlaneAnchor *)anchor isHidden:(BOOL)hidden withMaterial:(SCNMaterial *)material;
- (void)update:(ARPlaneAnchor *)anchor;
- (void)setTextureScale;
- (void)hide;
- (void)changeMaterial;
- (void)remove;
+ (SCNMaterial *)currentMaterial;
@property (nonatomic,retain) ARPlaneAnchor *anchor;
@property (nonatomic, retain) SCNBox *planeGeometry;

@end

NS_ASSUME_NONNULL_END

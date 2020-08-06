//
//  ViewController.m
//  AR_Materal
//
//  Created by 李贺 on 2020/8/6.
//  Copyright © 2020 李贺. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <ARSCNViewDelegate, UIGestureRecognizerDelegate, SCNPhysicsContactDelegate>

@property (nonatomic, strong) ARSCNView *sceneView;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIButton *button1;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentTrackingState = ARTrackingStateNormal;
    [self setupSceneView];
    [self setupLights];
    [self setupRecognizers];
    [self setupUI];
    
    // Create a ARSession confi object we can re-use
    self.arConfig = [ARWorldTrackingConfiguration new];
    self.arConfig.lightEstimationEnabled = YES;
    self.arConfig.planeDetection = ARPlaneDetectionHorizontal;
    
    Config *config = [Config new];
    config.showStatistics = NO;
    config.showWorldOrigin = YES;
    config.showFeaturePoints = YES;
    config.showPhysicsBodies = NO;
    config.detectPlanes = YES;
    self.config = config;
    [self updateConfig];
    
    // Stop the screen from dimming while we are using the app
    [UIApplication.sharedApplication setIdleTimerDisabled:YES];
}

-(void)setupUI {
    self.button = [[UIButton alloc]init];
    self.button.frame = CGRectMake(0, 200, 200, 60);
    [self.button setTitle:@"改变方块纹理" forState:UIControlStateNormal];
    [self.view addSubview:self.button];
    [self.button addTarget:self action:@selector(changeCubeMateral) forControlEvents:UIControlEventTouchUpInside];
    
    self.button1 = [[UIButton alloc]init];
    self.button1.frame = CGRectMake(0, 300, 200, 60);
    [self.button1 setTitle:@"改变平面纹理" forState:UIControlStateNormal];
    [self.view addSubview:self.button1];
    [self.button1 addTarget:self action:@selector(changePlaneMateral) forControlEvents:UIControlEventTouchUpInside];
}

-(void)changeCubeMateral {
    for (SCNNode* node in self.cubes) {
        // We add all the geometry as children of the Plane/Cube SCNNode object, so we can
        // get the parent and see what type of geometry this is
        if ([node isKindOfClass:[Cube class]]) {
          [((Cube *)node) changeMaterial];
        }
    }
}

-(void)changePlaneMateral {
    
    [self.planes enumerateKeysAndObjectsUsingBlock:^(NSUUID * _Nonnull key, Plane * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj changeMaterial];
    }];
}

 
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.navigationController setNavigationBarHidden:YES animated:NO];
  
  // Run the view's session
  [self.sceneView.session runWithConfiguration: self.arConfig options: 0];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
    
  // Pause the view's session
  [self.sceneView.session pause];
}

- (void)updateConfig {
  SCNDebugOptions opts = SCNDebugOptionNone;
  Config *config = self.config;
  if (config.showWorldOrigin) {
    opts |= ARSCNDebugOptionShowWorldOrigin;
  }
  if (config.showFeaturePoints) {
    opts = ARSCNDebugOptionShowFeaturePoints;
  }
  if (config.showPhysicsBodies) {
    opts |= SCNDebugOptionShowPhysicsShapes;
  }
  self.sceneView.debugOptions = opts;
  if (config.showStatistics) {
    self.sceneView.showsStatistics = YES;
  } else {
    self.sceneView.showsStatistics = NO;
  }
}


-(void)setupSceneView {
    self.view.backgroundColor = [UIColor whiteColor];
    self.sceneView = [[ARSCNView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.sceneView];
    
    self.sceneView.delegate = self;
    
    // A dictionary of all the current planes being rendered in the scene
    self.planes = [NSMutableDictionary new];
    
    // A list of all the cubes being rendered in the scene
    self.cubes = [NSMutableArray new];
    
    // Make things look pretty :)
    self.sceneView.antialiasingMode = SCNAntialiasingModeMultisampling4X;
    
    // This is the object that we add all of our geometry to, if you want
    // to render something you need to add it here
    SCNScene *scene = [SCNScene new];
    self.sceneView.scene = scene;
    
}

- (void)setupLights {
  // Turn off all the default lights SceneKit adds since we are handling it ourselves
  self.sceneView.autoenablesDefaultLighting = NO;
  self.sceneView.automaticallyUpdatesLighting = NO;
  
  UIImage *env = [UIImage imageNamed: @"./Assets.scnassets/Environment/spherical.jpg"];
  self.sceneView.scene.lightingEnvironment.contents = env;
  
  //TODO: wantsHdr
}

- (void)setupRecognizers {
  // Single tap will insert a new piece of geometry into the scene
  UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(insertCubeFrom:)];
  tapGestureRecognizer.numberOfTapsRequired = 1;
  [self.sceneView addGestureRecognizer:tapGestureRecognizer];
}

- (void)insertCubeFrom: (UITapGestureRecognizer *)recognizer {
  // Take the screen space tap coordinates and pass them to the hitTest method on the ARSCNView instance
  CGPoint tapPoint = [recognizer locationInView:self.sceneView];
  NSArray<ARHitTestResult *> *result = [self.sceneView hitTest:tapPoint types:ARHitTestResultTypeExistingPlaneUsingExtent];
  
  // If the intersection ray passes through any plane geometry they will be returned, with the planes
  // ordered by distance from the camera
  if (result.count == 0) {
    return;
  }
  
  // If there are multiple hits, just pick the closest plane
  ARHitTestResult * hitResult = [result firstObject];
  [self insertCube:hitResult];
}


- (void)insertCube:(ARHitTestResult *)hitResult {
  // We insert the geometry slightly above the point the user tapped, so that it drops onto the plane
  // using the physics engine
  float insertionYOffset = 0.5;
  SCNVector3 position = SCNVector3Make(
                                       hitResult.worldTransform.columns[3].x,
                                       hitResult.worldTransform.columns[3].y + insertionYOffset,
                                       hitResult.worldTransform.columns[3].z
                                       );
  
  Cube *cube = [[Cube alloc] initAtPosition:position withMaterial:[Cube currentMaterial]];
  [self.cubes addObject:cube];
  [self.sceneView.scene.rootNode addChildNode:cube];
}

#pragma mark - ARSCNViewDelegate

// 改变环境光
- (void)renderer:(id <SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time {
  ARLightEstimate *estimate = self.sceneView.session.currentFrame.lightEstimate;
  if (!estimate) {
    return;
  }
  
  // A value of 1000 is considered neutral, lighting environment intensity normalizes
  // 1.0 to neutral so we need to scale the ambientIntensity value
  CGFloat intensity = estimate.ambientIntensity / 1000.0;
  self.sceneView.scene.lightingEnvironment.intensity = intensity;
}

/**
 Called when a new node has been mapped to the given anchor.
 
 @param renderer The renderer that will render the scene.
 @param node The node that maps to the anchor.
 @param anchor The added anchor.
 */
- (void)renderer:(id <SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
  if (![anchor isKindOfClass:[ARPlaneAnchor class]]) {
    return;
  }
  
  // When a new plane is detected we create a new SceneKit plane to visualize it in 3D
  Plane *plane = [[Plane alloc] initWithAnchor: (ARPlaneAnchor *)anchor isHidden: NO withMaterial:[Plane currentMaterial]];
  [self.planes setObject:plane forKey:anchor.identifier];
  [node addChildNode:plane];
}

/**
 Called when a node has been updated with data from the given anchor.
 
 @param renderer The renderer that will render the scene.
 @param node The node that was updated.
 @param anchor The anchor that was updated.
 */
- (void)renderer:(id <SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
  Plane *plane = [self.planes objectForKey:anchor.identifier];
  if (plane == nil) {
    return;
  }
  
  // When an anchor is updated we need to also update our 3D geometry too. For example
  // the width and height of the plane detection may have changed so we need to update
  // our SceneKit geometry to match that
  [plane update:(ARPlaneAnchor *)anchor];
}

/**
 Called when a mapped node has been removed from the scene graph for the given anchor.
 
 @param renderer The renderer that will render the scene.
 @param node The node that was removed.
 @param anchor The anchor that was removed.
 */
- (void)renderer:(id <SCNSceneRenderer>)renderer didRemoveNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
  // Nodes will be removed if planes multiple individual planes that are detected to all be
  // part of a larger plane are merged.
  [self.planes removeObjectForKey:anchor.identifier];
}

/**
 Called when a node will be updated with data from the given anchor.
 
 @param renderer The renderer that will render the scene.
 @param node The node that will be updated.
 @param anchor The anchor that was updated.
 */
- (void)renderer:(id <SCNSceneRenderer>)renderer willUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
}







@end

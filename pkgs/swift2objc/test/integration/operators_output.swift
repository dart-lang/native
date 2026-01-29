@interface Vec2 : NSObject

@property (nonatomic, assign) double x;
@property (nonatomic, assign) double y;

- (instancetype)initWithX:(double)x y:(double)y;

+ (Vec2 *)add:(Vec2 *)lhs rhs:(Vec2 *)rhs;

+ (BOOL)equals:(Vec2 *)lhs rhs:(Vec2 *)rhs;

+ (double)operator:(Vec2 *)lhs rhs:(Vec2 *)rhs;

@end

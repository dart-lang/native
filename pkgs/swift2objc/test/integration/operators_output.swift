@interface Vec2 : NSObject

@property (nonatomic, assign) double x;
@property (nonatomic, assign) double y;

- (instancetype)initWithX:(double)x y:(double)y;

+ (Vec2 *)plus:(Vec2 *)lhs rhs:(Vec2 *)rhs;

+ (BOOL)equalequal:(Vec2 *)lhs rhs:(Vec2 *)rhs;

+ (double)multiplymultiplymultiply:(Vec2 *)lhs rhs:(Vec2 *)rhs;

@end

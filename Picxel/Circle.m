//
//  Circle.m
//  Picxel
//
//  Created by Ali Haris on 7/1/14.
//  Copyright (c) 2014 Ali Haris. All rights reserved.
//

#import "Circle.h"

@implementation Circle

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.picker.center = CGPointMake(75, 75);
        backgroundImageName = [UIImage imageNamed:@"maldives-island.jpg"];
    }
    
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    self.backgroundImage.frame = CGRectMake(0,0,300,300);
}


#pragma mark - Touch Handling methods
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	for (UITouch *touch in touches){
		[self dispatchTouchEvent:[touch locationInView:self]];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	for (UITouch *touch in touches){
		[self dispatchTouchEvent:[touch locationInView:self]];
	}
}

- (void)dispatchTouchEvent:(CGPoint)position
{
	if (CGRectContainsPoint(self.backgroundImage.frame, position)){
    
        CGFloat xDist = abs((position.x) - (self.center.x - self.frame.origin.x));
        CGFloat yDist = abs((position.y) - (self.center.y - self.frame.origin.y));
        
        CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist));
        
        if ((distance) >= (self.backgroundImage.frame.size.width /2)) {
            // EDGE REACHED SO DON'T UPDATE
        } else {
            self.picker.center = position;
            self.picker.layer.backgroundColor = [self getPixelColorAtLocation:position].CGColor;
        }
    
    }
    
}

#pragma mark - Lazy loading

- (UIImageView*)backgroundImage
{
    if (self->_backgroundImage == nil){
        self->_backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"maldives-island.jpg"]];
        self->_backgroundImage.layer.borderWidth = 2.f;
        self->_backgroundImage.layer.borderColor = [UIColor whiteColor].CGColor;
        self->_backgroundImage.layer.cornerRadius = 150.f;
        self->_backgroundImage.layer.masksToBounds = YES;
    }
    
    if (self->_backgroundImage.superview == nil){
        [self addSubview:self->_backgroundImage];
    }
    
    return self->_backgroundImage;
}

- (UIView*)picker
{
    if (self->_picker == nil){
        self->_picker = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)*0.5,
                                                                     CGRectGetHeight(self.frame)*0.5,
                                                                     30,
                                                                     30)];
        
        self->_picker.autoresizingMask = UIViewAutoresizingNone;
        self->_picker.layer.cornerRadius = 15;
        self->_picker.layer.borderColor = [UIColor blackColor].CGColor;
        self->_picker.layer.borderWidth = 2;
        self->_picker.layer.backgroundColor = [UIColor grayColor].CGColor;
    }
    
    if (self->_picker.superview == nil){
        [self insertSubview:self->_picker aboveSubview:self.backgroundImage];
    }
    
    return self->_picker;
}

#pragma mark - Color Pixel

- (UIColor*) getPixelColorAtLocation:(CGPoint)point {
	UIColor* color = nil;
    
    UIGraphicsBeginImageContext(self.frame.size);
    [[UIImage imageNamed:@"maldives-island.jpg"] drawInRect:self.bounds];
    backgroundImageName = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRef inImage = backgroundImageName.CGImage;
    
	// Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
	CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
	if (cgctx == NULL) { return nil; /* error */ }
	
    size_t w = CGImageGetWidth(inImage);
	size_t h = CGImageGetHeight(inImage);
	CGRect rect = {{0,0},{w,h}};
	
	// Draw the image to the bitmap context. Once we draw, the memory
	// allocated for the context for rendering will then contain the
	// raw image data in the specified color space.
	CGContextDrawImage(cgctx, rect, inImage);
	
	// Now we can get a pointer to the image data associated with the bitmap
	// context.
	unsigned char* data = CGBitmapContextGetData (cgctx);
	if (data != NULL) {
		//offset locates the pixel in the data from x,y.
		//4 for 4 bytes of data per pixel, w is width of one row of data.
		int offset = 4*((w*round(point.y))+round(point.x));
		int alpha =  data[offset];
		int red = data[offset+1];
		int green = data[offset+2];
		int blue = data[offset+3];
		//NSLog(@"offset: %i colors: RGB A %i %i %i  %i",offset,red,green,blue,alpha);
		color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
	}
	
	// When finished, release the context
	CGContextRelease(cgctx);
	// Free image data memory for the context
	if (data) { free(data); }
	
	return color;
}



- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef) inImage {
	
	CGContextRef    context = NULL;
	CGColorSpaceRef colorSpace;
	void *          bitmapData;
	int             bitmapByteCount;
	int             bitmapBytesPerRow;
	
	// Get image width, height. We'll use the entire image.
	size_t pixelsWide = CGImageGetWidth(inImage);
	size_t pixelsHigh = CGImageGetHeight(inImage);
	
	// Declare the number of bytes per row. Each pixel in the bitmap in this
	// example is represented by 4 bytes; 8 bits each of red, green, blue, and
	// alpha.
	bitmapBytesPerRow   = ((int)pixelsWide * 4);
	bitmapByteCount     = ((int)bitmapBytesPerRow * (int)pixelsHigh);
	
	// Use the generic RGB color space.
	colorSpace = CGColorSpaceCreateDeviceRGB();
    
	if (colorSpace == NULL)
	{
		fprintf(stderr, "Error allocating color space\n");
		return NULL;
	}
	
	// Allocate memory for image data. This is the destination in memory
	// where any drawing to the bitmap context will be rendered.
	bitmapData = malloc( bitmapByteCount );
	if (bitmapData == NULL)
	{
		fprintf (stderr, "Memory not allocated!");
		CGColorSpaceRelease( colorSpace );
		return NULL;
	}
	
	// Create the bitmap context. We want pre-multiplied ARGB, 8-bits
	// per component. Regardless of what the source image format is
	// (CMYK, Grayscale, and so on) it will be converted over to the format
	// specified here by CGBitmapContextCreate.
    
	context = CGBitmapContextCreate (bitmapData,
									 pixelsWide,
									 pixelsHigh,
									 8,      // bits per component
									 bitmapBytesPerRow,
									 colorSpace,
									 (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
	if (context == NULL)
	{
		free (bitmapData);
		fprintf (stderr, "Context not created!");
	}
	
	// Make sure and release colorspace before returning
	CGColorSpaceRelease( colorSpace );
	
	return context;
}

@end

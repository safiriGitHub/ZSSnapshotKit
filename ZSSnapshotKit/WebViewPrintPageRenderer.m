//
//  WebViewPrintPageRenderer.m
//  ZSSnapshotKit_master
//
//  Created by safiri on 2019/5/21.
//  Copyright © 2019 safiri. All rights reserved.
//

#import "WebViewPrintPageRenderer.h"

@interface WebViewPrintPageRenderer ()

@property (nonatomic, strong) UIPrintFormatter *formatter;

@property (nonatomic, assign) CGSize contentSize;

@end

@implementation WebViewPrintPageRenderer

- (instancetype)initFormatter:(UIPrintFormatter *)formatter contentSize:(CGSize)contentSize {
    self = [super init];
    if (self) {
        self.formatter = formatter;
        self.contentSize = contentSize;
        [self addPrintFormatter:formatter startingAtPageAtIndex:0];
    }
    return self;
}

- (UIImage *)printContentToImage {
    CGPDFPageRef pdfPage = [self printContentToPDFPage];
    if (!pdfPage) return nil;
    UIImage *image = [self covertPDFPageToImage:pdfPage];
    return image;
}

// MARK: Private

- (CGRect)paperRect {
    return CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
}

- (CGRect)printableRect {
    return CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
}

- (CGPDFPageRef)printContentToPDFPage {
    NSMutableData *data = [NSMutableData data];
    UIGraphicsBeginPDFContextToData(data, self.paperRect, nil);
    [self prepareForDrawingPages:NSMakeRange(0, 1)];
    UIGraphicsBeginPDFPage();
    [self drawPageAtIndex:0 inRect:UIGraphicsGetPDFContextBounds()];
    UIGraphicsEndPDFContext();
    
    CFDataRef cfData = (__bridge CFDataRef)(data);
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(cfData);
    if (!provider) return nil;
    
    CGPDFDocumentRef pdfDocument = CGPDFDocumentCreateWithProvider(provider);
    CGPDFPageRef pdfPage = CGPDFDocumentGetPage(pdfDocument, 1);
    
    return pdfPage;
}

- (UIImage *)covertPDFPageToImage:(CGPDFPageRef)pdfPage {
    
    CGRect pageRect = CGPDFPageGetBoxRect(pdfPage, kCGPDFTrimBox);
    CGSize contentSize = CGSizeMake(floor(pageRect.size.width), floor(pageRect.size.height));
    
    // usually you want UIGraphicsBeginImageContextWithOptions last parameter to be 0.0 as this will us the device's scale
    UIGraphicsBeginImageContextWithOptions(contentSize, YES, 2.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) return nil;
    
    CGContextSetFillColorWithColor(context, UIColor.whiteColor.CGColor);
    CGContextSetStrokeColorWithColor(context, UIColor.whiteColor.CGColor);
    CGContextFillRect(context, pageRect);
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 0, contentSize.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetInterpolationQuality(context, kCGInterpolationDefault);
    CGContextDrawPDFPage(context, pdfPage);
    CGContextRestoreGState(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


@end

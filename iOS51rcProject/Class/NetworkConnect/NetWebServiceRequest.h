//
//  NetWebServiceRequest.h
//  HttpRequest
//
//  Created by Richard Liu on 13-3-18.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "SoapXmlParseHelper.h"


typedef enum _NetworkRequestErrorType {
    NetRequestConnectionFailureErrorType = 1,
    NetRequestTimedOutErrorType = 2,
	
} NetworkRequestErrorType;


extern NSString* const NetWebServiceRequestErrorDomain;

@protocol NetWebServiceRequestDelegate;

@interface NetWebServiceRequest : NSObject 

@property (nonatomic, assign) id<NetWebServiceRequestDelegate> delegate;
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, assign) UIView *delegateView;


//+ (id)serviceRequestUrl:(NSString *)WebURL
//          SOAPActionURL:(NSString *)soapActionURL
//      ServiceMethodName:(NSString *)strMethod
//            SoapMessage:(NSString *)soapMsg;

+ (id)serviceRequestUrl:(NSString *)strMethod
                 Params:(NSDictionary *)params;

//创建请求对象
- (id)initWithUrl:(NSString *)WebURL
          SOAPActionURL:(NSString *)soapActionURL
      ServiceMethodName:(NSString *)strMethod
            SoapMessage:(NSString *)soapMsg;

- (void)cancel;

- (BOOL)isCancelled;
- (BOOL)isExecuting;
- (BOOL)isFinished;

- (void)startAsynchronous;
- (void)startSynchronous;
@end



@protocol NetWebServiceRequestDelegate <NSObject>

@optional


//开始
- (void)netRequestStarted:(NetWebServiceRequest *)request;
//失败
- (void)netRequestFailed:(NetWebServiceRequest *)request didRequestError:(int *)error;
//简历信息
- (void)netRequestFinishedFromCvInfo:(NetWebServiceRequest *)request
                          xmlContent:(GDataXMLDocument *)xmlContent;

@required
//成功
- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSArray *)requestData;


@end


//
//  ServiceHelper.m
//  HttpRequest
//
//  Created by Richard Liu on 13-3-18.
//

#import "NetWebServiceRequest.h"

NSString* const NetWebServiceRequestErrorDomain = @"NetWebServiceRequestErrorDomain";
@interface NetWebServiceRequest ()<ASIHTTPRequestDelegate>
@property (nonatomic, retain) __block ASIHTTPRequest* runningRequest;
@property (nonatomic, retain) NSRecursiveLock *cancelLock;

@end

@implementation NetWebServiceRequest
@synthesize runningRequest = _runningRequest;
@synthesize delegate = _delegate;
@synthesize cancelLock = _cancelLock;
@synthesize tag;

+ (id)serviceRequestUrl:(NSString *)strMethod
            Params:(NSDictionary *)params
{
    NSString *WebURL = @"http://webservice.51rc.com/app2/appservice.asmx";
    NSString *strNameSpace = @"http://www.51rc.com/";
    NSString *soapParam = @"";
    for (id key in params) {
        soapParam = [NSString stringWithFormat:@"%@<%@>%@</%@>\n",soapParam,key,[params objectForKey:key],key];
    }
    NSString *soapMsg = [NSString stringWithFormat:
                         @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                         "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                         "<soap:Body>\n"
                         "<%@ xmlns=\"%@\">\n"
                         "%@"
                         "</%@>\n"
                         "</soap:Body>\n"
                         "</soap:Envelope>\n", strMethod, strNameSpace, soapParam, strMethod
                         ];
    NSLog(@"%@",soapMsg);
    NSString *soapActionURL = [NSString stringWithFormat:@"%@%@",strNameSpace,strMethod];
    return [[[self alloc] initWithUrl:WebURL SOAPActionURL:soapActionURL ServiceMethodName:strMethod SoapMessage:soapMsg] autorelease];
}

//创建请求对象
- (id)initWithUrl:(NSString *)WebURL SOAPActionURL:(NSString *)soapActionURL
                                 ServiceMethodName:(NSString *)strMethod
                                       SoapMessage:(NSString *)soapMsg
{
	//请求发送到的路径
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", WebURL]];
    
	if ((self = [super init])) {
        self.runningRequest = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
        
        NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMsg length]];
        
        //以下对请求信息添加属性前四句是必有的，第五句是soap信息。
        [self.runningRequest addRequestHeader:@"Host" value:[url host]];
        [self.runningRequest addRequestHeader:@"Content-Type" value:@"text/xml; charset=utf-8"];
        [self.runningRequest addRequestHeader:@"Content-Length" value:msgLength];
        [self.runningRequest addRequestHeader:@"SOAPAction" value:[NSString stringWithFormat:@"%@",soapActionURL]];
        [self.runningRequest setRequestMethod:@"POST"];
        //传soap信息
        [self.runningRequest appendPostData:[soapMsg dataUsingEncoding:NSUTF8StringEncoding]];
        [self.runningRequest setValidatesSecureCertificate:NO];
        [self.runningRequest setTimeOutSeconds:60.0];
        [self.runningRequest setDefaultResponseEncoding:NSUTF8StringEncoding];
        
        
        self.runningRequest.delegate = self;
#ifdef SSL
        [self.runningRequest setValidatesSecureCertificate:NO];
#else
        [self.runningRequest setValidatesSecureCertificate:YES];
#endif
        self.cancelLock = [[[NSRecursiveLock alloc] init] autorelease];
    }
	return self;
}

-(void)dealloc{
    [self cancel];

    [super dealloc];
}

- (BOOL)isCancelled
{
    return [self.runningRequest isCancelled];
}

- (BOOL)isExecuting
{
    return [self.runningRequest isExecuting];
}

- (BOOL)isFinished
{
    return [self.runningRequest isFinished];
}

- (void) setDelegate:(id)delegate
{
    [self.cancelLock lock];
    
    _delegate = delegate;
    [self.cancelLock unlock];
}

- (void)startAsynchronous
{
    [_runningRequest startAsynchronous];
}

- (void)startSynchronous
{
    [_runningRequest startSynchronous];
}

- (void) cancel
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.cancelLock lock];
    
    self.delegate = nil;
    
    if (self.runningRequest) {
        [self.runningRequest clearDelegatesAndCancel];
        self.runningRequest = nil;
    }
    
    [self.cancelLock unlock];
}

- (void)NetWebServiceRequestStarted
{
    if (_delegate && [_delegate respondsToSelector:@selector(netRequestStarted:)]) {
        [self.delegate netRequestStarted:self];
    }
}

- (void)FinisheddidRecvedInfoToResult:(NSString *)result responseData:(NSMutableArray*)requestData
{
    if (_delegate && [_delegate respondsToSelector:@selector(netRequestFinished: finishedInfoToResult: responseData:)]) {
		[_delegate netRequestFinished:self finishedInfoToResult:result responseData:requestData];
	}
}

- (void)FinishedReceiveCvInfoResult:(GDataXMLDocument *)xmlContent
{
    if (_delegate && [_delegate respondsToSelector:@selector(netRequestFinishedFromCvInfo:xmlContent:)]) {
        [_delegate netRequestFinishedFromCvInfo:self xmlContent:xmlContent];
    }
}

- (void) FaileddidRequestError:(int *)error
{
    switch (*error) {
        case ASIRequestTimedOutErrorType:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"网络连接超时" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            NSLog(@"网络连接超时");
            break;
        }
        case ASIConnectionFailureErrorType:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"网络连接失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            NSLog(@"未连接网络");
            break;
        }
        default:
            NSLog(@"错误代码%d",*error);
            break;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(netRequestFailed:didRequestError:)]) {
        [_delegate netRequestFailed:self didRequestError:error];
    }
}

#pragma mark -
#pragma mark - ASIHTTPRequestDelegate Methods
- (void)requestStarted:(ASIHTTPRequest *)request
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self NetWebServiceRequestStarted];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    int statusCode = [request responseStatusCode];
	NSString *soapAction = [[request requestHeaders] objectForKey:@"SOAPAction"];
    
    NSArray *arraySOAP =[soapAction componentsSeparatedByString:@"/"];
    int count = (int)[arraySOAP count] - 1;
	NSString *methodName = [arraySOAP objectAtIndex:count];
    
	// Use when fetching text data
	NSString *responseString = [request responseString];
	NSString *result = nil;
    if (statusCode == 200) {
        //表示正常请求
        result = [SoapXmlParseHelper SoapMessageResultXml:responseString ServiceMethodName:methodName];
        GDataXMLDocument *xmlContent = [[[GDataXMLDocument alloc] initWithXMLString:responseString options:0 error:nil] autorelease];
        //GetCvInfo为多表联合，单独判断
        if ([[xmlContent nodesForXPath:@"//paData" error:nil] count] > 0) {
            [self FinishedReceiveCvInfoResult:xmlContent];
            return;
        }
        NSArray *xmlTable = [xmlContent nodesForXPath:@"//Table1" error:nil];
        if ([xmlTable count] == 0) {
            xmlTable = [xmlContent nodesForXPath:@"//ds" error:nil];
        }
        if ([xmlTable count] == 0) {
            xmlTable = [xmlContent nodesForXPath:@"//Table" error:nil];
        }
        NSMutableArray *arrXml = [[[NSMutableArray alloc] init] autorelease];
        for (int i=0; i<xmlTable.count; i++) {
            GDataXMLElement *oneXmlElement = [xmlTable objectAtIndex:i];
            NSArray *arrChild = [oneXmlElement children];
            NSMutableDictionary *dicOneXml = [[[NSMutableDictionary alloc] init] autorelease];
            for (int j=0; j<arrChild.count; j++) {
                [dicOneXml setObject:[arrChild[j] stringValue] forKey:[arrChild[j] name]];
            }
            [arrXml addObject:dicOneXml];
        }
        [self FinisheddidRecvedInfoToResult:result responseData:arrXml];
    }
    else{
        [self FaileddidRequestError:&statusCode];
        NSLog(@"%@",responseString);
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    //网络错误
    int errCode = (int)request.error.code;
    [self FaileddidRequestError:&errCode];
	
}
@end

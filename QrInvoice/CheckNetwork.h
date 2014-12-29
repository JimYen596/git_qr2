//
//  CheckNetWork.h
//  
//
//  Created by Isken on 11/13/10.
//  Copyright 2010 Isken. All rights reserved.
//

#import <netinet/in.h>
#import <SystemConfiguration/SCNetworkReachability.h>

@interface CheckNetwork : NSObject {

}

+ (BOOL) check;

@end

// Author: Tang Qiao
// Date:   2012-3-2
//
// The macro is inspired from:
//     http://www.yifeiyang.net/iphone-development-skills-of-the-debugging-chapter-2-save-the-log/

#ifdef DEBUG
#define debugLog(fmt, ...) NSLog((@"[DEBUG] [THREAD:%@] %s [Line %d] " fmt), [[NSThread currentThread] name], __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#define debugMethod() NSLog(@"%s", __func__)
#else
#define debugLog(...)
#define debugMethod()
#endif

#define EMPTY_STRING        @""

#define STR(key)            NSLocalizedString(key, nil)

#define PATH_OF_APP_HOME    NSHomeDirectory()
#define PATH_OF_TEMP        NSTemporaryDirectory()
#define PATH_OF_DOCUMENT    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]  
#define DB_PATH             [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"user.sqlite"]

#define LIGHT_FONT  [UIFont fontWithName:@"Avenir-Light"  size:14]
#define MEDIUM_FONT [UIFont fontWithName:@"Avenir-Medium" size:16]

#define DARK_COLOR             [UIColor colorWithRed: 68/255.0 green: 68/255.0 blue: 68/255.0 alpha:1.0]
#define KILL_LA_KILL_RED_COLOR [UIColor colorWithRed:221/255.0 green: 45/255.0 blue: 31/255.0 alpha:1.0]
#define LOAD_DB     [FMDatabase databaseWithPath:DB_PATH]

#define RGB(__r, __g, __b)  [UIColor colorWithRed:(1.0*(__r)/255)\
                             green:(1.0*(__g)/255)\
                             blue:(1.0*(__b)/255)\
                             alpha:1.0]



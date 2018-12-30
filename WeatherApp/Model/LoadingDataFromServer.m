//
//  Created by Nodir Latipov on 12/25/18.
//  Copyright © 2018 Home. All rights reserved.
//

#import "LoadingDataFromServer.h"
#import "WeatherForecastModel.h"


@interface LoadingDataFromServer()
@property (nonatomic, strong) NSURLSession *session;
@end

@implementation LoadingDataFromServer


+ (LoadingDataFromServer *)sharedManager
{
    static LoadingDataFromServer *manager = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LoadingDataFromServer alloc] init];
    });

    return manager;
}

- (void)getWeatherWithCity:(NSString *)city
                 onSuccess:(void(^)(NSArray *coutries))success
                 onFailure:(void(^)(NSError *error))failure
{
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:sessionConfig];

    NSString *stringURL = [NSString stringWithFormat:@"https://api.openweathermap.org/data/2.5/forecast?appid=bb87c4e7d376b1ad20e1cd1683c0824d&q=%@&units=metric&type=like&lang=en", city];
    NSURL *url = [NSURL URLWithString:stringURL];

    NSURLSessionDataTask *dataTask =
        [self.session dataTaskWithURL:url
               completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

                   NSArray *weathersForCity = [self handleWeathersLoaded:data];

                   if (success) {
                       success(weathersForCity);
                   }

               }];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [dataTask resume];
    });

}

- (NSArray *)handleWeathersLoaded:(NSData *)data
{
    NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:NSJSONReadingAllowFragments
                                                                   error:NULL];
    NSLog(@"JSON: %@", responseJSON);


    NSArray *weathers = [responseJSON objectForKey:@"list"];

    NSMutableArray<WeatherForecastModel *> *weatherForCity = [[NSMutableArray alloc] init];

    for (NSDictionary *weather in weathers) {
        WeatherForecastModel *row = [[WeatherForecastModel alloc] initWithServerResponse:weather];
        [weatherForCity addObject:row];
    }
    return weatherForCity;
}
@end

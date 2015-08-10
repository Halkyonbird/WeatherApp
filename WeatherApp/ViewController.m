 //
//  ViewController.m
//  WeatherApp
//
//  Created by User on 09.08.15.
//  Copyright (c) 2015 Alex Sheverdin. All rights reserved.
//

#import "ViewController.h"
#import "ASIHTTPRequest.h"
#import "TableViewController.h"
//&units=metric
static NSString  *urlWeather = @"http://api.openweathermap.org/data/2.5/weather?lat=50&lon=36.25&units=metric";
static NSString  *urlForecast = @"http://api.openweathermap.org/data/2.5/forecast?q=kharkiv";

@interface ViewController ()

@property (nonatomic, strong) NSDictionary *allWeatherData;
@property (nonatomic, strong) NSArray *forcast;
@property (nonatomic, weak) TableViewController *tableViewController;
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UILabel *tempLabel;

@end

@implementation ViewController


- (IBAction)getCurrentLocation:(id)sender {
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
  
    [self.locationManager startUpdatingLocation];
}


- (IBAction)refresh:(UIButton *)sender {

    [self downloadWeather];
    [self downloadForecast];
    //NSLog(@"asdf: %@", self.forcast);

}

- (void) downloadWeather {

    [self downloadWeatherDataFromURL:urlWeather withBlock:^(id result) {
        if ([result isKindOfClass:[NSError class]]) {
            //
        } else if ([result isKindOfClass:[NSData class]]) {
            NSError *error;
            self.allWeatherData = [NSJSONSerialization JSONObjectWithData:result options:0 error:&error];
            //self.forcast = [self.allWeatherData valueForKey:@"list"];
            NSDictionary *dict = [self.allWeatherData valueForKey:@"main"];
            self.tempLabel.text = [NSString stringWithFormat:@"%@º", [dict valueForKey:@"temp"]];
//            NSLog(@"Data = %@", self.allWeatherData);
            NSLog(@"Data = %@", dict);
        }
        
    }];
}

- (void) downloadForecast {
    
    [self downloadWeatherDataFromURL:urlForecast withBlock:^(id result) {
        if ([result isKindOfClass:[NSError class]]) {
            //
        } else if ([result isKindOfClass:[NSData class]]) {
            NSError *error;
            self.allWeatherData = [NSJSONSerialization JSONObjectWithData:result options:0 error:&error];
            self.forcast = [self.allWeatherData valueForKey:@"list"];
            
            
            self.tableViewController.forcast = self.forcast;
            [self.tableViewController refreshTable];
        }
        
    }];

}

- (void)downloadWeatherDataFromURL:(NSString *) urlString withBlock:(void(^)(id result))completion {
    NSURL *url = [NSURL URLWithString:urlString];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    __weak typeof(request) wRequest = request;
    [request setCompletionBlock:^{
        if (completion) {
            completion(wRequest.responseData);
        }
    }];
    
    [request setFailedBlock:^{
        if (completion) {
            completion(wRequest.error);
        }
    }];
    
//    [request setBytesReceivedBlock:^(unsigned long long size, unsigned long long total) {
//        NSLog(@"Progress: %llu", size/total);
//    }];
    
    [request startAsynchronous];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"ToTable"]) {
        if ([segue.destinationViewController isKindOfClass:[TableViewController class]]) {
            self.tableViewController = (TableViewController *)segue.destinationViewController;
            self.tableViewController.forcast = self.forcast;
        }

    }
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

//- (void)locationManager:(CLLocationManager *)manager
//     didUpdateLocations:(NSArray*)locations {
//    
//    NSLog(@"locs^ %@", locations);
//}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //NSLog(@"didUpdateToLocation: %@", newLocation);
    
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        _longitudeLabel = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        _latitudeLabel = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
    }

 
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.locationManager = [[CLLocationManager alloc] init];}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end

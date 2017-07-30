// Reference: https://developer.apple.com/reference/corelocation?language=objc
// Reference: https://github.com/evanphx/lost

#include <node.h>
#include <v8.h>

#import <CoreLocation/CoreLocation.h>

using namespace v8;
using namespace node;

@interface NSLInstance : NSObject <CLLocationManagerDelegate> {
    double latitude;
    double longitude;
    double altitude;
    double horizontalAccuracy;
    double verticalAccuracy;

    bool _hasData;
    NSInteger _errorCode;
}

- (void)reset;
- (bool)hasData;
- (void)copyLatitude:(double *)lat longitude:(double *)lng altitude:(double *)att horizontalAccuracy:(double *)horizontalAcc verticalAccuracy:(double *)verticalAcc;

- (void)processReceivedLocation:(CLLocation *)location;
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error;

@end

@implementation NSLInstance

- (void)reset {
    _hasData = false;
    _errorCode = 0;
}

- (bool)hasData {
    return _hasData;
}

- (NSInteger)errorCode {
    return _errorCode;
}

- (void)copyLatitude:(double *)lat longitude:(double *)lng altitude:(double *)att horizontalAccuracy:(double *)horizontalAcc verticalAccuracy:(double *)verticalAcc {
    *lat = latitude;
    *lng = longitude;
    *att = altitude;
    *horizontalAcc = horizontalAccuracy;
    *verticalAcc = verticalAccuracy;
}

- (void)processReceivedLocation:(CLLocation *)location {
    _hasData = true;
    CLLocationCoordinate2D coordinate = location.coordinate;
    latitude = coordinate.latitude;
    longitude = coordinate.longitude;
    altitude = location.altitude;
    horizontalAccuracy = location.horizontalAccuracy;
    verticalAccuracy = location.verticalAccuracy;

    CFRunLoopStop(CFRunLoopGetCurrent());
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self processReceivedLocation:newLocation];
    [pool drain];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if(error.code == kCLErrorHeadingFailure) {
        // This indicates that the heading could not be determined because of
        // strong interference from nearby magnetic fields. In this case, we
        // don't actually need to stop, since we don't care about heading
        // data.
        return;
    }

    // Possible failures at this point are kCLErrorLocationUnknown and kCLErrorDenied

    latitude = 0.0;
    longitude = 0.0;
    _errorCode = error.code;
    CFRunLoopStop(CFRunLoopGetCurrent());
}

@end

CLLocationManager *globalLocationManager = nil;

bool enableCoreLocation() {
    if([CLLocationManager locationServicesEnabled]) {
        globalLocationManager = [[CLLocationManager alloc] init];
        return true;
    }
    return false;
}

bool getCoreLocationPosition(double *lat, double *lng, double *altitude, double *horizontalAccuracy, double *verticalAccuracy, NSInteger *error) {
    NSLInstance *data = [[NSLInstance alloc] init];
    [globalLocationManager setDelegate:data];
    [globalLocationManager startUpdatingLocation];

    // Will block until all the sources and timers are removed from the
    // main run loop.
    CFRunLoopRun();

    [globalLocationManager stopUpdatingLocation];

    if([data hasData]) {
        [data copyLatitude:lat longitude:lng altitude:altitude horizontalAccuracy:horizontalAccuracy verticalAccuracy:verticalAccuracy];
        [data release];
        return true;
    }
    *error = [data errorCode];

    return false;
}

void GetLocation(const FunctionCallbackInfo<Value>& args) {
    Isolate* isolate = Isolate::GetCurrent();
    HandleScope scope(isolate);

    double lat, lng, alt, horizontalAcc, verticalAcc;
    NSInteger error;

    if(!enableCoreLocation()) {
        isolate->ThrowException(Exception::TypeError(String::NewFromUtf8(isolate, "ENOLOCATIONSERVICES")));
        return;
    }

    if(!getCoreLocationPosition(&lat, &lng, &alt, &horizontalAcc, &verticalAcc, &error)) {
        switch(error) {
        case kCLErrorDenied:
            isolate->ThrowException(Exception::TypeError(String::NewFromUtf8(isolate, "ELOCATIONDENIED")));
            return;
        case kCLErrorLocationUnknown:
            isolate->ThrowException(Exception::TypeError(String::NewFromUtf8(isolate, "ELOCATIONUNKNOWN")));
            return;
        default:
            isolate->ThrowException(Exception::TypeError(String::NewFromUtf8(isolate, "EGETLOCATIONFAILED")));
            return;
        }
    }

    Local<Object> obj = Object::New(isolate);
    obj->Set(String::NewFromUtf8(isolate, "lat"), v8::Number::New(isolate, static_cast<double>(lat)));
    obj->Set(String::NewFromUtf8(isolate, "lng"), v8::Number::New(isolate, static_cast<double>(lng)));
    obj->Set(String::NewFromUtf8(isolate, "altitude"), v8::Number::New(isolate, static_cast<double>(alt)));
    obj->Set(String::NewFromUtf8(isolate, "horizontalAccuracy"), v8::Number::New(isolate, static_cast<double>(horizontalAcc)));
    obj->Set(String::NewFromUtf8(isolate, "verticalAccuracy"), v8::Number::New(isolate, static_cast<double>(verticalAcc)));

    args.GetReturnValue().Set(obj);
}

void Initialise(Handle<Object> exports) {
    NODE_SET_METHOD(exports, "getLocation", GetLocation);
}

NODE_MODULE(nslocation, Initialise)

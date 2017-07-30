# NSLocation

**NSLocation** wraps [CoreLocation](https://developer.apple.com/reference/corelocation?language=objc) in order to provide geographic location of a device running macOS.

## Installation
Install it through NPM

```
$ npm install --save nslocation
```

## Usage

```javascript
const NSLocation = require('nslocation');

NSLocation.getLocation()
    .then(latLon => {
        console.log(latLon);
        // => { lat: 45.4702979, lng: 9.1787528, altitude: 748.8176879882812, horizontalAccuracy: 65, verticalAccuracy: 10 }
    })
    .catch(ex => {
        console.error(ex);
        // Refer to the Exception Handling section.
    });
```

NSLocation exposes a single `getLocation` method, which by its turn returns a `Promise`. When resolved, the result is a single argument containing both `lat` and `lng`, representing latitude and longitude, accordingly; both expressed by a float value.

## macOS User Permission Prompt
During the first invocation to `getLocation`, macOS will display a dialog asking the user whether they want to allow the application to access location information or not:

![](https://www.dropbox.com/s/i6nfg547itpt7xg/NSLocation-PermissionDialog.png?dl=1)

Rejection will result in an `ELOCATIONDENIED` error.

## Exception Handling

In case  Location Services are unavailable, or another condition prevents the acquisition of location data, one of the following `Error`-like objects will be returned through the callback function provided through your `catch` call:

```javascript
{
    name: 'NLError',
    type: 'ENOLOCATIONSERVICES',
    message: 'Location Services is either disabled or not available.'
}
```

`name` will always return `NLError`, `type` indicates the reason why the promise was rejected, and `message` includes a humanized reason behind the failure, in case you don't want to go through the possible values for `type`:

`ENOLOCATIONSERVICES` indicates that Location Services is disabled or not available. From Apple documentation:
> The user can enable or disable location services from the Settings app by toggling the Location Services switch in General.

`ELOCATIONDENIED` indicates that the user has denied this application to access Location Services functions.

`ELOCATIONUNKNOWN` indicates that the underlying mechanism failed to acquire geographic information at this time. A further call to the `getLocation` function may either return the expected result, or
yield another `ELOCATIONUNKNOWN` error.

`EGETLOCATIONFAILED` indicates that an unknown error has occured.

## License

```
MIT License

Copyright (c) 2017 Victor Gama

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

```

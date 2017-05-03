var Bridge = require('./build/Release/nslocation.node');

var NLError = function NLError(type, message, extra) {
    Error.captureStackTrace(this, this.constructor);
    this.name = this.constructor.name;
    this.type = type;
    this.message = message;
    this.extra = extra;
}

module.exports = {
    getLocation: function() {
        return new Promise(function(resolve, reject) {
            try {
                var result = Bridge.getLocation();
                resolve(result);
            } catch(ex) {
                if(ex.message === 'ENOLOCATIONSERVICES') {
                    return reject(new NLError(ex.message, 'Location Services is either disabled or not available.'));
                } else if(ex.message === 'ELOCATIONDENIED') {
                    return reject(new NLError(ex.message, 'Current privacy options are preventing this application from receiving location data.'));
                } else if(ex.message === 'ELOCATIONUNKNOWN') {
                    return reject(new NLError(ex.message, 'Location services could not determine the current location. Further calls to getLocation may eventually return the position.'));
                } else if(ex.message === 'EGETLOCATIONFAILED') {
                    return reject(new NLError(ex.message, 'There was a problem obtaining location information.'));
                }
                return reject(ex);
            }
        });
    }
};

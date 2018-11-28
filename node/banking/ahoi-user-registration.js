// Licensed to the Apache Software Foundation (ASF) under one or more contributor
// license agreements; and to You under the Apache License, Version 2.0.

var request = require('request');

/**
 * Regiter a client with AHOI
 *
 * Must specify one of zipCode or latitude/longitude.
 *
 * @param registrationToken Registration Token
 * @return Installation ID
 */
function main(params) {
    console.log('input params:', params);
    
    const registrationToken = params.registrationToken;

    const host = params.host || 'banking-sandbox.starfinanz.de';
    const url = 'https://' + host + '/ahoi/api/v2/registration';

    console.log('url:', url);

    const promise = new Promise(function(resolve, reject) {
        const authorizationHeader = 'Bearer ' + registrationToken;
        request({
            url: url,
            method: "POST",
            headers: { Authorization: authorizationHeader },
            timeout: 30000
        }, function(error, response, body) {
            if (!error && response.statusCode >= 200 && response.statusCode < 300) {
                var j = JSON.parse(body);
                resolve(j);
            } else {
                console.log('error registering user with token ' + registrationToken);
                console.log('http status code:', (response || {}).statusCode);
                console.log('error:', error);
                console.log('body:', body);
                reject({
                    error: error,
                    response: response,
                    body: body
                });
            }
        });
    });

    return promise;
}
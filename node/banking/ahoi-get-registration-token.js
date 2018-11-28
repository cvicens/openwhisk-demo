// Licensed to the Apache Software Foundation (ASF) under one or more contributor
// license agreements; and to You under the Apache License, Version 2.0.

var request = require('request');

/**
 * Regiter a client with AHOI
 *
 * Must specify one of zipCode or latitude/longitude.
 *
 * @param clientId Client ID.
 * @param clientSecret Client Secret.
 * @return Registration object
 */
function main(params) {
    console.log('input params:', params);
    
    const clientId = params.clientId;
    const clientSecret = params.clientSecret;



    const host = params.host || 'banking-sandbox.starfinanz.de';
    const url = 'https://' + host + '/auth/v1/oauth/token?grant_type=client_credentials';

    console.log('url:', url);

    const promise = new Promise(function(resolve, reject) {
        request({
            url: url,
            method: "POST",
            auth: {
                username: clientId,
                password: clientSecret
            },
            timeout: 30000
        }, function(error, response, body) {
            if (!error && response.statusCode === 200) {
                var j = JSON.parse(body);
                resolve(j);
            } else {
                console.log('error registering ' + clientId);
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
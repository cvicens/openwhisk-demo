function main(params) {
    var name = params.name || 'Guest';
    var place = params.place || 'OpenShift Cloud Functions';
    return {payload: 'Welcome to ' + place + ', ' + name};
}
APP = function (a) {
    for (var a = a.split("."), b = window.APP, f = 0; f < a.length; f++) var i = a[f],
        b = b[i] || (b[i] = {});
    return b
};

APP('Postcard')
APP('Postcard.controllers')
APP('Postcard.views')
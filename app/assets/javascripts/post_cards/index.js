//= require_tree ./views
//= require ./router.js

// Kick off the app!
$(function() {
    "use strict";

    $.ajaxSetup({
        cache: false
    });

    APP.Postcard.Router = new APP.Postcard.controllers.PostCards ();

    Backbone.history.start({pushState: true, root: "/post_cards/"});

});
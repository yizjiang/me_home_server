(function(){

    APP.Postcard.controllers.PostCards = Backbone.Router.extend({

        routes: {
            "": "renderList"
        },

        initialize: function() {
        },

        renderList: function() {
            var postcardsList = new APP.Postcard.views.PostcardsList();
            $('#app').html(postcardsList.render().el);
        }

    });
})();

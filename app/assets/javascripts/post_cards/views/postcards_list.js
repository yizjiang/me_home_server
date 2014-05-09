(function(){

    APP.Postcard.views.PostcardsList = Backbone.View.extend({

        initialize: function() {
            this.template = ich.postcards_list;
        },

        render: function() {
            this.$el.html(this.template());
            return this;
        }
    });

})();

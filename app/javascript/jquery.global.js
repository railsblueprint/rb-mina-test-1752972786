import jQuery from 'jquery';
window.$ = window.jQuery = jQuery;

var $document = $(document);

$.turbo = {
    version: '2.1.0',
    isReady: false,
    use: function(load, fetch) {
        return $document.off('.turbo').on("" + load + ".turbo", this.onLoad).on("" + fetch + ".turbo", this.onFetch);
    },
    addCallback: function(callback) {
        // console.log("jQuery.global addCallback");
        // console.log("turbo.ready", $.turbo.isReady);

        if ($.turbo.isReady) {
            // console.log("Running delayed callback");
            callback($);
        }
        return $document.on('turbo:ready', function() {
            // console.log("Running delayed callback");
            return callback($);
        });
    },
    onLoad: function() {
        // console.log("jQuery.global onLoad");
        $.turbo.isReady = true;
        return $document.trigger('turbo:ready');
    },
    onFetch: function() {
        // console.log("jQuery.global onFetch");
        $.turbo.isReady = false;
        return true;
    },
    register: function() {
        // console.log("jQuery.global register");
        $(this.onLoad);
        return $.fn.ready = this.addCallback;
    }
};

$.turbo.register();

$.turbo.use('turbo:load', 'turbo:before-fetch-request');

export default $;


// make sure logging is available, even if firebug is not
function log() {
    if (window.console === undefined) {
        var record = jQuery ? function(msg) {
            var $body = arguments.callee.$body;
            if (!$body) {
                $body = arguments.callee.$body = jQuery('body').append('<br><b>Log:</b>');
            }
            $body.append('<br>'+msg);
        } : function(msg) {
            if (log.record === undefined) {
                log.record = [];
            }
            log.record.push(msg);
        };
        function isArray(obj) {
            return Object.prototype.toString.call(obj) === "[object Array]";
        }
        function toString(arg, depth) {
            if (arg === null || arg === undefined) {
                return '';
            } else if (depth > 1 || typeof arg == "string" ||
                       typeof arg == "number" || typeof arg == "boolean") {
                return arg.toString();
            } else if (arg.jquery) {
                var ctx = arg.context.nodeName.toLowerCase();
                ctx = (ctx == "#document" ? '' : ','+ctx);
                return "$("+arg.selector+ctx+")";
            } else if (arg.nodeName) {
                var out = arg.nodeName.toLowerCase();
                if ('id' in arg) {
                    out += '#'+arg['id'];
                }
                return out;
            } else if (isArray(arg)) {
                var out = '[';
                for (var i=0,m=arg.length; i<m; i++) {
                    out += toString(arg[i], depth + 1);
                    if (i != m-1) out += ',';
                }
                return out + ']';
            } else {
                var out = '{';
                for (var key in arg) {
                    out += key+'='+toString(arg[key], depth+1)+',';
                }
                return out.substring(0, out.length-1) + '}';
            }
        };
        window.console = {
            log: function() {
                var msg = '';
                try {
                    if (arguments.length > 1) {
                        for (var i=0,m=arguments.length; i<m; i++) {
                            msg += toString(arguments[i], 0)+' ';
                        }
                    } else {
                        msg = toString(arguments[0], 0);
                    }
                } catch(e) {
                    try {
                        msg += toString(e, 0);
                    } catch(f) {
                        msg += e;
                    }
                } finally {
                    record(msg);
                }
            }
        };
    }
    console.log.apply(console, arguments);
}
if (jQuery) {
    (function ($) {
        var $doc = $(document);

        var watch = function(type) {
            if (log.watch) {
                var c = log.watch.length;
                for (var i=0; i < c; i++) {
                    if (type.indexOf(log.watch[i]) === 0) {
                        if (!log.watching) {
                            log.watching = [type];
                        } else {
                            log.watching.push(type);
                        }
                        return true;
                    }
                }
            }
            return false;
        };

        var watching = function(type) {
            if (log.watching) {
                var c = log.watching.length;
                for (var i=0; i < c; i++) {
                    if (type == log.watching[i]) {
                        return true;
                    }
                }
            }
            return false;
        };

        // keep watched event history for examination in firebug
        log.watched = {};

        // override bind to watch for interesting events
        var _bind = $.fn.bind;
        $.fn.bind = function(type, data, fn) {
            if (!watching(type) && watch(type)) {
                _bind.apply($doc, [type, function(e) {
                    log.watched[e.timeStamp+':'+e.type] = e;
                    log(arguments);
                }]);
            }
            return _bind.apply(this, [type, data, fn]);
        };

        // be sure to log ajaxErrors
        $doc.ajaxError(function(event, xhr, ajaxOptions, error) {
            log("There was a jQuery ajax error: ", arguments);
            // beware mysterious json errors...
            try {
                var data = eval(xhr.responseText);
                log(data);
            } catch (e) {
                log(e);
            }
        });

    })(jQuery);
}

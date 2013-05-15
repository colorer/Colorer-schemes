TinyMCE_Control.prototype = {
        selection : null,

        settings : null,

        cleanup : null,

        _fixTrailingNbsp : function() {
                var s = this.selection, e = s.getFocusElement(), bm, v;
                var l = "\u00a0";

                if (e && tinyMCE.blockRegExp.test(e.nodeName) && e.firstChild) {
                        v = e.firstChild.nodeValue;

                        if (v && v.length > 1 && /(^\u00a0|\u00a0$)/.test(v)) {
                                e.firstChild.nodeValue = v.replace(/(^\u00a0|\u00a0$)/, '');
                                s.selectNode(e.firstChild, true, false, false); // Select and collapse
                        }
                }
        }
}

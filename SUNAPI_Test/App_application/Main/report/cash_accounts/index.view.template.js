define(["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    const url = require('std:url');
    const template = {
        properties: {
            'TCashAccount.$DetailsUrl': getDetailUrl
        },
    };
    exports.default = template;
    function getDetailUrl() {
        let filter = this.$parent.$ModelInfo.Filter;
        let params = {
            Period: filter.Period,
        };
        return this.Id + url.makeQueryString(params);
    }
});

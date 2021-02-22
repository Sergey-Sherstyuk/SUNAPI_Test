define(["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    const cmn = require('document/common');
    const url = require('std:url');
    const template = {
        properties: {
            'TBalance.$DetailsUrl': getDetailUrl
        },
        events: {},
        delegates: {
            fetchCompany: cmn.fetchCompany,
            fetchPartner: cmn.fetchPartner,
            fetchContract: cmn.fetchContract,
        },
        commands: {
            clearFilter(f) {
                f.Id = 0;
                f.Name = '';
            }
        }
    };
    exports.default = template;
    function getDetailUrl() {
        let filter = this.$parent.$ModelInfo.Filter;
        let params = {
            Period: filter.Period,
            Company: filter.Company.Id,
        };
        return this.Id + url.makeQueryString(params);
    }
});

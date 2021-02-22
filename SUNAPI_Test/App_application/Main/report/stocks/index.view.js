define(["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    const cmn = require('document/common');
    const utils = require('std:utils');
    const du = utils.date;
    const template = {
        properties: {
            "TRoot.$ReportDescr": reportDescr
        },
        delegates: {
            fetchStore: cmn.fetchStore,
            fetchCompany: cmn.fetchCompany,
        },
    };
    exports.default = template;
    function reportDescr() {
        const root = this;
        let descr = [];
        descr.push('@[Report.DateOn] ' + du.formatDate(root.Query.Date));
        if (root.Query.Store.Name)
            descr.push('@[FieldStore]: ' + root.Query.Store.Name);
        if (root.Query.Company.Name)
            descr.push('@[FieldCompany]: ' + root.Query.Company.Name);
        return descr.join(', ');
    }
});

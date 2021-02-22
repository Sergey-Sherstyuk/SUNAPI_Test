define(["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    const cmn = require('document/common');
    const template = {
        properties: {
            'TProductMove.$DocTypeDetailUrl': docTypeDetailUrl,
        },
        delegates: {
            fetchProduct: cmn.fetchProduct,
            fetchCompany: cmn.fetchCompany,
            fetchPartner: cmn.fetchPartner,
            fetchStore: cmn.fetchStore,
        },
        commands: {
            clearFilter(f) {
                f.Id = 0;
                f.Name = '';
            }
        }
    };
    exports.default = template;
    function docTypeDetailUrl() {
        return ('/document/' + this.DocType + '/edit').toLowerCase();
    }
});

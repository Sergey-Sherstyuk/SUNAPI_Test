define(["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    const cmn = require('document/common');
    const template = {
        properties: {
            'TOperation.$DocTypeDetailUrl': docTypeDetailUrl
        },
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
    function docTypeDetailUrl() {
        return ('/document/' + this.Type + '/edit').toLowerCase();
    }
});

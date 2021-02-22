define(["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    const cmn = require('document/common');
    const template = {
        delegates: {
            fetchCompany: cmn.fetchCompany,
            fetchCashAccount: cmn.fetchCashAccount,
            fetchPartner: cmn.fetchPartner,
            fetchOperation: cmn.fetchOperation,
            fetchExpenditure: cmn.fetchExpenditure,
        },
        commands: {
            clearFilter(f) {
                f.Id = 0;
                f.Name = '';
            }
        }
    };
    exports.default = template;
});

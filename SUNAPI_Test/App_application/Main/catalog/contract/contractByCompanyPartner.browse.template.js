define(["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    const template = {
        properties: {
            "TParam.$newContractParams"() {
                return {
                    Company: this.Company.Id,
                    Partner: this.Partner.Id
                };
            }
        },
    };
    exports.default = template;
});

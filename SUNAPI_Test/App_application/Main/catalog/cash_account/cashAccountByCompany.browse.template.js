define(["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    const template = {
        properties: {
            "TParam.$newCashAccountParams"() {
                return {
                    Company: this.Company.Id,
                };
            }
        },
        validators: {
            "Params.Company.Name": [{
                    valid: "notBlank",
                    msg: 'ZZZ'
                }]
        },
    };
    exports.default = template;
});

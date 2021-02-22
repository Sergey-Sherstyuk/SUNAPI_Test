define(["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    const template = {
        properties: {
            'TCashAccount.$Title'() {
                return 'Деталізація руху по рахунку: ' + this.Name + ' (' + this.Company + ')';
            }
        },
    };
    exports.default = template;
});

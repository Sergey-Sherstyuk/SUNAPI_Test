define(["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    const cmn = require('document/common');
    const template = {
        properties: {
            'TDocument.$Mark': cmn.docMark,
            'TDocument.$Icon': cmn.docIcon,
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

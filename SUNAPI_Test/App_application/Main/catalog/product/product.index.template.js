define(["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    const template = {
        commands: {
            clearFilterObject(f) {
                f.Id = 0;
                f.Name = '';
            }
        }
    };
    exports.default = template;
});

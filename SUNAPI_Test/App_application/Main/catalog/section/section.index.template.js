define(["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    const template = {
        events: {
            "Sections[].change": sectionChange
        }
    };
    exports.default = template;
    function isNameValid(section) {
        return section.Name.length > 3;
    }
    function sectionChange(sections) {
        sections.$vm.$reload();
    }
});

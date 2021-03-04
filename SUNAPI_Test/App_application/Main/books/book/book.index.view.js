define(["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    const template = {
        properties: {
            "TBook.$IsAuthorPresent": checkAuthor,
            "TBook.$Mark": getBookMark
        },
        commands: {
            clearFilter
        }
    };
    exports.default = template;
    function checkAuthor() {
        return this.Author.Id > 0;
    }
    function getBookMark() {
        return (this.Author.Id > 0) ? '' : 'warning';
    }
    function clearFilter(filter) {
        console.log(filter);
        filter.Fragment = null;
    }
});

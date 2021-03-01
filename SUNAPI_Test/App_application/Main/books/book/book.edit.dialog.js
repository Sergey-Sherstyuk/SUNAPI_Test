define(["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    const template = {
        delegates: {
            fetchAuthor
        }
    };
    exports.default = template;
    function fetchAuthor(author, searchText) {
        const ctrl = this.$ctrl;
        return ctrl.$invoke('fetchAuthor', { Search: searchText }, '/books/author');
    }
});

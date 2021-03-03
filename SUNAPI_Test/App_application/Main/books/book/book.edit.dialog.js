define(["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    const template = {
        properties: {
            "TBook.$ReverseName": getReverseName
        },
        validators: {
            "Book.Name": [{
                    valid: isNameValid,
                    msg: 'Наименование не должно быть пустым'
                }]
        },
        delegates: {
            fetchAuthor
        }
    };
    exports.default = template;
    function fetchAuthor(author, searchText) {
        const ctrl = this.$ctrl;
        return ctrl.$invoke('fetchAuthor', { Search: searchText }, '/books/author');
    }
    function isNameValid(book) {
        return book.Name.length > 3;
    }
    function getReverseName() {
        return this.Name.split('').reverse().join('');
    }
});

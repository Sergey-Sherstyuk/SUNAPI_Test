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
                    msg: 'Потрібно вказати назву книги. Назва має бути 2 символів'
                }],
            "Book.Author": [{
                    valid: "notBlank",
                    msg: 'Потрібно вказати автора',
                    severity: "warning"
                }]
        },
        delegates: {
            fetchAuthor,
            fetchPublisher
        },
        commands: {
            newAuthor
        }
    };
    exports.default = template;
    function fetchAuthor(author, searchText) {
        const ctrl = this.$ctrl;
        return ctrl.$invoke('fetchAuthor', { Search: searchText }, '/books/author');
    }
    function fetchPublisher(publisher, searchText) {
        const ctrl = this.$ctrl;
        return ctrl.$invoke('fetchPublisher', { Search: searchText }, '/books/publisher');
    }
    function isNameValid(book) {
        return book.Name.length > 2;
    }
    function getReverseName() {
        return this.Name.split('').reverse().join('');
    }
    function newAuthor(opts) {
        const ctrl = this.$ctrl;
        ctrl.$showDialog('/books/author/edit', { Id: 0 }, { Text: opts.text }).then(function (author) {
            console.dir(author);
            opts.elem.$merge(author);
        });
    }
});

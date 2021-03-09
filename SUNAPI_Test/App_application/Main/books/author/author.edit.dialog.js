define(["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    const template = {
        events: {
            "Model.load": modelLoad
        },
        validators: {
            "Author.Name": [{
                    valid: isNameValid,
                    msg: 'Потрібно вказати Ім`я автора. Ім`я автора має бути білше 3 символів'
                }]
        }
    };
    exports.default = template;
    function modelLoad(root) {
        if (root.Author.$isNew && root.Params.Text) {
            root.Author.Name = root.Params.Text;
            root.$defer(() => {
                root.$setDirty(true);
            });
        }
    }
    function isNameValid(book) {
        return book.Name.length > 3;
    }
});

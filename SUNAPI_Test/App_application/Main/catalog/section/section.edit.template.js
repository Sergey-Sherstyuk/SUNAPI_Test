define(["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    const template = {
        validators: {
            "Section.Name": [{
                    valid: isNameValid,
                    msg: 'Наименование не должно быть пустым'
                }]
        },
        events: {
            "Model.load": modelLoad
        }
    };
    exports.default = template;
    function isNameValid(section) {
        return section.Name.length > 3;
    }
    function modelLoad(root) {
        if (root.Params.Text) {
            root.Section.Name = root.Params.Text;
            root.$defer(() => {
                root.$setDirty(true);
            });
        }
    }
});

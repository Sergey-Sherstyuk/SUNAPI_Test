define(["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    const template = {
        validators: {
            "Operation.Name": [{
                    valid: isNameValid,
                    msg: 'Наименование не должно быть пустым'
                }]
        },
        events: {
            "Model.load": modelLoad
        }
    };
    exports.default = template;
    function isNameValid(expenditure) {
        return expenditure.Name.length > 3;
    }
    function modelLoad(root) {
        if (root.Params.Text) {
            root.Expenditure.Name = root.Params.Text;
            root.$defer(() => {
                root.$setDirty(true);
            });
        }
    }
});

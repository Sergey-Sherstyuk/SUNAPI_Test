define(["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    const template = {
        validators: {
            "Unit.Name": [{
                    valid: isNameValid,
                    msg: 'Наименование не должно быть пустым'
                }]
        },
        events: {
            "Model.load": modelLoad
        }
    };
    exports.default = template;
    function isNameValid(unit) {
        return unit.Name.length > 0;
    }
    function modelLoad(root) {
        if (root.Params.Text) {
            root.Unit.Name = root.Params.Text;
            root.$defer(() => {
                root.$setDirty(true);
            });
        }
    }
});

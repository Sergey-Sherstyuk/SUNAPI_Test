define(["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    const template = {
        validators: {
            "Contract.Name": [{
                    valid: isNameValid,
                    msg: 'Наименование не должно быть пустым'
                }]
        },
        events: {
            "Model.load": modelLoad
        }
    };
    exports.default = template;
    function isNameValid(contract) {
        return contract.Name.length > 3;
    }
    function modelLoad(root) {
        if (root.Contract.$isNew) {
            if (root.Params.Text) {
                root.Contract.Name = root.Params.Text;
                root.$defer(() => {
                    root.$setDirty(true);
                });
            }
            if (root.Params.Company.Id) {
                root.Contract.Company.Id = root.Params.Company.Id;
                root.Contract.Company.Name = root.Params.Company.Name;
                root.$defer(() => {
                    root.$setDirty(true);
                });
            }
            if (root.Params.Partner.Id) {
                root.Contract.Partner.Id = root.Params.Partner.Id;
                root.Contract.Partner.Name = root.Params.Partner.Name;
                root.$defer(() => {
                    root.$setDirty(true);
                });
            }
        }
    }
});

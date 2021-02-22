define(["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    const template = {
        validators: {
            "Company.Name": [{
                    valid: isNameValid,
                    msg: '@[ValidatorNameEmpty]'
                }]
        },
        events: {
            "Model.load": modelLoad
        }
    };
    exports.default = template;
    function isNameValid(company) {
        return company.Name.length > 3;
    }
    function modelLoad(root) {
        if (root.Params.Text) {
            root.Company.Name = root.Params.Text;
            root.$defer(() => {
                root.$setDirty(true);
            });
        }
    }
});

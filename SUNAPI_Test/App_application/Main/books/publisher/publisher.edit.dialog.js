define(["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    const template = {
        events: {
            "Model.load": modelLoad
        }
    };
    exports.default = template;
    function modelLoad(root) {
        if (root.Publisher.$isNew && root.Params.Text) {
            root.Publisher.Name = root.Params.Text;
            root.$defer(() => {
                root.$setDirty(true);
            });
        }
    }
});

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
        if (root.Author.$isNew && root.Params.Text) {
            root.Author.Name = root.Params.Text;
            root.$defer(() => {
                root.$setDirty(true);
            });
        }
    }
});

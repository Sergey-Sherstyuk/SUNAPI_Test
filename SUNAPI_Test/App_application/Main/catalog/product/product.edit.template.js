define(["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    const template = {
        properties: {
            "TPriceType.$browsePriceHistoryParams": browsePriceHistoryParams
        },
        validators: {
            "Product.Name": [{
                    valid: "notBlank",
                    msg: 'Наименование не должно быть пустым'
                }]
        },
        events: {
            "Model.load": modelLoad
        }
    };
    exports.default = template;
    function modelLoad(root) {
        if (root.Params.Text) {
            root.Product.Name = root.Params.Text;
            root.$defer(() => {
                root.$setDirty(true);
            });
        }
    }
    function browsePriceHistoryParams() {
        let root = this.$parent.$parent;
        return {
            Product: root.Product.Id,
        };
    }
});

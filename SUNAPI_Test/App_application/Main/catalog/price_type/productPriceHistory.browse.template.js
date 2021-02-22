define(["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    const template = {
        properties: {
            "TRoot.$title": pageTitle,
            "TRoot.$editPriceParams": editPriceParams
        },
    };
    exports.default = template;
    function editPriceParams() {
        let root = this;
        return {
            Product: root.Product.Id,
            PriceType: root.PriceType.Id,
        };
    }
    function pageTitle() {
        let root = this;
        return root.Product.Name + ' - ' + root.PriceType.Name;
    }
});

define(["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    const template = {
        properties: {
            'TRoot.$Products': getSelectedSectionProducts
        },
        events: {
            "Model.load": modelLoad,
            "Sections[].select": sectionSelected,
        }
    };
    exports.default = template;
    function modelLoad(root) {
        root.Sections.forEach(section => {
            section.$expanded = true;
        });
    }
    function getSelectedSectionProducts() {
        let root = this;
        return !!root.Sections.$selected ? root.Sections.$selected.Products : [];
    }
    function sectionSelected(arg1, arg2) {
        const root = this;
        let section = root.Sections.$selected;
        console.log(section.Id);
        section.Products.$load();
    }
    function getProducts() {
        return [];
        const root = this;
        let section = root.Sections.$selected;
        console.log(section.Id);
        section.Products.$load();
        return section.Products;
    }
});

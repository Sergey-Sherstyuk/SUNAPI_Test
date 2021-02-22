const template: Template = {
	properties: {
		'TRoot.$Products': getSelectedSectionProducts
	},
	events: {
		"Model.load": modelLoad,
		"Sections[].select": sectionSelected,
	}
};

export default template;

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

	//	let addr = root.Agent.Address;
	//	let cntry = root.Countries.find(c => c.Code === addr.Country);
	//	if (!cntry) return null;
	//	cntry.Cities.$load(); // ensure lazy
	//	return cntry.Cities;
}

const template: Template = {
	properties: {
		"TRoot.$title": pageTitle,
		"TRoot.$editPriceParams": editPriceParams
	},
};

export default template;

function editPriceParams() {
	let root = this;
	return {
		Product: root.Product.Id,
		PriceType: root.PriceType.Id,
	}
}

function pageTitle() {
	let root = this;
	return root.Product.Name + ' - ' + root.PriceType.Name;
}

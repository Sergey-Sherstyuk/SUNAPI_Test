const template: Template = {
	properties: {
		"TPriceType.$browsePriceHistoryParams": browsePriceHistoryParams
	},
	validators: {
		"Product.Name": [{
			valid: StdValidator.notBlank,
			msg: 'Наименование не должно быть пустым'
		}]
	},
	events: {
		"Model.load": modelLoad
	}
};

export default template;

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
	}
}

const template: Template = {
	validators: {
		"Price.Name": [{
			valid: isNameValid,
			msg: 'Наименование не должно быть пустым'
		}]
	},
	events: {
		"Model.load": modelLoad
	}
};

export default template;

function isNameValid(price) {
	return price.Name.length > 3;
}

function modelLoad(root) {
	if (root.Params.Text) {
		root.Price.Name = root.Params.Text;
		root.$defer(() => {
			root.$setDirty(true);
		});
	}
}

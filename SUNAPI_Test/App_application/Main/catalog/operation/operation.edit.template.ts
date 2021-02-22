const template: Template = {
	validators: {
		"Operation.Name": [{
			valid: isNameValid,
			msg: 'Наименование не должно быть пустым'
		}]
	},
	events: {
		"Model.load": modelLoad
	}
};

export default template;

function isNameValid(expenditure) {
	return expenditure.Name.length > 3;
}

function modelLoad(root) {
	if (root.Params.Text) {
		root.Expenditure.Name = root.Params.Text;
		root.$defer(() => {
			root.$setDirty(true);
		});
	}
}

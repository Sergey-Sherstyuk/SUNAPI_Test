const template: Template = {
	validators: {
		"Unit.Name": [{
			valid: isNameValid,
			msg: 'Наименование не должно быть пустым'
		}]
	},
	events: {
		"Model.load": modelLoad
	}
};

export default template;

function isNameValid(unit) {
	return unit.Name.length > 0;
}

function modelLoad(root) {
	if (root.Params.Text) {
		root.Unit.Name = root.Params.Text;
		root.$defer(() => {
			root.$setDirty(true);
		});
	}
}

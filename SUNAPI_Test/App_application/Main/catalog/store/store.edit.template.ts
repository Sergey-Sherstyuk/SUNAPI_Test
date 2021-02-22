const template: Template = {
	validators: {
		"Store.Name": [{
			valid: isNameValid,
			msg: 'Наименование не должно быть пустым'
		}]
	},
	events: {
		"Model.load": modelLoad
	}
};

export default template;

function isNameValid(store) {
	return store.Name.length > 3;
}

function modelLoad(root) {
	if (root.Params.Text) {
		root.Store.Name = root.Params.Text;
		root.$defer(() => {
			root.$setDirty(true);
		});
	}
}

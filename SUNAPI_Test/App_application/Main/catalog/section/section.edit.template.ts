const template: Template = {
	validators: {
		"Section.Name": [{
			valid: isNameValid,
			msg: 'Наименование не должно быть пустым'
		}]
	},
	events: {
		"Model.load": modelLoad
	}
};

export default template;

function isNameValid(section) {
	return section.Name.length > 3;
}

function modelLoad(root) {
	if (root.Params.Text) {
		root.Section.Name = root.Params.Text;
		root.$defer(() => {
			root.$setDirty(true);
		});
	}
}

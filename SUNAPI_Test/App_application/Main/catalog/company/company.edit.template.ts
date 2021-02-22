const template: Template = {
	validators: {
		"Company.Name": [{
			valid: isNameValid,
			msg: '@[ValidatorNameEmpty]'
		}]
	},
	events: {
		"Model.load": modelLoad
	}
};

export default template;

function isNameValid(company) {
	return company.Name.length > 3;
}

function modelLoad(root) {
	if (root.Params.Text) {
		root.Company.Name = root.Params.Text;
		root.$defer(() => {
			root.$setDirty(true);
		});
	}
}

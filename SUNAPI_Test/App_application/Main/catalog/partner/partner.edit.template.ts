const template: Template = {
	validators: {
		"Partner.Name": [{
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
		root.Partner.Name = root.Params.Text;
		root.$defer(() => {
			root.$setDirty(true);
		});
	}
}

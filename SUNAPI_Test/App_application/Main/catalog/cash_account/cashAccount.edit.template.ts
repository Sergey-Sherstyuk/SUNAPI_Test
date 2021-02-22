const template: Template = {
	validators: {
		"CashAccount.Name": [{
			valid: isNameValid,
			msg: 'Наименование не должно быть пустым'
		}]
	},
	events: {
		"Model.load": modelLoad
	}
};

export default template;

function isNameValid(cashAccount) {
	return cashAccount.Name.length > 3;
}

function modelLoad(root) {
	if (root.CashAccount.$isNew) {
		if (root.Params.Text) {
			root.CashAccount.Name = root.Params.Text;
			root.$defer(() => {
				root.$setDirty(true);
			});
		}
		if (root.Params.Company.Id) {
			root.CashAccount.Company.Id = root.Params.Company.Id;
			root.CashAccount.Company.Name = root.Params.Company.Name;
			root.$defer(() => {
				root.$setDirty(true);
			});
		}
	}
}
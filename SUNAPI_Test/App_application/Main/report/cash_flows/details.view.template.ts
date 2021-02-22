const cmn = require('document/common');

const template: Template = {
	delegates: {
		fetchCompany: cmn.fetchCompany,
		fetchCashAccount: cmn.fetchCashAccount,
		fetchPartner: cmn.fetchPartner,
		fetchOperation: cmn.fetchOperation,
		fetchExpenditure: cmn.fetchExpenditure,
	},
	commands: {
		clearFilter(f) {
			f.Id = 0;
			f.Name = ''
		}
	}
};

export default template;

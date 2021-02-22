const cmn = require('document/common');
const url = require('std:url');

const template: Template = {
	properties: {
		'TCashFlow.$DetailUrlOperation': getDetailUrlOperation,
		'TCashFlow.$DetailUrlExpenditure': getDetailUrlExpenditure,
		'TCashFlow.$DetailUrlFull': getDetailUrlFull,
	},
	events: {
	},
	delegates: {
		fetchCompany: cmn.fetchCompany,
		fetchCashAccount: cmn.fetchCashAccount,
		fetchPartner: cmn.fetchPartner,
	},
	commands: {
		clearFilter(f) {
			f.Id = 0;
			f.Name = ''
		}
	}
};

export default template;

function getDetailUrlOperation() {
	let filter = this.$parent.$ModelInfo.Filter;
	let params = {
		Period: filter.Period,
		Company: filter.Company.Id,
		CashAccount: filter.CashAccount.Id,
		Partner: filter.Partner.Id,
		Operation: this.OperationId,
	};
	return '0' + url.makeQueryString(params);
}

function getDetailUrlExpenditure() {
	let filter = this.$parent.$ModelInfo.Filter;
	let params = {
		Period: filter.Period,
		Company: filter.Company.Id,
		CashAccount: filter.CashAccount.Id,
		Partner: filter.Partner.Id,
		Expenditure: this.ExpenditureId,
	};
	return '0' + url.makeQueryString(params);
}

function getDetailUrlFull() {
	let filter = this.$parent.$ModelInfo.Filter;
	let params = {
		Period: filter.Period,
		Company: filter.Company.Id,
		CashAccount: filter.CashAccount.Id,
		Partner: filter.Partner.Id,
		Operation: this.OperationId,
		Expenditure: this.ExpenditureId,
	};
	return '0' + url.makeQueryString(params);
}

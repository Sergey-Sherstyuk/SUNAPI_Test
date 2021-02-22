const cmn = require('document/common');
const url = require('std:url');

const template: Template = {
	properties: {
		'TBalance.$DetailsUrl': getDetailUrl
	},
	events: {
	},
	delegates: {
		fetchCompany: cmn.fetchCompany,
		fetchPartner: cmn.fetchPartner,
		fetchContract: cmn.fetchContract,
	},
	commands: {
		clearFilter(f) {
			f.Id = 0;
			f.Name = ''
		}
	}
};

export default template;

function getDetailUrl() {
	let filter = this.$parent.$ModelInfo.Filter;
	let params = {
		Period: filter.Period,
		Company: filter.Company.Id,
	};
	return this.Id + url.makeQueryString(params);
}

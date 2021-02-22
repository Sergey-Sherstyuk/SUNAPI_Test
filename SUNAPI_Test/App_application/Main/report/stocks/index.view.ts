const cmn = require('document/common');
const utils: Utils = require('std:utils');
const du = utils.date;

const template: Template = {
	properties: {
		"TRoot.$ReportDescr": reportDescr
	},
	delegates: {
		fetchStore: cmn.fetchStore,
		fetchCompany: cmn.fetchCompany,
	},
};



export default template;

function reportDescr() {
	const root = this;
	let descr = [];

	descr.push('@[Report.DateOn] ' + du.formatDate(root.Query.Date));

	if (root.Query.Store.Name)
		descr.push('@[FieldStore]: ' + root.Query.Store.Name);

	if (root.Query.Company.Name)
		descr.push('@[FieldCompany]: ' + root.Query.Company.Name);

	return descr.join(', ');
}
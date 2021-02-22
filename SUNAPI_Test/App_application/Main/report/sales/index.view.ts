const cmn = require('document/common');
const utils: Utils = require('std:utils');
const du = utils.date;

const template: Template = {
	properties: {
		"TRoot.$ReportDescr": reportDescr
	},
	delegates: {
		fetchPartner: cmn.fetchPartner,
		fetchCompany: cmn.fetchCompany,
	},
};

export default template;

function reportDescr() {
	const root = this;
	let descr = [];

	descr.push( '@[Report.DatePeriod] @[Report.DateFrom] ' + du.formatDate(root.Query.Period.From) + ' @[Report.DateTo] ' + du.formatDate(root.Query.Period.To) );

	if (root.Query.Partner.Name)
		descr.push('@[FieldPartner]: ' + root.Query.Partner.Name);

	if (root.Query.Company.Name)
		descr.push('@[FieldCompany]: ' + root.Query.Company.Name);

	return descr.join(', ');
}
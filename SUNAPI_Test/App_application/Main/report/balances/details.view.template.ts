const cmn = require('document/common');

const template: Template = {
	properties: {
		'TOperation.$DocTypeDetailUrl': docTypeDetailUrl
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

function docTypeDetailUrl() {
	return ('/document/' + this.Type + '/edit').toLowerCase();
}

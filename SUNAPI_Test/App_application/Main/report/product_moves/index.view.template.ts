const cmn = require('document/common');

const template: Template = {
	properties: {
		'TProductMove.$DocTypeDetailUrl': docTypeDetailUrl,
	},
	delegates: {
		fetchProduct: cmn.fetchProduct,
		fetchCompany: cmn.fetchCompany,
		fetchPartner: cmn.fetchPartner,
		fetchStore: cmn.fetchStore,
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
	return ('/document/' + this.DocType + '/edit').toLowerCase();
}

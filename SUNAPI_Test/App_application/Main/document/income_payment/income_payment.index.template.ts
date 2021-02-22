const cmn = require('document/common');

const template: Template = {
	properties: {
		'TDocument.$Mark': cmn.docMark,
		'TDocument.$Icon': cmn.docIcon,
	},
	commands: {
		clearFilter(f) {
			f.Id = 0;
			f.Name = ''
		}
	}
};

export default template;

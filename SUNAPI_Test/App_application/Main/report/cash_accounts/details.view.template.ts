const template: Template = {
	properties: {
		'TCashAccount.$Title'() {
			return 'Деталізація руху по рахунку: ' + this.Name + ' (' + this.Company + ')';
		}
	},
	
};

export default template;

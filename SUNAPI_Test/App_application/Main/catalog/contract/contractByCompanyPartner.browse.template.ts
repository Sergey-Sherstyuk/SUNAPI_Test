const template: Template = {
	properties: {
		"TParam.$newContractParams"() {
			return {
				Company: this.Company.Id,
				Partner: this.Partner.Id
			}
		}
	},
};

export default template;

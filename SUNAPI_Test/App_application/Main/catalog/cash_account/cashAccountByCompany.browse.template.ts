const template: Template = {
	properties: {
		"TParam.$newCashAccountParams"() {
			return {
				Company: this.Company.Id,
			}
		}
	},
	validators: {
		"Params.Company.Name": [{
			valid: StdValidator.notBlank,
			msg: 'ZZZ'
		}]
	},

};

export default template;

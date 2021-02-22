const url = require('std:url');

const template: Template = {
	properties: {
		'TCashAccount.$DetailsUrl': getDetailUrl
	},
};

export default template;

function getDetailUrl() {
	let filter = this.$parent.$ModelInfo.Filter;
	let params = {
		Period: filter.Period,
	};
	return this.Id + url.makeQueryString(params);
}

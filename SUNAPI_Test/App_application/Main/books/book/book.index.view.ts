const template: Template = {
	properties: {
		"TBook.$IsAuthorPresent": checkAuthor,
		"TBook.$Mark": getBookMark
	},
	commands: {
		clearFilter
	}
};

export default template;

function checkAuthor() {
	return this.Author.Id > 0;
}

function getBookMark() {
	return (this.Author.Id > 0) ? '' : 'warning';
}

function clearFilter(filter) {
	console.log(filter);
	filter.Fragment = null;
}

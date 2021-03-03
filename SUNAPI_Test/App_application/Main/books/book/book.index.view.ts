const template: Template = {
	properties: {
		"TBook.$IsAuthorPresent": checkAuthor,
		"TBook.$Mark": getBookMark
	},
};

export default template;

function checkAuthor() {
	return this.Author.Id > 0;
}

function getBookMark() {
	return (this.Author.Id > 0) ? '' : 'warning';
}

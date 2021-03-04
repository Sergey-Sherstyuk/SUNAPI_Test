const template: Template = {
	properties: {
		"TBook.$ReverseName": getReverseName
	},
	validators: {
		"Book.Name": "Потрібно заповнити назву",
		//"Book.Name": [{
		//	valid: isNameValid,
		//	msg: "Потрібно заповнити назву"
		//}],
		// "Book.Author": [{
		//	valid: StdValidator.notBlank,
		//	msg: 'Потрібно вказати автора',
		//	severity: Severity.warning
		//}]
	},
	delegates: {
		fetchAuthor
	},
	commands: {
		newAuthor
	}
};

export default template;

function fetchAuthor(author, searchText) {
	const ctrl = this.$ctrl;
	return ctrl.$invoke('fetchAuthor', { Search: searchText }, '/books/author');
}

function isNameValid(book) {
	return book.Name.length > 3;
}

function getReverseName() {
	return this.Name.split('').reverse().join('');
}

function newAuthor(opts) {
	const ctrl = this.$ctrl;
	ctrl.$showDialog('/books/author/edit', { Id: 0 }, { Text: opts.text }).then(function (author) {
		console.dir(author);
		opts.elem.$merge(author);
	});
}

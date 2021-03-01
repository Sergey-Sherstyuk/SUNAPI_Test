const template: Template = {
	delegates: {
		fetchAuthor
	}
};

export default template;

function fetchAuthor(author, searchText) {
	const ctrl = this.$ctrl;
	return ctrl.$invoke('fetchAuthor', { Search: searchText }, '/books/author');
}
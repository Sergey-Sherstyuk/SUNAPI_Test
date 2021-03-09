const template: Template = {
	events: {
		"Model.load": modelLoad
	},
	validators: {
		"Author.Name": [{
			valid: isNameValid,
			msg: 'Потрібно вказати Ім`я автора. Ім`я автора має бути білше 3 символів'
		}]
	}
};

export default template;

function modelLoad(root) {
	if (root.Author.$isNew && root.Params.Text) {
		root.Author.Name = root.Params.Text;
		root.$defer(() => {
			root.$setDirty(true);
		});
	}
}

function isNameValid(book) {
	return book.Name.length > 3;
}
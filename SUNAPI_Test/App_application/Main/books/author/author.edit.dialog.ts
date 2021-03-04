const template: Template = {
	events: {
		"Model.load": modelLoad
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

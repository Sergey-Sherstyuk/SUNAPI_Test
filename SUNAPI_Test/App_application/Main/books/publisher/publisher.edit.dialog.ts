const template: Template = {
	events: {
		"Model.load": modelLoad
	}
};

export default template;

function modelLoad(root) {
	if (root.Publisher.$isNew && root.Params.Text) {
		root.Publisher.Name = root.Params.Text;
		root.$defer(() => {
			root.$setDirty(true);
		});
	}
}
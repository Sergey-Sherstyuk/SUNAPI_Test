const template: Template = {
	commands: {
		clearFilterObject(f) {
			f.Id = 0;
			f.Name = ''
		}
	}
};

export default template;

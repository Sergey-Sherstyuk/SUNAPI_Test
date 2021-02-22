const template: Template = {
	events: {
		"Sections[].change": sectionChange
	}
};

export default template;

function isNameValid(section) {
	return section.Name.length > 3;
}

function sectionChange(sections) {
	sections.$vm.$reload();
}

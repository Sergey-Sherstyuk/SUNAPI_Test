const template: Template = {
    properties: {
        "TBook.$IsAuthorPresent": checkAuthor,
        "TBook.$Mark": getBookMark
    },
    commands: {
        clearFilter,
        clearFilterObject(f) {
            f.Id = 0;
            f.Name = ''
        }
    }
 };

export default template;

function checkAuthor() {
    return this.Author.Id > 0;
}

function getBookMark() {
    return (this.Price == 0) ? 'error' :
           ((this.Price ^ 0) === this.Price) ? '' : 'warning';
} 

function clearFilter(filter) {
    filter.Fragment = null;
}
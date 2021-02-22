const template = {
    commands: {
        clearFilter(f) {
            f.Id = 0;
            f.Name = '';
        }
    }
};
module.exports = template;

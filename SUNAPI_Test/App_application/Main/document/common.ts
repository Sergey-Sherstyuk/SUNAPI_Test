/* document common module */

const utils = require('std:utils');
const du = utils.date;

const module = {
	// properties:
	docSum,
	docSumGoods,
	docSumServices,
	rowCntGoods,
	rowCntServices,
	rowSum: { get: getRowSum, set: setRowSum },
	browseContractParams,
	browseCashAccountParams,
	docMark,
	docIcon,
	docTreeMark,
	docCanCreate,

	// events:
	findArticle,
	documentCreate,
	docCompanyChanged,
	docPartnerChanged,
	docRowAdded,
	docRowChangedSetPriceFromStocksPrice,

	//delegates: 
	fetchPartner,
	fetchProduct,
	fetchStore,
	fetchCompany,
	fetchContract,
	fetchCashAccount,
	fetchExpenditure,
	fetchOperation,
	fetchPriceType,

	// commands:
	newPartner,
	newProduct,
	newStore,
	newCompany,
	newContract,
	newCashAccount,
	docApply: {
		saveRequired: true,
		validRequired: true,
		confirm: '@[Sure.ApplyDocument]',
		exec: applyDocument
	},
	docUnApply: {
		confirm: '@[Sure.UnApplyDocument]',
		exec: unApplyDocument
	},
	appendRowGoods,
	appendRowService,
	createDocInvoice,
	createDocIncomeOrder,
	createDocOutgoingOrder,
	createDocIncomeInvoice,
	createDocOutgoingInvoice,
	createDocIncomePayment,
	createDocOutgoingPayment,
};

export default module;

// Properties
function docSum() {
	return this.Rows.reduce((p, c) => p + c.Sum, 0);
}
function docSumGoods() {
	return this.Rows.reduce((p, c) => p + (c.Product.IsService ? 0 : c.Sum), 0);
}
function docSumServices() {
	return this.Rows.reduce((p, c) => p + (c.Product.IsService ? c.Sum : 0), 0);
}
function rowCntGoods() {
	return this.Rows.reduce((p, c) => p + (c.Product.IsService ? 0 : 1), 0);
}
function rowCntServices() {
	return this.Rows.reduce((p, c) => p + (c.Product.IsService ? 1 : 0), 0);
}

function getRowSum() {
	return +(this.Price * this.Qty).toFixed(2);
}
function setRowSum(value) {
	if (this.Qty)
		this.Price = +(value / this.Qty).toFixed(2);
	else
		this.Pirce = 0;
}

function browseContractParams() {
	let doc = this;
	return {
		Company: doc.Company.Id,
		Partner: doc.Partner.Id
	}
}

function browseCashAccountParams() {
	let doc = this;
	return {
		Company: doc.Company.Id,
		Date: doc.Date
	}
}

function docMark() {
	return this.Done ? 'success'
		: this.Deleted ? 'danger'
		: null;
}

function docIcon() {
	return this.Done ? 'success-green'
		: this.Deleted ? 'delete-red'
		: 'circle';
}

function docTreeMark() {
	return this.Done ? 'success' : null;
}

function docCanCreate() {

	let docType = this.Type.trim();
	let avlTypes = {};

	let allTypes = {
		Available: false,
		OutgoingOrder: false,
		Invoice: false,
		OutgoingInvoice: false,
		IncomePayment: false,
	};

	switch (docType) {
		case 'INVOICE':
			avlTypes = {
				Available: true,
				OutgoingInvoice: true,
				IncomePayment: true
			};
			break;
		case 'INCOME_ORDER':
			avlTypes = {
				Available: true,
				IncomeInvoice: true,
				OutgoingPayment: true
			};
			break;
		case 'OUTGOING_ORDER':
			avlTypes = {
				Available: true,
				Invoice: true,
				OutgoingInvoice: true,
				IncomePayment: true,
				IncomeOrder: true,
				IncomeInvoice: true
			};
			break;
		case 'INCOME_INVOICE':
			avlTypes = {
				Available: true,
				OutgoingPayment: true
			};
			break;
		case 'OUTGOING_INVOICE':
			avlTypes = {
				Available: true,
				IncomePayment: true
			};
			break;
		case 'INCOME_PAYMENT':
			avlTypes = {
				Available: false,
			};
			break;
		case 'OUTGOING_PAYMENT':
			avlTypes = {
				Available: false,
			};
			break;
	}

	let DocCanCreate = { ...allTypes, ...avlTypes };

	return DocCanCreate;
}

// Events
function documentCreate(doc) {
	// doc.Date = du.today();
	// doc.Date = new Date();

	// To fix LocalTime
	let d = new Date();
	let localDiff = d.getTimezoneOffset() * 60000 / 3600000;
	d.setHours(d.getHours() - localDiff);
	doc.Date = d;
}

function docCompanyChanged(doc) {
	doc.Number = '';
	doc.Contract.Id = 0;
	doc.Contract.Name = '';
	doc.CashAccount.Id = 0;
	doc.CashAccount.Name = '';
	doc.CashAccountFrom.Id = 0;
	doc.CashAccountFrom.Name = '';
	doc.CashAccountTo.Id = 0;
	doc.CashAccountTo.Name = '';
}

function docPartnerChanged(doc) {
	doc.Contract.Id = 0;
	doc.Contract.Name = '';
}

function docRowAdded(arr, row) {
	row.Qty = 1
}

function findArticle(product) {
	const vm = product.$vm;
	const row = product.$parent;
	const dat = { Article: product.Article };
	vm.$invoke('findArticle', dat, '/catalog/product').then(r => {
		if ('Product' in r)
			row.Product = r.Product;
		else
			row.Product.$empty();
	});
}

function docRowChangedSetPriceFromStocksPrice(row, product) {
	row.Price = row.Product.Price;
	row.Product.Price = null;
}

// Delegates
function fetchPartner(partner, searchText) {
	const ctrl = this.$ctrl;
	return ctrl.$invoke('fetchPartner', { Search: searchText }, '/catalog/partner');
	//return [];
}

function fetchProduct(product, searchText) {
	const ctrl = this.$ctrl;
	return ctrl.$invoke('fetchProduct', { Search: searchText }, '/catalog/product');
}

function fetchStore(store, searchText) {
	const ctrl = this.$ctrl;
	return ctrl.$invoke('fetchStore', { Search: searchText }, '/catalog/store');
}

function fetchCompany(company, searchText) {
	const ctrl = this.$ctrl;
	return ctrl.$invoke('fetchCompany', { Search: searchText }, '/catalog/company');
}

function fetchContract(contract, searchText) {
	const ctrl = this.$ctrl;
	return ctrl.$invoke('fetchContract', { Search: searchText }, '/catalog/contract');
}

function fetchCashAccount(cashAccount, searchText) {
	const ctrl = this.$ctrl;
	return ctrl.$invoke('fetchCashAccount', { Search: searchText }, '/catalog/cash_account');
}

function fetchExpenditure(Expenditure, searchText) {
	const ctrl = this.$ctrl;
	return ctrl.$invoke('fetchExpenditure', { Search: searchText }, '/catalog/expenditure');
}

function fetchOperation(Operation, searchText) {
	const ctrl = this.$ctrl;
	return ctrl.$invoke('fetchOperation', { Search: searchText }, '/catalog/operation');
}

function fetchPriceType(priceType, searchText) {
	const ctrl = this.$ctrl;
	return ctrl.$invoke('fetchPriceType', { Search: searchText }, '/catalog/price_type');
}

// Document Commands
async function applyDocument(doc) {
	const vm = doc.$vm;
	await vm.$invoke('apply', { Id: doc.Id }, '/document');
	vm.$requery();
}

async function unApplyDocument(doc) {
	const vm = doc.$vm;
	await vm.$invoke('unApply', { Id: doc.Id }, '/document');
	vm.$requery();
}

function newPartner(opts) {
	const ctrl = this.$ctrl;
	ctrl.$showDialog('/catalog/partner/edit', { Id: 0 }, { Text: opts.text }).then(function (ag) {
		console.dir(ag);
		opts.elem.$merge(ag);
	});
}

function newProduct(opts) {
	const ctrl = this.$ctrl;
	ctrl.$showDialog('/catalog/product/edit', { Id: 0 }, { Text: opts.text }).then(function (product) {
		console.dir(product);
		opts.elem.$merge(product);
	});
}

function newStore(opts) {
	const ctrl = this.$ctrl;
	ctrl.$showDialog('/catalog/store/edit', { Id: 0 }, { Text: opts.text }).then(function (store) {
		console.dir(store);
		opts.elem.$merge(store);
	});
}

function newCompany(opts) {
	const ctrl = this.$ctrl;
	ctrl.$showDialog('/catalog/company/edit', { Id: 0 }, { Text: opts.text }).then(function (company) {
		console.dir(company);
		opts.elem.$merge(company);
	});
}

function newContract(opts) {
	const ctrl = this.$ctrl;
	ctrl.$showDialog('/catalog/contract/edit', { Id: 0 }, { Text: opts.text }).then(function (contract) {
		console.dir(contract);
		opts.elem.$merge(contract);
	});
}

function newCashAccount(opts) {
	const ctrl = this.$ctrl;
	ctrl.$showDialog('/catalog/cash_account/edit', { Id: 0 }, { Text: opts.text }).then(function (cashAccount) {
		console.dir(cashAccount);
		opts.elem.$merge(cashAccount);
	});
}

function appendRowGoods(rows) {
	let newItem = rows.$append();
	newItem.Product.IsService = false;
}

function appendRowService(rows) {
	let newItem = rows.$append();
	newItem.Product.IsService = true;
}


async function createDocInvoice(doc) {
	// vm.$alert('Еще не реализовано');
	const vm = doc.$vm;
	let result = await vm.$invoke('DocumentAddChildCopy', { Id: doc.Id, Type: 'INVOICE' });
	if (result.Document) {
		vm.$navigate('/document/invoice/edit', result.Document.Id)
	}
}

async function createDocIncomeOrder(doc) {
	const vm = doc.$vm;
	let result = await vm.$invoke('DocumentAddChildCopy', { Id: doc.Id, Type: 'INCOME_ORDER' });
	if (result.Document) {
		vm.$navigate('/document/income_order/edit', result.Document.Id)
	}
}

async function createDocOutgoingOrder(doc) {
	const vm = doc.$vm;
	let result = await vm.$invoke('DocumentAddChildCopy', { Id: doc.Id, Type: 'OUTGOING_ORDER' });
	if (result.Document) {
		vm.$navigate('/document/outgoing_order/edit', result.Document.Id)
	}
}

async function createDocIncomeInvoice(doc) {
	const vm = doc.$vm;
	let result = await vm.$invoke('DocumentAddChildCopy', { Id: doc.Id, Type: 'INCOME_INVOICE' });
	if (result.Document) {
		vm.$navigate('/document/income_invoice/edit', result.Document.Id)
	}
}

async function createDocOutgoingInvoice(doc) {
	const vm = doc.$vm;
	let result = await vm.$invoke('DocumentAddChildCopy', { Id: doc.Id, Type: 'OUTGOING_INVOICE' });
	if (result.Document) {
		vm.$navigate('/document/outgoing_invoice/edit', result.Document.Id)
	}
}

async function createDocIncomePayment(doc) {
	const vm = doc.$vm;
	let result = await vm.$invoke('DocumentAddChildCopyWithoutDetails', { Id: doc.Id, Type: 'INCOME_PAYMENT' });
	if (result.Document) {
		vm.$navigate('/document/income_payment/edit', result.Document.Id)
	}
}

async function createDocOutgoingPayment(doc) {
	const vm = doc.$vm;
	let result = await vm.$invoke('DocumentAddChildCopyWithoutDetails', { Id: doc.Id, Type: 'OUTGOING_PAYMENT' });
	if (result.Document) {
		vm.$navigate('/document/outgoing_payment/edit', result.Document.Id)
	}
}

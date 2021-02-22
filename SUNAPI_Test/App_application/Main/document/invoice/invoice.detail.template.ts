const cmn = require('document/common');

const template: Template = {
	properties: {
		"TDocument.Sum": cmn.docSum,
		"TDocument.$SumGoods": cmn.docSumGoods,
		"TDocument.$SumServices": cmn.docSumServices,
		"TDocument.$RowsCntGoods": cmn.rowCntGoods,
		"TDocument.$RowsCntServices": cmn.rowCntServices,
		"TDocument.$BrowseContractParams": cmn.browseContractParams,
		"TDocument.$BrowseCashAccountParams": cmn.browseCashAccountParams,
		"TDocument.$CanCreate": cmn.docCanCreate,
		"TRow.Sum": cmn.rowSum,
		"TDocTreeItem.$Mark": cmn.docTreeMark,
		"TRow.$BrowseStocksParams": browseStocksParams
	},

	validators: {
		'Document.Date': 'Укажите дату документа',
		'Document.Partner': 'Выберите контрагента',
		'Document.Company': 'Выберите организацию',
		'Document.Contract': 'Выберите договор',
		'Document.CashAccount': 'Выберите счет',
		'Document.Rows[].Product': 'Выберите товар',
		'Document.Rows[].Price': 'Укажите цену'
	},

	delegates: {
		fetchPartner: cmn.fetchPartner,
		fetchProduct: cmn.fetchProduct,
		fetchStore: cmn.fetchStore,
		fetchContract: cmn.fetchContract,
		fetchCompany: cmn.fetchCompany,
		fetchCashAccount: cmn.fetchCashAccount,
		fetchPriceType: cmn.fetchPriceType,
	},
	commands: {
		newPartner: cmn.newPartner,
		newProduct: cmn.newProduct,
		newStore: cmn.newStore,
		newContract: cmn.newContract,
		newCompany: cmn.newCompany,
		newCashAccount: cmn.newCashAccount,
		apply: cmn.docApply,
		unApply: cmn.docUnApply,
		appendRowGoods: cmn.appendRowGoods,
		appendRowService: cmn.appendRowService,
		createDocInvoice: cmn.createDocInvoice,
		createDocOutgoingInvoice: cmn.createDocOutgoingInvoice,
		createDocOutgoingOrder: cmn.createDocOutgoingOrder,
		createDocIncomeInvoice: cmn.createDocIncomeInvoice,
		createDocIncomeOrder: cmn.createDocIncomeOrder,
		createDocOutgoingPayment: cmn.createDocOutgoingPayment,
		createDocIncomePayment: cmn.createDocIncomePayment,
	},
	events: {
		"Model.load": modelLoad,
		"Document.Rows[].add": cmn.docRowAdded,
		"Document.Company.change": cmn.docCompanyChanged,
		"Document.Partner.change": cmn.docPartnerChanged,
		"Document.Rows[].Product.Article.change": cmn.findArticle,
		"Document.Rows[].Product.change": cmn.docRowChangedSetPriceFromStocksPrice
	}
};

export default template;

function modelLoad(root) {
	if (root.Document.$isNew)
		cmn.documentCreate(root.Document);
}

function browseStocksParams() {
	let doc = this.$parent.$parent;
	return {
		Date: doc.Date,
		Company: doc.Company.Id,
		Store: doc.StoreFrom.Id,
		PriceType: doc.PriceType.Id
	}
}
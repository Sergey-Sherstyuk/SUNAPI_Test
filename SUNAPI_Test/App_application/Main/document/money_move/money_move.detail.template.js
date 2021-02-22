define(["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    const cmn = require('document/common');
    const template = {
        properties: {
            "TDocument.$BrowseContractParams": cmn.browseContractParams,
            "TDocument.$BrowseCashAccountParams": cmn.browseCashAccountParams,
            "TDocument.$CanCreate": cmn.docCanCreate,
            "TDocTreeItem.$Mark": cmn.docTreeMark,
            "TDocument.$BrowseExpenditureParams"() { return { Filter: 'Income' }; },
            "TDocument.$BrowseOperationParams"() { return { Filter: 'Income' }; }
        },
        validators: {
            'Document.Date': 'Укажите дату документа',
            'Document.Sum': 'Укажите сумму',
            'Document.Company': 'Выберите организацию',
            'Document.CashAccountFrom': 'Выберите счет',
            'Document.CashAccountTo': 'Выберите счет',
        },
        delegates: {
            fetchPartner: cmn.fetchPartner,
            fetchProduct: cmn.fetchProduct,
            fetchStore: cmn.fetchStore,
            fetchContract: cmn.fetchContract,
            fetchCompany: cmn.fetchCompany,
            fetchCashAccount: cmn.fetchCashAccount,
            fetchExpenditure: cmn.fetchExpenditure,
            fetchOperation: cmn.fetchOperation,
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
            "Document.Company.change": cmn.docCompanyChanged,
            "Document.Partner.change": cmn.docPartnerChanged,
        }
    };
    exports.default = template;
    function modelLoad(root) {
        if (root.Document.$isNew)
            cmn.documentCreate(root.Document);
    }
});

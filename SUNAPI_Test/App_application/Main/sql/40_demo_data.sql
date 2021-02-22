---------------------
----- Demo data -----
---------------------

------------------------------------------------
----- Units
if not exists(select * from sunapi.Units) 
begin
	insert into sunapi.Units(Id, [Name], FullName, UserCreated, UserModified)
		values 
		(100, N'шт.',  N'Штука', 0, 0),
		(101, N'кг.',  N'Килограмм', 0, 0),
		(102, N'л.',   N'Литр', 0, 0),
		(103, N'пач.', N'Пачка', 0, 0),
		(104, N'м.',   N'Метр', 0, 0);
end
go
------------------------------------------------
----- Sections
if not exists(select * from sunapi.Sections) 
begin
	insert into sunapi.Sections(Id, ParentSectionId, [Name], UserCreated, UserModified)
		values 
		(100, null, N'Посуда', 0, 0),
		(101, null, N'Одежда', 0, 0),
		(102, null, N'Обувь', 0, 0),
		(103, 101,  N'Аксессуары', 0, 0),
		(104, null, N'Электроника', 0, 0),
		(105, 104,  N'Смартфоны', 0, 0),
		(106, 104,  N'Телевизоры', 0, 0),
		(107, 104,  N'Холодильники', 0, 0),
		(108, 106,  N'Smart TV', 0, 0),
		(109, null, N'Услуги', 0, 0);
end
go
------------------------------------------------
----- Products
if not exists(select * from sunapi.Products) 
begin
	insert into sunapi.Products(Id, IsService, Article, [Name], Unit, Section, UserCreated, UserModified)
		values 
		(100, 0, N'cp1234', N'Чашка',       100, 100, 0, 0),
		(101, 0, N'tc4567', N'Термокружка', 100, 100, 0, 0),
		(102, 0, N'pl9876', N'Тарелка',     100, 100, 0, 0),
		(103, 0, N'cr7654', N'Кроссовки',   100, 101, 0, 0),
		(104, 0, N'ts1234', N'Футболка',    100, 102, 0, 0),
		(105, 0, N'sh7890', N'Туфли',       100, 102, 0, 0),
		(106, 0, N'dr6543', N'Платье',      100, 101, 0, 0),
		(107, 0, N'ca3210', N'Кепка',       100, 101, 0, 0),
		(108, 1, N'deliv',  N'Доставка',    100, 109, 0, 0),
		(109, 1, N'pack',   N'Упаковка',    100, 109, 0, 0);
end
go
------------------------------------------------
----- Stores
if not exists(select * from sunapi.Stores) 
begin
	insert into sunapi.Stores(Id, [Name], UserCreated, UserModified)
		values 
		(100, N'Основной склад', 0, 0),
		(101, N'Магазин', 0, 0),
		(102, N'Офис', 0, 0);
end
go
-------------------------------------------------
----- Partners
if not exists(select * from sunapi.Partners) 
begin
	insert into sunapi.Partners(Id, [Name], UserCreated, UserModified)
		values 
		(100, N'Основной поставщик',   0, 0),
		(101, N'Розничный покупатель', 0, 0),
		(102, N'Sunapi',    0, 0),
		(103, N'Иванов',  0, 0),
		(104, N'Петров',  0, 0),
		(105, N'Сидоров', 0, 0);
end
go
------------------------------------------------
----- Prices
if not exists(select * from sunapi.PriceTypes) 
begin
	insert into sunapi.PriceTypes(Id, [Name], UserCreated, UserModified)
		values 
		(100, N'Розничная цена', 0, 0),
		(101, N'Оптовая цена', 0, 0);
end
go
-------------------------------------------------
----- Companies
if not exists(select * from sunapi.Companies) 
begin
	insert into sunapi.Companies(Id, [Name], UserCreated, UserModified)
		values 
		(100, N'Наша фирма', 0, 0),
		(101, N'Рога и копыта', 0, 0);
end
go
-------------------------------------------------
----- Cash accounts
if not exists(select * from sunapi.CashAccounts) 
begin
	insert into sunapi.CashAccounts(Id, Company, [Name], UserCreated, UserModified)
		values 
		(100, 100, N'Касса 1 НФ', 0, 0),
		(101, 100, N'Касса 2 НФ', 0, 0),
		(102, 101, N'Касса 1 РК', 0, 0),
		(103, 101, N'Касса 2 РК', 0, 0);
end
go
-------------------------------------------------
----- Contracts
if not exists(select * from sunapi.Contracts) 
begin
	insert into sunapi.Contracts(Id, Company, [Partner], [Name], UserCreated, UserModified)
		values 
		(100, 100, 100, N'Основное соглашение НФ Основной поставщик', 0, 0),
		(101, 100, 100, N'Договор опт НФ Основной поставщик', 0, 0),
		(102, 101, 100, N'Основное соглашение РК Основной поставщик', 0, 0),
		(103, 101, 100, N'Договор опт РК Основной поставщик', 0, 0),

		(104, 100, 101, N'Основное соглашение НФ Розничный покупатель', 0, 0),
		(105, 100, 101, N'Договор опт НФ Розничный покупатель', 0, 0),
		(106, 101, 101, N'Основное соглашение РК Розничный покупатель', 0, 0),
		(107, 101, 101, N'Договор опт РК Розничный покупатель', 0, 0),

		(108, 100, 102, N'Основное соглашение НФ Sunapi', 0, 0),
		(109, 100, 102, N'Договор опт НФ Sunapi', 0, 0),
		(110, 101, 102, N'Основное соглашение Sunapi', 0, 0),
		(111, 101, 102, N'Договор опт РК Sunapi', 0, 0),

		(112, 100, 103, N'Основное соглашение НФ Иванов', 0, 0),
		(113, 100, 103, N'Договор опт НФ Иванов', 0, 0),
		(114, 101, 103, N'Основное соглашение РК Иванов', 0, 0),
		(115, 101, 103, N'Договор опт РК Иванов', 0, 0),

		(116, 100, 104, N'Основное соглашение НФ Петров', 0, 0),
		(117, 100, 104, N'Договор опт НФ Петров', 0, 0),
		(118, 101, 104, N'Основное соглашение РК Петров', 0, 0),
		(119, 101, 104, N'Договор опт РК Петров', 0, 0),

		(120, 100, 105, N'Основное соглашение НФ Сидоров', 0, 0),
		(121, 100, 105, N'Договор опт НФ Сидоров', 0, 0),
		(122, 101, 105, N'Основное соглашение РК Сидоров', 0, 0),
		(123, 101, 105, N'Договор опт РК Сидоров', 0, 0);

end
go
-------------------------------------------------
----- Expenditures
if not exists(select * from sunapi.Expenditures)
begin
	insert into sunapi.Expenditures(Id, [Name], Income, Outgoing, UserCreated, UserModified)
		values 
		(100, N'Оплата от покупателя', 1, 1, 0, 0),
		(101, N'Оплата поставщику', 1, 1, 0, 0),
		(102, N'Покупка основных средств', 1, 1, 0, 0),
		(103, N'Бытовые расходы', 1, 1, 0, 0),
		(104, N'Начальный остаток', 1, 0, 0, 0);
end
go
-------------------------------------------------
----- Operations
if not exists(select * from sunapi.Operations)
begin
	insert into sunapi.Operations(Id, [Name], Income, Outgoing, UserCreated, UserModified)
		values 
		(100, N'Оплата от покупателя', 1, 1, 0, 0),
		(101, N'Оплата поставщику', 1, 1, 0, 0),
		(102, N'Прочие поступления', 1, 1, 0, 0),
		(103, N'Возврат от поставщика', 1, 1, 0, 0),
		(104, N'Взнос наличными', 1, 1, 0, 0);
end
go
-------------------------------------------------
----- Demo Documents

if not exists(select * from sunapi.Documents) 
begin

	SET DATEFORMAT ymd;
	SET ARITHABORT, ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER, ANSI_NULLS, NOCOUNT ON;
	SET NUMERIC_ROUNDABORT, IMPLICIT_TRANSACTIONS, XACT_ABORT OFF;

	INSERT sunapi.Documents(Id, Type, ParentId, Date, Number, Partner, Company, Contract, CashAccount, CashAccountFrom, CashAccountTo, Expenditure, Operation, PriceType, Sum, Comment, StoreFrom, StoreTo, Done, Deleted, DateCreated, UserCreated, DateModified, UserModified) VALUES (150, N'OUTGOING_ORDER', NULL, '2020-12-07 14:54:41.980', 1, 103, 100, 112, 100, NULL, NULL, NULL, NULL, 100, 265.00, NULL, 100, NULL, CONVERT(bit, 'True'), CONVERT(bit, 'False'), '2020-12-07 14:56:18.223', 99, '2020-12-07 14:56:21.590', 99);
	INSERT sunapi.Documents(Id, Type, ParentId, Date, Number, Partner, Company, Contract, CashAccount, CashAccountFrom, CashAccountTo, Expenditure, Operation, PriceType, Sum, Comment, StoreFrom, StoreTo, Done, Deleted, DateCreated, UserCreated, DateModified, UserModified) VALUES (151, N'INVOICE', 150, '2020-12-07 14:56:26.823', 1, 103, 100, 112, 100, NULL, NULL, NULL, NULL, 100, 265.00, NULL, 100, NULL, CONVERT(bit, 'True'), CONVERT(bit, 'False'), '2020-12-07 14:56:26.823', 99, '2020-12-07 14:56:38.220', 99);
	INSERT sunapi.Documents(Id, Type, ParentId, Date, Number, Partner, Company, Contract, CashAccount, CashAccountFrom, CashAccountTo, Expenditure, Operation, PriceType, Sum, Comment, StoreFrom, StoreTo, Done, Deleted, DateCreated, UserCreated, DateModified, UserModified) VALUES (152, N'INCOME_ORDER', 150, '2020-12-07 14:56:45.160', 1, 100, 100, 100, 100, NULL, NULL, NULL, NULL, 100, 1350.00, NULL, 100, 100, CONVERT(bit, 'True'), CONVERT(bit, 'False'), '2020-12-07 14:56:45.160', 99, '2020-12-07 14:59:56.587', 99);
	INSERT sunapi.Documents(Id, Type, ParentId, Date, Number, Partner, Company, Contract, CashAccount, CashAccountFrom, CashAccountTo, Expenditure, Operation, PriceType, Sum, Comment, StoreFrom, StoreTo, Done, Deleted, DateCreated, UserCreated, DateModified, UserModified) VALUES (153, N'INCOME_INVOICE', 152, '2020-12-07 14:57:16.400', 1, 100, 100, 100, 100, NULL, NULL, NULL, NULL, 100, 1350.00, NULL, 100, 100, CONVERT(bit, 'True'), CONVERT(bit, 'False'), '2020-12-07 14:57:16.400', 99, '2020-12-07 15:00:01.870', 99);
	INSERT sunapi.Documents(Id, Type, ParentId, Date, Number, Partner, Company, Contract, CashAccount, CashAccountFrom, CashAccountTo, Expenditure, Operation, PriceType, Sum, Comment, StoreFrom, StoreTo, Done, Deleted, DateCreated, UserCreated, DateModified, UserModified) VALUES (154, N'OUTGOING_INVOICE', 151, '2020-12-07 14:58:54.440', 1, 103, 100, 112, 100, NULL, NULL, NULL, NULL, 100, 265.00, NULL, 100, NULL, CONVERT(bit, 'True'), CONVERT(bit, 'False'), '2020-12-07 14:58:54.440', 99, '2020-12-07 15:00:13.690', 99);
	INSERT sunapi.Documents(Id, Type, ParentId, Date, Number, Partner, Company, Contract, CashAccount, CashAccountFrom, CashAccountTo, Expenditure, Operation, PriceType, Sum, Comment, StoreFrom, StoreTo, Done, Deleted, DateCreated, UserCreated, DateModified, UserModified) VALUES (155, N'OUTGOING_PAYMENT', 153, '2020-12-07 15:00:20.947', 1, 100, 100, 100, 100, 100, NULL, 101, 101, 100, 1000.00, NULL, 100, 100, CONVERT(bit, 'True'), CONVERT(bit, 'False'), '2020-12-07 15:00:20.947', 99, '2020-12-07 15:00:54.857', 99);
	INSERT sunapi.Documents(Id, Type, ParentId, Date, Number, Partner, Company, Contract, CashAccount, CashAccountFrom, CashAccountTo, Expenditure, Operation, PriceType, Sum, Comment, StoreFrom, StoreTo, Done, Deleted, DateCreated, UserCreated, DateModified, UserModified) VALUES (156, N'INCOME_PAYMENT', 154, '2020-12-07 15:01:00.063', 1, 103, 100, 112, 100, NULL, 100, 100, 100, 100, 265.00, NULL, 100, NULL, CONVERT(bit, 'True'), CONVERT(bit, 'False'), '2020-12-07 15:01:00.063', 99, '2020-12-07 15:01:37.937', 99);
	INSERT sunapi.Documents(Id, Type, ParentId, Date, Number, Partner, Company, Contract, CashAccount, CashAccountFrom, CashAccountTo, Expenditure, Operation, PriceType, Sum, Comment, StoreFrom, StoreTo, Done, Deleted, DateCreated, UserCreated, DateModified, UserModified) VALUES (157, N'INCOME_PAYMENT', NULL, '2020-12-07 12:00:39.717', 2, 102, 100, 108, 100, NULL, 100, 104, 102, NULL, 5000.00, NULL, NULL, NULL, CONVERT(bit, 'True'), CONVERT(bit, 'False'), '2020-12-07 15:03:47.080', 99, '2020-12-07 15:03:49.420', 99);

end
go

----- 

if not exists(select * from sunapi.Details) 
begin

	SET DATEFORMAT ymd;
	SET ARITHABORT, ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER, ANSI_NULLS, NOCOUNT ON;
	SET NUMERIC_ROUNDABORT, IMPLICIT_TRANSACTIONS, XACT_ABORT OFF;

	SET IDENTITY_INSERT sunapi.Details ON;

	INSERT sunapi.Details(Id, Document, Product, Price, Qty, Sum) VALUES (150, 150, 104, 150, 1, 150.00);
	INSERT sunapi.Details(Id, Document, Product, Price, Qty, Sum) VALUES (151, 150, 100, 50, 1, 50.00);
	INSERT sunapi.Details(Id, Document, Product, Price, Qty, Sum) VALUES (152, 150, 108, 50, 1, 50.00);
	INSERT sunapi.Details(Id, Document, Product, Price, Qty, Sum) VALUES (153, 150, 109, 15, 1, 15.00);
	INSERT sunapi.Details(Id, Document, Product, Price, Qty, Sum) VALUES (154, 151, 104, 150, 1, 150.00);
	INSERT sunapi.Details(Id, Document, Product, Price, Qty, Sum) VALUES (155, 151, 100, 50, 1, 50.00);
	INSERT sunapi.Details(Id, Document, Product, Price, Qty, Sum) VALUES (156, 151, 108, 50, 1, 50.00);
	INSERT sunapi.Details(Id, Document, Product, Price, Qty, Sum) VALUES (157, 151, 109, 15, 1, 15.00);
	INSERT sunapi.Details(Id, Document, Product, Price, Qty, Sum) VALUES (158, 152, 104, 100, 10, 1000.00);
	INSERT sunapi.Details(Id, Document, Product, Price, Qty, Sum) VALUES (159, 152, 100, 35, 10, 350.00);
	INSERT sunapi.Details(Id, Document, Product, Price, Qty, Sum) VALUES (162, 153, 104, 100, 10, 1000.00);
	INSERT sunapi.Details(Id, Document, Product, Price, Qty, Sum) VALUES (163, 153, 100, 35, 10, 350.00);
	INSERT sunapi.Details(Id, Document, Product, Price, Qty, Sum) VALUES (164, 154, 104, 150, 1, 150.00);
	INSERT sunapi.Details(Id, Document, Product, Price, Qty, Sum) VALUES (165, 154, 100, 50, 1, 50.00);
	INSERT sunapi.Details(Id, Document, Product, Price, Qty, Sum) VALUES (166, 154, 108, 50, 1, 50.00);
	INSERT sunapi.Details(Id, Document, Product, Price, Qty, Sum) VALUES (167, 154, 109, 15, 1, 15.00);

	SET IDENTITY_INSERT sunapi.Details OFF;
end
go

----- 

if not exists(select * from sunapi.Prices) 
begin

	SET DATEFORMAT ymd;
	SET ARITHABORT, ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER, ANSI_NULLS, NOCOUNT ON;
	SET NUMERIC_ROUNDABORT, IMPLICIT_TRANSACTIONS, XACT_ABORT OFF;

	INSERT sunapi.Prices(Id, Date, Product, PriceType, Price, DateCreated, UserCreated, DateModified, UserModified) VALUES (110, '2020-12-01', 100, 100, 50.00, '2020-12-07 15:04:51.453', 99, '2020-12-07 15:04:51.453', 99);
	INSERT sunapi.Prices(Id, Date, Product, PriceType, Price, DateCreated, UserCreated, DateModified, UserModified) VALUES (111, '2020-12-01', 100, 101, 45.00, '2020-12-07 15:05:20.980', 99, '2020-12-07 15:05:20.980', 99);
	INSERT sunapi.Prices(Id, Date, Product, PriceType, Price, DateCreated, UserCreated, DateModified, UserModified) VALUES (112, '2020-12-01', 104, 100, 150.00, '2020-12-07 15:05:57.157', 99, '2020-12-07 15:05:57.157', 99);
	INSERT sunapi.Prices(Id, Date, Product, PriceType, Price, DateCreated, UserCreated, DateModified, UserModified) VALUES (113, '2020-12-01', 104, 101, 125.00, '2020-12-07 15:06:19.353', 99, '2020-12-07 15:06:19.353', 99);

end
go

----- 

if not exists(select * from sunapi.Stocks) 
begin

	SET DATEFORMAT ymd;
	SET ARITHABORT, ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER, ANSI_NULLS, NOCOUNT ON;
	SET NUMERIC_ROUNDABORT, IMPLICIT_TRANSACTIONS, XACT_ABORT OFF;

	SET IDENTITY_INSERT sunapi.Stocks ON;

	INSERT sunapi.Stocks(Id, Date, DocId, CompanyId, StoreId, ProductId, Qty, Price, Profit) VALUES (100, '2020-12-07 14:57:16.400', 153, 100, 100, 104, 10.000, 100.00, NULL);
	INSERT sunapi.Stocks(Id, Date, DocId, CompanyId, StoreId, ProductId, Qty, Price, Profit) VALUES (101, '2020-12-07 14:57:16.400', 153, 100, 100, 100, 10.000, 35.00, NULL);
	INSERT sunapi.Stocks(Id, Date, DocId, CompanyId, StoreId, ProductId, Qty, Price, Profit) VALUES (102, '2020-12-07 14:58:54.440', 154, 100, 100, 104, -1.000, 150.00, 50.00);
	INSERT sunapi.Stocks(Id, Date, DocId, CompanyId, StoreId, ProductId, Qty, Price, Profit) VALUES (103, '2020-12-07 14:58:54.440', 154, 100, 100, 100, -1.000, 50.00, 15.00);

	SET IDENTITY_INSERT sunapi.Stocks OFF;

end
go

----- 

if not exists(select * from sunapi.CashFlows) 
begin

	SET DATEFORMAT ymd;
	SET ARITHABORT, ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER, ANSI_NULLS, NOCOUNT ON;
	SET NUMERIC_ROUNDABORT, IMPLICIT_TRANSACTIONS, XACT_ABORT OFF;

	SET IDENTITY_INSERT sunapi.CashFlows ON;

	INSERT sunapi.CashFlows(Id, Date, DocId, CashAccountId, Sum, SumIn, SumOut) VALUES (101, '2020-12-07 12:00:39.717', 157, 100, 5000.000, 5000.000, 0.000);
	INSERT sunapi.CashFlows(Id, Date, DocId, CashAccountId, Sum, SumIn, SumOut) VALUES (102, '2020-12-07 15:00:20.947', 155, 100, -1000.000, 0.000, 1000.000);
	INSERT sunapi.CashFlows(Id, Date, DocId, CashAccountId, Sum, SumIn, SumOut) VALUES (103, '2020-12-07 15:01:00.063', 156, 100, 265.000, 265.000, 0.000);

	SET IDENTITY_INSERT sunapi.CashFlows OFF;

end
go

-------------------------------------------------


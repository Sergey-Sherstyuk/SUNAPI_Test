------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SCHEMATA where SCHEMA_NAME=N'sunapi')
begin
	exec sp_executesql N'create schema sunapi';
end
go
------------------------------------------------
grant execute on schema ::sunapi to public;
go
------------------------------------------------
if not exists(select * from a2sys.SysParams where [Name]= N'AppTitle')
	insert into a2sys.SysParams([Name], StringValue) values (N'AppTitle', N'Sunapi');
go
------------------------------------------------
if not exists(select * from a2sys.SysParams where [Name]= N'AppSubTitle')
	insert into a2sys.SysParams([Name], StringValue) values (N'AppSubTitle', N'Test application');
go
------------------------------------------------
if not exists (select * from a2security.Acl where [Object] = 'std:menu' and [ObjectId] = 1 and GroupId = 1)
begin
	insert into a2security.Acl ([Object], ObjectId, GroupId, CanView)
		values (N'std:menu', 1, 1, 1);
end
go
------------------------------------------------
if not exists(select * from a2security.Users where Id <> 0)
begin
	set nocount on;
	insert into a2security.Users(Id, UserName, SecurityStamp, PasswordHash, PersonName, EmailConfirmed)
	values (99, N'admin@admin.com', N'c9bb451a-9d2b-4b26-9499-2d7d408ce54e', N'AJcfzvC7DCiRrfPmbVoigR7J8fHoK/xdtcWwahHDYJfKSKSWwX5pu9ChtxmE7Rs4Vg==', -- password: Admin
		N'System administrator', 1);
	insert into a2security.UserGroups(UserId, GroupId) values (99, 77), (99, 1); /*predefined values*/
end
go
------------------------------------------------
begin
	set nocount on;

	-- create admin menu

	-- Use delete to prevent error: The MERGE statement conflicted with the REFERENCE constraint "FK_MenuAcl_Menu". The conflict occurred in database "SUNAPI_***", table "a2security.Menu.Acl", column 'Menu'.
	delete from [a2security].[Menu.Acl];

	declare @menu table(id bigint, p0 bigint, [name] nvarchar(255), [url] nvarchar(255), icon nvarchar(255), [order] int);
	insert into @menu(id, p0, [name], [url], icon, [order])
	values
		(1, null, N'Main',               null,       null,              0),
		(30,   1, N'@[MenuDocument]',   N'document', null,              10),
		(10,   1, N'@[MenuCatalog]',    N'catalog',  null,              20),
		(32,  30, N'Покупець',          N'',         null,              32),
		(34,  30, N'Постачальник',      N'',         null,              34),
		(36,  30, N'Складські документі', N'',       null,              36),
		(38,  30, N'Грошові кошти',     N'',         null,              36),

		(50,   1, N'@[MenuReport]',     N'report',   null,              50),

		(105, 10, N'@[MenuPartners]',   N'partner',  N'users',         105),
		(110, 10, N'@[MenuProducts]',   N'product',  N'package',       110),
		(115, 10, N'@[MenuSections]',   N'section',  N'account-folder', 115),
		(120, 10, N'@[MenuUnits]',      N'unit',     N'file',          120),
		(130, 10, N'@[MenuStores]',     N'store',    N'warehouse',     130),
		(140, 10, N'@[MenuPriceTypes]', N'price_type', N'list',        140),
		(150, 10, N'@[MenuCompanies]',  N'company',  N'storyboard',    150),
		(155, 10, N'@[MenuCashAccounts]', N'cash_account', N'bank',    155),
		(160, 10, N'@[MenuContracts]',  N'contract', N'file-signature', 160),
		(165, 10, N'@[MenuExpenditures]',  N'expenditure', N'arrow-left-right', 165),
		(170, 10, N'@[MenuOperations]', N'operation', N'arrow-left-right', 170),
		(195, 10, N'Catalog',	        N'Cat',		 N'report',		195),

		(210, 32, N'@[DocNameOutgoingOrder]', N'outgoing_order', N'file', 210),
		(215, 32, N'@[DocNameInvoice]', N'invoice',  N'file',             215),
		(220, 36, N'@[DocNameOutgoingInvoice]', N'outgoing_invoice', N'file', 220),
		(225, 34, N'@[DocNameIncomeOrder]', N'income_order', N'file',  225),
		(230, 36, N'@[DocNameIncomeInvoice]', N'income_invoice', N'file', 230),
		(240, 36, N'@[DocNameStocksMove]', N'stocks_move', N'file',    240),
		(245, 38, N'@[DocNameIncomePayment]', N'income_payment', N'file', 245),
		(250, 38, N'@[DocNameOutgoingPayment]', N'outgoing_payment', N'file', 250),
		(255, 38, N'@[DocNameMoneyMove]', N'money_move', N'file',      255),

		(310, 50, N'@[MenuStocks]',     N'stocks',   N'report',        310),
		(320, 50, N'@[MenuSales]',      N'sales',    N'report',        320),
		(330, 50, N'@[MenuCashAccounts]', N'cash_accounts', N'report', 330),
		(340, 50, N'@[MenuExpenditures]', N'cash_flows',  N'report', 340),
		(350, 50, N'@[MenuProductMoves]', N'product_moves',  N'report', 350),
		(360, 50, N'@[MenuBalances]',     N'balances',       N'report', 360);

	merge a2ui.Menu as target
	using @menu as source
	on target.Id=source.id and target.Id >= 1 and target.Id < 10000
	when matched then
		update set
			target.Id = source.id,
			target.Parent = source.p0,
			target.[Name] = source.[name],
			target.[Url] = source.[url],
			target.[Icon] = source.icon,
			target.[Order] = source.[order]
	when not matched by target then
		insert(Id, Parent, [Name], [Url], Icon, [Order]) values (id, p0, [name], [url], icon, [order])
	when not matched by source and target.Id >= 1 and target.Id < 10000 then 
		delete;
	exec a2security.[Permission.UpdateAcl.Menu];
end
go
------------------------------------------------

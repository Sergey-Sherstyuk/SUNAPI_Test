-------------------
----- Reports -----
-------------------

create or alter procedure sunapi.[Report.Sales.Index]
@UserId bigint,
@From datetime = null,
@To datetime = null,
@Partner bigint = null,
@Company bigint = null
as
begin

	set nocount on;

	DECLARE @currentDate DATE = GETDATE();
	if (@From IS NULL)
		set @From = DATEADD(DAY, 1, EOMONTH(@currentDate, -1));
	
	if (@To IS NULL)
		set @To = EOMONTH(@currentDate);

/*
	SELECT
		[Products!TProduct!Array] = null,
		[Id!!Id] = det.Product,
		p.Article,
		p.Name,
		SUM(det.Qty) AS ProdQty,
		SUM(det.Sum) AS ProdSum
	FROM sunapi.Details as det
	LEFT JOIN sunapi.Documents as doc ON det.Document = doc.Id
	LEFT JOIN sunapi.Products as p ON det.Product = p.Id
	LEFT JOIN sunapi.Companies as c ON c.Id = doc.Company
	WHERE doc.Type = 'OUTGOING_INVOICE' 
		AND doc.Date >= @From AND doc.Date <= @To
		AND (@Partner IS NULL or doc.Partner = @Partner)
		AND (@Company IS NULL or doc.Company = @Company)
	GROUP BY det.Product,
		p.Article,
		p.Name
	ORDER BY p.Name
*/

	SELECT
		[Products!TProduct!Array] = null,
		[Id!!Id] = stk.ProductId,
		p.Article,
		p.Name,
		-1 * SUM(stk.Qty) AS ProdQty,
		SUM(stk.Price * stk.Qty * -1)  AS ProdSum,
		SUM(stk.Profit)  AS ProdProfit
	FROM sunapi.Stocks as stk
	LEFT JOIN sunapi.Documents as doc ON doc.Id = stk.DocId
	LEFT JOIN sunapi.Products as p ON p.Id = stk.ProductId
	LEFT JOIN sunapi.Companies as c ON c.Id = stk.CompanyId
	WHERE doc.Type = 'OUTGOING_INVOICE' 
		AND doc.Date >= @From AND doc.Date <= @To
		AND (@Partner IS NULL or doc.Partner = @Partner)
		AND (@Company IS NULL or doc.Company = @Company)
	GROUP BY stk.ProductId,
		p.Article,
		p.Name
	ORDER BY p.Name


	select [Query!TQuery!Object] = null,
		[Period.From!TPeriod] = @From,
		[Period.To!TPeriod] = @To,
		[Partner!TPartner!RefId] = @Partner,
		[Company!TCompany!RefId] = @Company;

	select [!TPartner!Map] = null, [Id!!Id] = Id, [Name], Phone, Memo
		from sunapi.Partners where Id = @Partner;

	select [!TCompany!Map] = null, [Id!!Id] = Id, [Name]
		from sunapi.Companies where Id = @Company;

end
go
------------------------------------------------
create or alter procedure sunapi.[Report.Stocks.Index]
@UserId bigint,
@Id bigint = null,
@Date date = null,
@Store bigint = null,
@Company bigint = null,
@PriceType bigint = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	if @Date is null
		set @Date = getdate();

	declare @DateFilter date;
	set @DateFilter = dateadd(day, 1, @Date);

	with stocksavl as
	(
		select s.StoreId, s.ProductId, SUM(s.Qty) as QtyAvl
			from sunapi.Stocks as s
			left join sunapi.Documents as d on d.Id = s.DocId
			left join sunapi.Companies as c on c.Id = d.Company
			where s.[Date] < @DateFilter and (@Company is null or c.Id = @Company)
			group by StoreId, ProductId
	)
	select [Products!TProduct!Array] = null, [Id!!Id] = sa.ProductId, sa.StoreId, sa.QtyAvl, StoreName = st.Name, p.Article, p.Id as ProductId, p.Name as ProductName, u.Name as UnitName
		from stocksavl as sa
		left join sunapi.Products as p on p.Id = sa.ProductId
		left join sunapi.Stores as st on st.Id = sa.StoreId
		left join sunapi.Units as u on u.Id = p.Unit
		where (@Store is null or sa.StoreId = @Store)
		order by p.Name

	select [Query!TQuery!Object] = null,
		[Date!!] = @Date,
		[Store!TStore!RefId] = @Store,
		[Company!TCompany!RefId] = @Company;

		select [!TStore!Map] = null, [Id!!Id] = Id, [Name]
		from sunapi.Stores where Id = @Store;

		select [!TCompany!Map] = null, [Id!!Id] = Id, [Name]
		from sunapi.Companies where Id = @Company;

end
go
------------------------------------------------


------------------------------------------------
-- TODO: Complete the procedure

create or alter procedure sunapi.[Stocks.Index]
@UserId bigint,
@Id bigint = null,
@Offset int = 0,
@PageSize int = 10,
@Order nvarchar(255) = N'Name',
@Dir nvarchar(20) = N'asc',
@Date datetime = null,
@Company bigint = null,
@Store bigint = null,
@Section bigint = null,
@IsService bit = null,
@InStock bit = 0,
@Fragment nvarchar(255) = null,
@PriceType bigint = null

as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	declare @Asc nvarchar(10), @Desc nvarchar(10), @RowCount int;
	set @Asc = N'asc'; 
	set @Desc = N'desc';
	set @Dir = isnull(@Dir, @Asc);

	if @Date is null
		set @Date = getdate();
/*
	with stocksavl as
	(
		select StoreId, ProductId, SUM(Qty) as QtyAvl
			from sunapi.Stocks
			where Date <= @Date
			group by StoreId, ProductId
	)
	select [Products!TProduct!Array] = null, [Id!!Id] = sa.ProductId, sa.StoreId, sa.QtyAvl, StoreName = st.Name, p.Artnumber, p.Name from stocksavl as sa
		left join sunapi.Products as p on p.Id = sa.ProductId
		left join sunapi.Stores as st on st.Id = sa.StoreId
		where (@Store is null and 1 = 1) or (@Store is not null and  sa.StoreId = @Store)
		order by p.Name
*/


	with stocksAvl as
	(
		select CompanyId, StoreId, ProductId, SUM(Qty) as QtyAvl
			from sunapi.Stocks
			where Date <= @Date
			group by CompanyId, StoreId, ProductId
	),
	productsFiltered as 
	(
		select [Products!TProduct!Array] = null, [Id!!Id] = p.Id, 
			sa.CompanyId, sa.StoreId, sa.QtyAvl, CompanyName = c.[Name], StoreName = st.[Name], p.Article, p.Name, 
			[Unit.Id!TUnit!Id] = u.Id, [Unit.Name!TUnit!] = u.[Name],
			Price = (
				select top(1) Price 
				from sunapi.Prices as prices 
				where prices.Product=p.Id and prices.PriceType = @PriceType and prices.[Date] <= @Date
				order by [Date] desc
			),
			[!!RowNumber] = row_number() over (
				order by
					case when @Order=N'Id' and @Dir = @Asc then p.Id end asc,
					case when @Order=N'Id' and @Dir = @Desc  then p.Id end desc,
					case when @Order=N'Name' and @Dir = @Asc then p.[Name] end asc,
					case when @Order=N'Name' and @Dir = @Desc then p.[Name] end desc,
					case when @Order=N'QtyAvl' and @Dir = @Asc then sa.QtyAvl end asc,
					case when @Order=N'QtyAvl' and @Dir = @Desc then sa.QtyAvl end desc,
					case when @Order=N'Article' and @Dir = @Asc then p.Article end asc,
					case when @Order=N'Article' and @Dir = @Desc then p.Article end desc,
					case when @Order=N'StoreName' and @Dir = @Asc then st.Name end asc,
					case when @Order=N'StoreName' and @Dir = @Desc then st.Name end desc
			)
			from sunapi.Products as p
			-- left join stocksAvl as sa on ((@Store is not null or @Company is not null) and sa.ProductId = p.Id)
			left join stocksAvl as sa on sa.ProductId = p.Id
			left join sunapi.Stores as st on st.Id = sa.StoreId
			left join sunapi.Companies as c on c.Id = sa.CompanyId
			left join sunapi.Units as u on u.Id = p.Unit
			where (
				(p.IsService = 0)
				and (@Fragment is null or upper(p.[Name]) like @Fragment or upper(p.[Article]) like @Fragment or cast(p.Id as nvarchar) like @Fragment)
				and ((@InStock = 0) or (@Store is null or sa.StoreId = @Store))
				and ((@InStock = 0) or (@Company is null or sa.CompanyId = @Company))
				and (@InStock = 0 or sa.QtyAvl > 0)
			)
	)
	select *, [!!RowCount] = (select count(1) from productsFiltered) 
	from productsFiltered
	where [!!RowNumber] > @Offset and [!!RowNumber] <= @Offset + @PageSize
	order by [!!RowNumber];

	select [Companies!TCompany!Array] = null, [Id!!Id] = null, [Name] = N'---'
	union
	select [Companies!TCompany!Array] = null, [Id!!Id] = Id, [Name]
		from sunapi.Companies
		order by Name asc;

	select [Stores!TStore!Array] = null, [Id!!Id] = null, [Name] = N'---'
	union
	select [Stores!TStore!Array] = null, [Id!!Id] = Id, [Name]
		from sunapi.Stores
		order by Name asc;

	select [PriceTypes!TPriceType!Array] = null, [Id!!Id] = null, [Name] = N'---'
	union
	select [PriceTypes!TPriceType!Array] = null, [Id!!Id] = Id, [Name]
		from sunapi.PriceTypes
		order by Name asc;

	select [!$System!] = null, 
		[!Products!PageSize] = @PageSize, 
		[!Products!SortOrder] = @Order, 
		[!Products!SortDir] = @Dir,
		[!Products!Offset] = @Offset,
		[!Products!HasRows] = case when exists(select * from sunapi.Products) then 1 else 0 end,
		[!Products.Date!Filter] = @Date,
		-- [!Products.Date!Filter] = N'20200721',
		-- [!Products.Date!Filter] = convert(varchar, @Date, 104),
		[!Products.Company!Filter] = @Company,
		[!Products.Store!Filter] = @Store,
		[!Products.PriceType!Filter] = @PriceType,
		[!Products.InStock!Filter] = @InStock;
end
go
------------------------------------------------
create or alter procedure sunapi.[Report.CashAccounts.Index]
@UserId bigint,
@From date = null,
@To date = null
as
begin

	set nocount on;

	declare @currentDate DATE = GETDATE();
	if (@From IS NULL)
		set @From = DATEADD(DAY, 1, EOMONTH(@currentDate, -1));
	if (@To IS NULL)
		set @To = EOMONTH(@currentDate);

	with T([Id!!Id], [Name], CompanyName, SumBegin, SumIn, SumOut, SumEnd)
	as( 
		select 
			ca.Id, ca.[Name], c.[Name],
			--(	(select coalesce(Sum(d.Sum), 0) from sunapi.Documents as d where d.Done = 1 and d.Type in ('INCOME_PAYMENT', 'MONEY_MOVE') and CashAccountTo = ca.Id and CAST(d.Date as date) < @From)
			--	-
			--	(select coalesce(Sum(d.Sum), 0) from sunapi.Documents as d where d.Done = 1 and d.Type in ('OUTGOING_PAYMENT', 'MONEY_MOVE') and CashAccountFrom = ca.Id and CAST(d.Date as date) < @From)
			--) as SumBegin,
			sunapi.GetCashAccountBalanceOnDateBegin(ca.Id, @From) as SumBegin,
			( 
				-- (select coalesce(Sum(d.Sum), 0) from sunapi.Documents as d where d.Done = 1 and d.Type in ('INCOME_PAYMENT', 'MONEY_MOVE') and CashAccountTo = ca.Id and CAST(d.Date as date) BETWEEN @From AND @To)
				(select coalesce(Sum(d.Sum), 0) from sunapi.Documents as d where d.Done = 1 and d.Type in ('INCOME_PAYMENT', 'MONEY_MOVE') and CashAccountTo = ca.Id and d.Date >= @From and d.Date < sunapi.GetNextDay(@To))
			) as SumIn,
			( 
				--(select coalesce(Sum(d.Sum), 0) from sunapi.Documents as d where d.Done = 1 and d.Type in ('OUTGOING_PAYMENT', 'MONEY_MOVE') and CashAccountFrom = ca.Id and CAST(d.Date as date) BETWEEN @From AND @To)
				(select coalesce(Sum(d.Sum), 0) from sunapi.Documents as d where d.Done = 1 and d.Type in ('OUTGOING_PAYMENT', 'MONEY_MOVE') and CashAccountFrom = ca.Id and d.Date >= @From and d.Date < sunapi.GetNextDay(@To))
			) as SumOut,
			--( 
			--	(select coalesce(Sum(d.Sum), 0) from sunapi.Documents as d where d.Done = 1 and d.Type in ('INCOME_PAYMENT', 'MONEY_MOVE') and CashAccountTo = ca.Id and CAST(d.Date as date) <= @To)
			--	-
			--	(select coalesce(Sum(d.Sum), 0) from sunapi.Documents as d where d.Done = 1 and d.Type in ('OUTGOING_PAYMENT', 'MONEY_MOVE') and CashAccountFrom = ca.Id and CAST(d.Date as date) <= @To)
			--) as SumEnd,
			sunapi.GetCashAccountBalanceOnDateBegin(ca.Id, sunapi.GetNextDay(@To)) as SumEnd
		from sunapi.CashAccounts as ca
		left join sunapi.Companies as c on c.Id = ca.Company
	)
	select [CashAccounts!TCashAccount!Array]=null, *, [!!RowCount] = (select count(1) from T)
		from T
		order by CompanyName asc, [Name] asc;

		--where [!!RowNumber] > @Offset and [!!RowNumber] <= @Offset + @PageSize
		--order by [!!RowNumber];

	select [!$System!] = null, 
--		[!CashAccounts!PageSize] = @PageSize, 
--		[!CashAccounts!SortOrder] = @Order, 
--		[!CashAccounts!SortDir] = @Dir,
--		[!CashAccounts!Offset] = @Offset,
--		[!CashAccounts!HasRows] = case when exists(select * from sunapi.Products) then 1 else 0 end,
		[!CashAccounts.Period.From!Filter] = @From,
		[!CashAccounts.Period.To!Filter] = @To;
end
go
------------------------------------------------
create or alter function sunapi.GetCashAccountBalanceOnDateBegin (@CashAccount bigint, @Date date)
returns decimal(10,2)
as
begin

	declare @Result decimal(10, 2);

	select @Result = (
		select coalesce(sum(d.[Sum]), 0)
		from sunapi.Documents as d 
		where 
			d.Done = 1 
			and d.Type in ('INCOME_PAYMENT', 'OUTGOING_PAYMENT', 'MONEY_MOVE')
			and (d.CashAccountTo = @CashAccount)
			and d.Date < @Date  -- CAST(d.Date as date) < @Date
	) - (
		select coalesce(sum(d.[Sum]), 0)
		from sunapi.Documents as d 
		where 
			d.Done = 1 
			and d.Type in ('INCOME_PAYMENT', 'OUTGOING_PAYMENT', 'MONEY_MOVE')
			and (d.CashAccountFrom = @CashAccount)
			and d.Date < @Date -- CAST(d.Date as date) < @Date
	);

	-- TODO: проверить корректность работы

	return @Result;

end;
go
------------------------------------------------
create or alter procedure sunapi.[Report.CashAccounts.Load]
@UserId bigint,
@Id bigint,
@From date = null,
@To date = null
as
begin
	set nocount on;

	declare @currentDate DATE = GETDATE();
	if (@From IS NULL)
		set @From = DATEADD(DAY, 1, EOMONTH(@currentDate, -1));
	if (@To IS NULL)
		set @To = EOMONTH(@currentDate);

	declare @SumBegin decimal(10,2) = sunapi.GetCashAccountBalanceOnDateBegin (@Id, @From);
	declare @SumEnd decimal(10,2) = sunapi.GetCashAccountBalanceOnDateBegin (@Id, DATEADD(DAY, 1, @To));

	with t as
	(
		select d.Id as DocId, d.[Type] as DocType, d.Number as DocNumber, d.Date as DocDate,
			PartnerName = p.Name, ContractName = c.Name, OperationName = op.Name, ExpenditureName = e.Name,
			case when d.CashAccountTo = @Id then d.Sum else 0 end as SumIn,
			case when d.CashAccountFrom = @Id then d.Sum else 0 end as SumOut
		from sunapi.Documents as d 
		left join sunapi.Partners as p on p.Id = d.[Partner]
		left join sunapi.Contracts as c on c.Id = d.[Contract]
		left join sunapi.Operations as op on op.Id = d.Operation
		left join sunapi.Expenditures as e on e.Id = d.Expenditure
		where 
			d.Done = 1 
			and d.Type in ('INCOME_PAYMENT', 'OUTGOING_PAYMENT', 'MONEY_MOVE') 
			and (d.CashAccountFrom = @Id or d.CashAccountTo = @Id)
			and d.Date >= @From and d.Date < sunapi.GetNextDay(@To) -- CAST(d.Date as date) BETWEEN @From AND @To
	),
	totals as
	(
		select DocId, DocType, DocNumber = sunapi.FormatNumber8(DocNumber, DocType), DocDate, 
			PartnerName, ContractName, OperationName, ExpenditureName, 
			SumIn, SumOut, SumIn - SumOut as Delta,
			SUM(SumIn) OVER(
				ORDER BY DocDate
				ROWS BETWEEN UNBOUNDED PRECEDING
				AND CURRENT ROW) AS TotalIn,
			SUM(SumOut) OVER(
				ORDER BY DocDate
				ROWS BETWEEN UNBOUNDED PRECEDING
				AND CURRENT ROW) AS TotalOut,

			(
				SUM(SumIn) OVER(
					ORDER BY DocDate
					ROWS BETWEEN UNBOUNDED PRECEDING
					AND CURRENT ROW) -
				SUM(SumOut) OVER(
					ORDER BY DocDate
					ROWS BETWEEN UNBOUNDED PRECEDING
					AND CURRENT ROW)
			) as TotalDelta

		from t
	),
	result as 
	(
		select [Id!!Id]=DocId, DocId, DocType, DocNumber, DocDate, PartnerName, ContractName, OperationName, ExpenditureName, 
			@SumBegin + TotalDelta - Delta as SumBefore, SumIn, SumOut, @SumBegin + TotalDelta as SumAfter,
			TypeEditUrl = N'/document/' + trim(lower(DocType)) + N'/edit/'
		from totals
	)
	select [Operations!TOperation!Array]=null, *, [!!RowCount] = (select count(1) from result)
	from result
	order by DocDate;

	select [CashAccount!TCashAccount!Object]=null, [Id!!Id] = ca.Id, [Name!!Name] = ca.[Name], 
		Company = c.[Name], SumBegin = @SumBegin, SumEnd = @SumEnd
	from sunapi.CashAccounts as ca
	left join sunapi.Companies as c on c.Id = ca.Company
	where ca.Id=@Id;


	select [!$System!] = null, 
--		[!CashAccount!PageSize] = @PageSize, 
--		[!CashAccount!SortOrder] = @Order, 
--		[!CashAccount!SortDir] = @Dir,
--		[!CashAccount!Offset] = @Offset,
--		[!CashAccount!HasRows] = case when exists(select * from sunapi.Products) then 1 else 0 end,
		[!Operations.Period.From!Filter] = @From,
		[!Operations.Period.To!Filter] = @To;

end
go


------------------------------------------------
create or alter procedure sunapi.[Report.CashFlows.Index]
@UserId bigint,
@From date = null,
@To date = null,
@Company bigint = null,
@CashAccount bigint = null,
@Partner bigint = null
as
begin

	set nocount on;

	declare @currentDate DATE = GETDATE();
	if (@From IS NULL)
		set @From = DATEADD(DAY, 1, EOMONTH(@currentDate, -1));
	if (@To IS NULL)
		set @To = EOMONTH(@currentDate);


	with T([Id!!Id], OperationId, OperationName, ExpenditureId, ExpenditureName, SumIn, SumOut)
	as( 
		select 0, OperationId, OperationName, ExpenditureId, ExpenditureName, sum(SumIn) as SumIn, sum(SumOut) as SumOut
		from sunapi.CashFlowsView
		where 
			DocType in ('INCOME_PAYMENT', 'OUTGOING_PAYMENT') 
			and (@Company is null or CompanyId = @Company)
			and (@CashAccount is null or CashAccountId = @CashAccount)
			and (@Partner is null or PartnerId = @Partner)
			and (Date >= @From and Date < sunapi.GetNextDay(@To)) --(CAST(Date as date) BETWEEN @From AND @To)
		group by OperationId, OperationName, ExpenditureId, ExpenditureName
		
	)
	select [CashFlows!TCashFlow!Array]=null, *, [!!RowCount] = (select count(1) from T)
		from T
		order by OperationName, ExpenditureName;

	select [!$System!] = null, 
--		[!CashAccounts!SortOrder] = @Order, 
--		[!CashAccounts!SortDir] = @Dir,
		[!CashFlows.Period.From!Filter] = @From,
		[!CashFlows.Period.To!Filter] = @To,
		[!CashFlows.Company.Id!Filter] = @Company,
		[!CashFlows.Company.Name!Filter] = (select [Name] from sunapi.Companies where Id=@Company),
		[!CashFlows.CashAccount.Id!Filter] = @CashAccount,
		[!CashFlows.CashAccount.Name!Filter] = (select [Name] from sunapi.CashAccounts where Id=@CashAccount),
		[!CashFlows.Partner.Id!Filter] = @Partner,
		[!CashFlows.Partner.Name!Filter] = (select [Name] from sunapi.Partners where Id=@Partner);
end
go
------------------------------------------------
create or alter procedure sunapi.[Report.CashFlows.Load]
@UserId bigint,
@Id bigint = null,
@From date = null,
@To date = null,
@Company bigint = null,
@CashAccount bigint = null,
@Partner bigint = null,
@Operation bigint = null, 
@Expenditure bigint = null
as
begin
	set nocount on;

	declare @currentDate DATE = GETDATE();
	if (@From IS NULL)
		set @From = DATEADD(DAY, 1, EOMONTH(@currentDate, -1));
	if (@To IS NULL)
		set @To = EOMONTH(@currentDate);

	with T([Id!!Id], [Date], DocId, DocType, SumIn, SumOut, CashAccountId, CashAccountName, OperationId, OperationName, ExpenditureId, ExpenditureName, CompanyId, CompanyName, PartnerId, PartnerName)
	as( 
		select Id, [Date], DocId, DocType, SumIn, SumOut, CashAccountId, CashAccountName, OperationId, OperationName, ExpenditureId, ExpenditureName, CompanyId, CompanyName, PartnerId, PartnerName
		from sunapi.CashFlowsView 
		where 
			DocType in ('INCOME_PAYMENT', 'OUTGOING_PAYMENT')
			and (@Company is null or CompanyId = @Company)
			and (@CashAccount is null or CashAccountId = @CashAccount)
			and (@Partner is null or PartnerId = @Partner)
			and (@Operation is null or OperationId = @Operation)
			and (@Expenditure is null or ExpenditureId = @Expenditure)
			and (Date >= @From and Date < sunapi.GetNextDay(@To)) -- (CAST([Date] as date) BETWEEN @From AND @To)
	)
	select [CashFlows!TCashFlow!Array]=null, *, DocNumber = sunapi.FormatNumber8(DocId, DocType), [!!RowCount] = (select count(1) from T)
		from T
		order by [Date];

	select [!$System!] = null, 
--		[!CashAccounts!SortOrder] = @Order, 
--		[!CashAccounts!SortDir] = @Dir,
		[!CashFlows.Period.From!Filter] = @From,
		[!CashFlows.Period.To!Filter] = @To,
		[!CashFlows.Company.Id!Filter] = @Company,
		[!CashFlows.Company.Name!Filter] = (select [Name] from sunapi.Companies where Id=@Company),
		[!CashFlows.CashAccount.Id!Filter] = @CashAccount,
		[!CashFlows.CashAccount.Name!Filter] = (select [Name] from sunapi.CashAccounts where Id=@CashAccount),
		[!CashFlows.Partner.Id!Filter] = @Partner,
		[!CashFlows.Partner.Name!Filter] = (select [Name] from sunapi.Partners where Id=@Partner),
		[!CashFlows.Operation.Id!Filter] = @Operation,
		[!CashFlows.Operation.Name!Filter] = (select [Name] from sunapi.Operations where Id=@Operation),
		[!CashFlows.Expenditure.Id!Filter] = @Expenditure,
		[!CashFlows.Expenditure.Name!Filter] = (select [Name] from sunapi.Expenditures where Id=@Expenditure);
end
go
------------------------------------------------
create or alter procedure sunapi.[Report.ProductMoves.Index]
@UserId bigint,
@Offset int = 0,
@PageSize int = 20,
@From date = null,
@To date = null,
@Product bigint = null,
@Company bigint = null,
@Partner bigint = null,
@Store bigint = null
as
begin

	set nocount on;

	declare @currentDate DATE = GETDATE();
	if (@From IS NULL)
		set @From = DATEADD(DAY, 1, EOMONTH(@currentDate, -1));
	if (@To IS NULL)
		set @To = EOMONTH(@currentDate);


	with T as 
	(
		select det.Id, det.Document as DocId, det.Product as ProductId, det.Price, det.Qty, det.Sum, 
			doc.Date as DocDate, doc.Type as DocType, doc.Done as Done, doc.Number as DocNumber,
			doc.StoreFrom, doc.StoreTo,
			QtyIn = det.Qty, QtyOut = null

		from sunapi.Details as det
		left join sunapi.Documents as doc on doc.Id = det.Document
		where 
			doc.Done = 1 
			and (doc.Date >= @From and doc.Date < sunapi.GetNextDay(@To)) -- (CAST(doc.Date as date) BETWEEN @From AND @To)
			and (det.Product = @Product)
			and (@Company is null or doc.Company = @Company)
			and (@Partner is null or doc.[Partner] = @Partner)
			and (
				(doc.Type in ('INCOME_INVOICE') and (@Store is null or doc.StoreTo = @Store))
				or (doc.Type in ('STOCKS_MOVE') and (@Store is null or doc.StoreTo = @Store))
			) -- @Store rule in unions is different !!!

		union  

		select det.Id, det.Document as DocId, det.Product as ProductId, det.Price, det.Qty, det.Sum, 
			doc.Date as DocDate, doc.Type as DocType, doc.Done as Done, doc.Number as DocNumber,
			doc.StoreFrom, doc.StoreTo,
			QtyIn = null, QtyOut = det.Qty

		from sunapi.Details as det
		left join sunapi.Documents as doc on doc.Id = det.Document
		where 
			doc.Done = 1 
			and (doc.Date >= @From and doc.Date < sunapi.GetNextDay(@To)) -- (CAST(doc.Date as date) BETWEEN @From AND @To)
			and (det.Product = @Product)
			and (@Company is null or doc.Company = @Company)
			and (@Partner is null or doc.[Partner] = @Partner)
			and (
				(doc.Type in ('OUTGOING_INVOICE') and (@Store is null or doc.StoreFrom = @Store))
				or (doc.Type in ('STOCKS_MOVE') and (@Store is null or doc.StoreFrom = @Store))
			)	-- @Store rule in unions is different !!!

	),
	RES as (
		select 
			[ProductMoves!TProductMove!Array] = null, det.*,
			prod.IsService as ProductIsService, prod.Name as ProductName,  prod.Article as ProductArticle,
			prod.Unit as ProductUnitId, unit.Name as UnitName,
			doc.Partner as PartnerId, p.Name as PartnerName,
			prod.Section as SectionId, sect.Name as SectionName, 
			doc.Company as CompanyId, c.Name as CompanyName, 
			doc.StoreFrom as StoreFromId, sf.Name as StoreFromName, 
			doc.StoreTo as StoreToId, st.Name as StoreToName,
			PartnerNameMixed = IIF((DocType = 'STOCKS_MOVE'), 
				(case when QtyIn is not null then sf.Name when QtyOut is not null then st.Name else N'' end), 
				p.Name),
			StoreNameMixed = IIF((DocType = 'STOCKS_MOVE'), 
				(case when QtyIn is not null then st.Name when QtyOut is not null then sf.Name else N'' end), 
				(case when DocType = 'INCOME_INVOICE' then st.Name when DocType = 'OUTGOING_INVOICE' then sf.Name else N'' end)),
			DocNumberFormatted = sunapi.FormatNumber8(det.DocNumber, det.DocType),
			[!!RowNumber] = row_number() over (
				order by DocDate
			)
		from T as det
		left join sunapi.Documents as doc on doc.Id = det.DocId
		left join sunapi.Products as prod on prod.Id = det.ProductId
		left join sunapi.Units as unit on unit.Id = prod.Unit
		left join sunapi.Stores as sf on sf.Id = doc.StoreFrom
		left join sunapi.Stores as st on st.Id = doc.StoreTo
		left join sunapi.Partners as p on p.Id = doc.Partner
		left join sunapi.Companies as c on c.Id = doc.Company
		left join sunapi.Sections as sect on sect.Id = prod.Section
	)
	select *, [!!RowCount] = (select count(1) from RES)
	from RES
	where [!!RowNumber] > @Offset and [!!RowNumber] <= @Offset + @PageSize
	order by [!!RowNumber];

	select [!$System!] = null, 
		[!ProductMoves!PageSize] = @PageSize, 
		[!ProductMoves!Offset] = @Offset,
--		[!ProductMoves!SortOrder] = @Order, 
--		[!ProductMoves!SortDir] = @Dir,
		[!ProductMoves.Period.From!Filter] = @From,
		[!ProductMoves.Period.To!Filter] = @To,
		[!ProductMoves.Product.Id!Filter] = @Product,
		[!ProductMoves.Product.Name!Filter] = (select [Name] from sunapi.Products where Id=@Product),
		[!ProductMoves.Company.Id!Filter] = @Company,
		[!ProductMoves.Company.Name!Filter] = (select [Name] from sunapi.Companies where Id=@Company),
		[!ProductMoves.Partner.Id!Filter] = @Partner,
		[!ProductMoves.Partner.Name!Filter] = (select [Name] from sunapi.Partners where Id=@Partner),
		[!ProductMoves.Store.Id!Filter] = @Store,
		[!ProductMoves.Store.Name!Filter] = (select [Name] from sunapi.Stores where Id=@Store);

end
go
------------------------------------------------
create or alter procedure sunapi.[Report.Balances.Index]
@UserId bigint,
@From date = null,
@To date = null,
@Company bigint = null,
@Contract bigint = null

as
begin

	set nocount on;

	declare @currentDate DATE = GETDATE();
	if (@From IS NULL)
		set @From = DATEADD(DAY, 1, EOMONTH(@currentDate, -1));
	if (@To IS NULL)
		set @To = EOMONTH(@currentDate);

	with T as (
		select Id, Date, [Sum], SumIn, SumOut, PartnerId, PartnerName
		from sunapi.BalancesView
		where 
			(Date >= @From and Date < sunapi.GetNextDay(@To)) -- CAST(Date as date) >= @From and CAST(Date as date) <= @To
			and (@Company is null or CompanyId = @Company)
			and (@Contract is null or ContractId = @Contract)
	)
	select [Balances!TBalance!Array] = null, [Id!!Id] = t.PartnerId, t.PartnerName, 
		(	
			select coalesce(Sum(bv.Sum), 0) 
			from sunapi.BalancesView as bv 
			where bv.PartnerId = t.PartnerId and CAST(bv.Date as date) < @From
			and (@Company is null or CompanyId = @Company)
			and (@Contract is null or ContractId = @Contract)
		) as SumBegin,
		sum(t.SumIn) as SumIn, sum(t.SumOut) as SumOut,
		(
			select coalesce(Sum(bv.Sum), 0) 
			from sunapi.BalancesView as bv 
			where bv.PartnerId = t.PartnerId and CAST(bv.Date as date) <= @To
			and (@Company is null or CompanyId = @Company)
			and (@Contract is null or ContractId = @Contract)
		) as SumEnd
	from T as t
	group by PartnerId, PartnerName
	order by PartnerName;


	select [!$System!] = null, 
--		[!Balances!PageSize] = @PageSize, 
--		[!Balances!SortOrder] = @Order, 
--		[!Balances!SortDir] = @Dir,
--		[!Balances!Offset] = @Offset,
		[!Balances.Period.From!Filter] = @From,
		[!Balances.Period.To!Filter] = @To,
		[!Balances.Company.Id!Filter] = @Company,
		[!Balances.Company.Name!Filter] = (select [Name] from sunapi.Companies where Id=@Company),
		[!Balances.Contract.Id!Filter] = @Contract,
		[!Balances.Contract.Name!Filter] = (select [Name] from sunapi.Contracts where Id=@Contract);


end
go
------------------------------------------------
create or alter procedure sunapi.[Report.Balances.Load]
@UserId bigint,
@Id bigint,
@From datetime = null,
@To datetime = null,
@Company bigint = null,
@Contract bigint = null
as
begin
	set nocount on;

	declare @currentDate DATE = GETDATE();
	if (@From IS NULL)
		set @From = DATEADD(DAY, 1, EOMONTH(@currentDate, -1));
	if (@To IS NULL)
		set @To = EOMONTH(@currentDate);

	declare 	
		@SumBegin decimal(10,2),
		@SumEnd decimal(10,2);

	select @SumBegin = coalesce(Sum(bv.Sum), 0) 
		from sunapi.BalancesView as bv 
		where bv.PartnerId = @Id 
		and bv.[Date] < @From -- CAST(bv.Date as date) < @From
		and (@Company is null or CompanyId = @Company)
		and (@Contract is null or ContractId = @Contract);

	select @SumEnd = coalesce(Sum(bv.Sum), 0) 
		from sunapi.BalancesView as bv 
		where bv.PartnerId = @Id 
		and bv.[Date] < sunapi.GetNextDay(@To) -- CAST(bv.Date as date) <= @To
		and (@Company is null or CompanyId = @Company)
		and (@Contract is null or ContractId = @Contract);

	with t as
	(
	select DocId, [Sum], SumIn, SumOut, [Type], [Date], Number, 
		PartnerId, PartnerName, CompanyId, CompanyName, ContractId, ContractName, 
		OperationId, OperationName, ExpenditureId, ExpenditureName,
		SUM(SumIn) OVER(ORDER BY [Date] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalIn,
		SUM(SumOut) OVER(ORDER BY [Date] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalOut
	from sunapi.BalancesView
	where PartnerId = @Id 
		and ([Date] >= @From and [Date] < sunapi.GetNextDay(@To)) -- CAST(Date as date) >= @From and CAST(Date as date) <= @To
		and (@Company is null or CompanyId = @Company)
		and (@Contract is null or ContractId = @Contract)
	)
	select 
		[Operations!TOperation!Array]=null, [Id!!Id]=DocId,
		DocId, [Sum], SumIn, SumOut, [Type], [Date], Number, DocNumberFormatted = sunapi.FormatNumber8(Number, [Type]),
		PartnerId, PartnerName, CompanyId, CompanyName, ContractId, ContractName, 
		OperationId, OperationName, ExpenditureId, ExpenditureName,
		TotalIn, TotalOut,
		@SumBegin + TotalIn - TotalOut - SumIn + SumOut as TotalBegin,
		@SumBegin + TotalIn - TotalOut as TotalEnd
	from t
	order by [Date];

	select [Balance!TBalance!Object]=null, SumBegin = @SumBegin, SumEnd = @SumEnd;

	/*
	select [Balance!TBalance!Object]=null, [Id!!Id] = @Id, [Name!!Name] = p.[Name], CompanyId = comp.Id, CompanyName = comp.[Name], ContractId = ct.Id, ContractName = ct.[Name]
	from sunapi.CashAccounts as ca
	left join sunapi.Partners as p on p.Id = @Id
	left join sunapi.Companies as comp on comp.Id = @Company
	left join sunapi.Contracts as ct on ct.Id = @Contract
	where ca.Id=@Id;
	*/


	select [!$System!] = null, 
--		[!CashAccount!PageSize] = @PageSize, 
--		[!CashAccount!SortOrder] = @Order, 
--		[!CashAccount!SortDir] = @Dir,
--		[!CashAccount!Offset] = @Offset,
--		[!CashAccount!HasRows] = case when exists(select * from sunapi.Products) then 1 else 0 end,
		[!Operations.Period.From!Filter] = @From,
		[!Operations.Period.To!Filter] = @To,
		[!Operations.Company.Id!Filter] = @Company,
		[!Operations.Company.Name!Filter] = (select [Name] from sunapi.Companies where Id=@Company);

end
go


------------------------------------------------

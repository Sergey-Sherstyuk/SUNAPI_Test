-----------------
----- Units -----
-----------------

------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'sunapi' and SEQUENCE_NAME=N'SQ_Units')
	create sequence sunapi.SQ_Units as bigint start with 150 increment by 1;
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'sunapi' and TABLE_NAME=N'Units')
begin
	create table sunapi.Units
	(
		Id	bigint not null constraint PK_Units primary key
			constraint DF_Units_PK default(next value for sunapi.SQ_Units),
		[Name] nvarchar(32) not null,
		FullName nvarchar(255) not null,
		Memo nvarchar(255) null,
		DateCreated datetime not null constraint DF_Units_DateCreated default(getdate()),
		UserCreated bigint not null
			constraint FK_Units_UserCreated_Users foreign key references a2security.Users(Id),
		DateModified datetime not null constraint DF_Units_DateModified default(getdate()),
		UserModified bigint not null
			constraint FK_Units_UserModified_Users foreign key references a2security.Users(Id)
	);
end
go
------------------------------------------------
create or alter procedure sunapi.[Unit.Index]
@UserId bigint,
@Id bigint = null,
@Offset int = 0,
@PageSize int = 10,
@Order nvarchar(255) = N'Name',
@Dir nvarchar(20) = N'asc'

as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	declare @Asc nvarchar(10), @Desc nvarchar(10), @RowCount int;
	set @Asc = N'asc'; set @Desc = N'desc';
	set @Dir = isnull(@Dir, @Asc);

	with T([Id!!Id], [Name], FullName, Memo, [!!RowNumber])
	as(
		select u.Id, u.[Name], u.FullName, u.Memo, [!!RowNumber] = row_number() over (
			order by
				case when @Order=N'Id' and @Dir = @Asc then u.Id end asc,
				case when @Order=N'Id' and @Dir = @Desc  then u.Id end desc,
				case when @Order=N'Name' and @Dir = @Asc then u.[Name] end asc,
				case when @Order=N'Name' and @Dir = @Desc then u.[Name] end desc,
				case when @Order=N'FullName' and @Dir = @Asc then u.FullName end asc,
				case when @Order=N'FullName' and @Dir = @Desc then u.FullName end desc
			)
			from sunapi.Units as u
	)
	select [Units!TUnit!Array]=null, *, [!!RowCount] = (select count(1) from T)
		from T
		where [!!RowNumber] > @Offset and [!!RowNumber] <= @Offset + @PageSize
		order by [!!RowNumber];

	select [!$System!] = null, 
		[!Units!PageSize] = @PageSize, 
		[!Units!SortOrder] = @Order, 
		[!Units!SortDir] = @Dir,
		[!Units!Offset] = @Offset,
		[!Units!HasRows] = case when exists(select * from sunapi.Units) then 1 else 0 end
end
go
-------------------------------------------------
create or alter procedure sunapi.[Unit.Load]
@UserId bigint,
@Id bigint = null,
@Text nvarchar(255) = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	select [Unit!TUnit!Object] = null, [Id!!Id] = Id, [Name], FullName, Memo
	from sunapi.Units
	where Id=@Id;

	select [Params!TParam!Object] = null, [Text] = @Text;
end
go
-------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'sunapi' and ROUTINE_NAME=N'Unit.Update')
	drop procedure sunapi.[Unit.Update]
go
------------------------------------------------
if exists(select * from INFORMATION_SCHEMA.DOMAINS where DOMAIN_SCHEMA=N'sunapi' and DOMAIN_NAME=N'Unit.TableType' and DATA_TYPE=N'table type')
	drop type sunapi.[Unit.TableType];
go
------------------------------------------------
create type sunapi.[Unit.TableType]
as table(
	Id bigint null,
	[Name] nvarchar(255),
	FullName nvarchar(255),
	Memo nvarchar(255)
)
go
-------------------------------------------------
create or alter procedure sunapi.[Unit.Metadata]
as
begin
	set nocount on;
	declare @Unit sunapi.[Unit.TableType];
	select [Unit!Unit!Metadata] = null, * from @Unit;
end
go
-------------------------------------------------
create or alter procedure sunapi.[Unit.Update]
@UserId bigint,
@Unit sunapi.[Unit.TableType] readonly,
@RetId bigint = null output
as
begin
	set nocount on;
	set transaction isolation level serializable;
	set xact_abort on;

	declare @output table(op nvarchar(150), id bigint);

	merge sunapi.Units as target
	using @Unit as source
	on (target.Id = source.Id)
	when matched then
		update set 
			target.[Name] = source.[Name],
			target.FullName = source.FullName,
			target.Memo = source.Memo,
			target.UserModified = @UserId
	when not matched by target then 
		insert ([Name], FullName, Memo, UserCreated, UserModified)
		values ([Name], FullName, Memo, @UserId, @UserId)
	output 
		$action op,
		inserted.Id id
	into @output(op, id);

	select top(1) @RetId = id from @output;

	exec sunapi.[Unit.Load] @UserId, @RetId;
end
go
-------------------------------------------------
create or alter procedure sunapi.[Unit.Delete]
@UserId bigint,
@Id bigint
as
begin
	set nocount on;
	set transaction isolation level serializable;
	set xact_abort on;
	delete from sunapi.Units where Id=@Id;
end
go
-------------------------------------------------
create or alter procedure sunapi.[Unit.Fetch]
	@UserId bigint,
	@Search nvarchar(255) = null
as
begin
	set nocount on
	set transaction isolation level read uncommitted;

	if @Search is not null
		set @Search = N'%' + upper(@Search) + N'%';

	select [Units!TUnit!Array]=null, [Id!!Id] = Id, [Name!!Name] = [Name], FullName, Memo
	from sunapi.Units
		where (upper([Name]) like @Search or upper(Memo) like @Search or cast(Id as nvarchar) like @Search)
	order by [Name]
end
go
-------------------------------------------------


--------------------
----- Sections -----
--------------------

------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'sunapi' and SEQUENCE_NAME=N'SQ_Sections')
	create sequence sunapi.SQ_Sections as bigint start with 150 increment by 1;
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'sunapi' and TABLE_NAME=N'Sections')
begin
	create table sunapi.Sections
	(
		Id	bigint not null constraint PK_Sections primary key
			constraint DF_Sections_PK default(next value for sunapi.SQ_Sections),
		[Name] nvarchar(255) null,
		ParentSectionId bigint null
			constraint FK_Sections_ParentSectionId_Sections foreign key references sunapi.Sections(Id),
		Memo nvarchar(255) null,
		DateCreated datetime not null constraint DF_Sections_DateCreated default(getdate()),
		UserCreated bigint not null
			constraint FK_Sections_UserCreated_Users foreign key references a2security.Users(Id),
		DateModified datetime not null constraint DF_Sections_DateModified default(getdate()),
		UserModified bigint not null
			constraint FK_Sections_UserModified_Users foreign key references a2security.Users(Id)
	);
end
go
------------------------------------------------
IF OBJECT_ID('sunapi.SectionsTree') IS NOT NULL
	DROP VIEW sunapi.SectionsTree;
GO
-------------------------------------------------
CREATE VIEW sunapi.SectionsTree
AS
	WITH Sections(Name, Id, Memo, Level, Sort)
	AS (SELECT CONVERT(varchar(255), e.Name),
			e.Id,
			e.Memo,
			1,
			CONVERT(varchar(255), e.Name)
		FROM sunapi.Sections AS e
		WHERE e.ParentSectionId IS NULL
		UNION ALL
		SELECT CONVERT(varchar(255), REPLICATE ('……' , Level) + e.Name),
			e.Id,
			e.Memo,
			Level + 1,
			CONVERT (varchar(255), RTRIM(Sort) + '>' + e.Name)
		FROM sunapi.Sections AS e
		JOIN Sections AS d ON e.ParentSectionId = d.Id
		)
	SELECT Id, Name, Memo, Level, Sort
	FROM Sections;
GO
------------------------------------------------
CREATE OR ALTER FUNCTION sunapi.Subsections
	(@Id AS BIGINT) RETURNS TABLE
AS
RETURN
	WITH SubSections AS
	(
		SELECT Id, ParentSectionId, Name
		FROM sunapi.Sections
		WHERE Id = @Id
		UNION ALL
		SELECT s.Id, s.ParentSectionId, s.Name
		FROM SubSections AS ss
		JOIN sunapi.Sections AS s
		ON s.ParentSectionId = ss.Id
	)
	SELECT Id, ParentSectionId, Name
	FROM SubSections;
GO
------------------------------------------------
create or alter procedure sunapi.[Section.Index]
@UserId bigint,
@Id bigint = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	select [Sections!TSection!Array] = null, [Id!!Id] = Id, [Name], Memo
	from sunapi.SectionsTree
	order by Sort asc;
end
go
-------------------------------------------------
create or alter procedure sunapi.[Section.Load]
@UserId bigint,
@Id bigint = null,
@Text nvarchar(255) = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;


	select [Section!TSection!Object] = null, [Id!!Id] = Id, [Name], [ParentSectionId!TParentSection!RefId] = ParentSectionId, Memo
	from sunapi.Sections
	where Id=@Id;

	select [ParentSections!TParentSection!Array] = null, [Id!!Id] = Null, [Name!!Name] = N'@[NotSet]', Sort=N' '
	union all
	select [ParentSections!TParentSection!Array] = null, [Id!!Id] = Id, [Name!!Name] = [Name], Sort
	from sunapi.SectionsTree
	where Id not in (select Id from sunapi.Subsections(@Id))
	order by Sort;

	select [Params!TParam!Object] = null, [Text] = @Text;
end
go
-------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'sunapi' and ROUTINE_NAME=N'Section.Update')
	drop procedure sunapi.[Section.Update]
go
------------------------------------------------
if exists(select * from INFORMATION_SCHEMA.DOMAINS where DOMAIN_SCHEMA=N'sunapi' and DOMAIN_NAME=N'Section.TableType' and DATA_TYPE=N'table type')
	drop type sunapi.[Section.TableType];
go
------------------------------------------------
create type sunapi.[Section.TableType]
as table(
	Id bigint null,
	[Name] nvarchar(255),
	ParentSectionId bigint null,
	Memo nvarchar(255)
)
go
-------------------------------------------------
create or alter procedure sunapi.[Section.Metadata]
as
begin
	set nocount on;
	declare @Section sunapi.[Section.TableType];
	select [Section!Section!Metadata] = null, * from @Section;
end
go
-------------------------------------------------
create or alter procedure sunapi.[Section.Update]
@UserId bigint,
@Section sunapi.[Section.TableType] readonly,
@RetId bigint = null output
as
begin
	set nocount on;
	set transaction isolation level serializable;
	set xact_abort on;

	declare @output table(op nvarchar(150), id bigint);

	merge sunapi.Sections as target
	using @Section as source
	on (target.Id = source.Id)
	when matched then
		update set 
			target.[Name] = source.[Name],
			target.ParentSectionId = source.ParentSectionId,
			target.Memo = source.Memo,
			target.UserModified = @UserId
	when not matched by target then 
		insert ([Name], ParentSectionId, Memo, UserCreated, UserModified)
		values ([Name], ParentSectionId, Memo, @UserId, @UserId)
	output 
		$action op,
		inserted.Id id
	into @output(op, id);

	select top(1) @RetId = id from @output;

	exec sunapi.[Section.Load] @UserId, @RetId;
end
go
-------------------------------------------------
create or alter procedure sunapi.[Section.Delete]
@UserId bigint,
@Id bigint
as
begin
	set nocount on;
	set transaction isolation level serializable;
	set xact_abort on;
	delete from sunapi.Sections where Id=@Id;
end
go
-------------------------------------------------
create or alter procedure sunapi.[Section.Fetch]
	@UserId bigint,
	@Search nvarchar(255) = null
as
begin
	set nocount on
	set transaction isolation level read uncommitted;

	if @Search is not null
		set @Search = N'%' + upper(@Search) + N'%';

	select [Sections!TSection!Array]=null, [Id!!Id] = Id, [Name!!Name] = [Name], ParentSectionId, Memo
	from sunapi.Sections
		where (upper([Name]) like @Search or upper(Memo) like @Search or cast(Id as nvarchar) like @Search)
	order by [Name]
end
go
-------------------------------------------------


--------------------
----- Products -----
--------------------

------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'sunapi' and SEQUENCE_NAME=N'SQ_Products')
	create sequence sunapi.SQ_Products as bigint start with 150 increment by 1;
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'sunapi' and TABLE_NAME=N'Products')
begin
	create table sunapi.Products
	(
		Id	bigint not null constraint PK_Products primary key
			constraint DF_Products_PK default(next value for sunapi.SQ_Products),
		IsService bit not null
			constraint DF_Products_IsService default(0),
		Article nvarchar(64) null,
		[Name] nvarchar(255) null,
		Memo nvarchar(255) null,
		Unit bigint null
			constraint FK_Products_Unit_Units foreign key references sunapi.Units(Id),
		Section bigint null
			constraint FK_Products_Section_Sections foreign key references sunapi.Sections(Id),
		DateCreated datetime not null constraint DF_Products_DateCreated default(getdate()),
		UserCreated bigint not null 
			constraint FK_Products_UserCreated_Users foreign key references a2security.Users(Id),
		DateModified datetime not null constraint DF_Products_DateModified default(getdate()),
		UserModified bigint not null
			constraint FK_Products_UserModified_Users foreign key references a2security.Users(Id)
	);
end
go





----------------------------------------
----- PriceTypes table declaration -----
----------------------------------------

------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'sunapi' and SEQUENCE_NAME=N'SQ_PriceTypes')
	create sequence sunapi.SQ_PriceTypes as bigint start with 150 increment by 1;
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'PriceTypes' and TABLE_SCHEMA = N'sunapi')
begin
	create table sunapi.PriceTypes (
		Id	bigint not null constraint PK_PriceTypes primary key
			constraint DF_PriceTypes_PK default(next value for sunapi.SQ_PriceTypes),
		[Name] nvarchar(255),
		Memo nvarchar(255),
		DateCreated datetime not null constraint DF_PriceTypes_DateCreated default(getdate()),
		UserCreated bigint not null
			constraint FK_PriceTypes_UserCreated_Users foreign key references a2security.Users(Id),
		DateModified datetime not null constraint DF_PriceTypes_DateModified default(getdate()),
		UserModified bigint not null
			constraint FK_PriceTypes_UserModified_Users foreign key references a2security.Users(Id)
	)
end
go





------------------------------------
----- Prices table declaration -----
------------------------------------

------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'sunapi' and SEQUENCE_NAME=N'SQ_Prices')
	create sequence sunapi.SQ_Prices as bigint start with 150 increment by 1;
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'Prices' and TABLE_SCHEMA = N'sunapi')
begin
	create table sunapi.Prices (
		Id	bigint not null constraint PK_Prices primary key
			constraint DF_Prices_PK default(next value for sunapi.SQ_Prices),
		[Date] date not null,
		Product bigint not null constraint FK_Prices_Product_Products references sunapi.Products(Id),
		PriceType bigint not null constraint FK_Prices_PriceType_PriceTypes references sunapi.PriceTypes(Id),
		Price decimal(16,2),
		DateCreated datetime not null constraint DF_Prices_DateCreated default(getdate()),
		UserCreated bigint not null
			constraint FK_Prices_UserCreated_Users foreign key references a2security.Users(Id),
		DateModified datetime not null constraint DF_Prices_DateModified default(getdate()),
		UserModified bigint not null
			constraint FK_Prices_UserModified_Users foreign key references a2security.Users(Id)
	)
end
go
-------------------------------------------------





-------------------------------
----- Products procedures -----
-------------------------------

-------------------------------------------------
create or alter procedure sunapi.[Product.Index]
@UserId bigint,
@Id bigint = null,
@Offset int = 0,
@PageSize int = 10,
@Order nvarchar(255) = N'Name',
@Dir nvarchar(20) = N'asc',
@Section bigint = null,
@IsService bit = null,
@Fragment nvarchar(255) = null

as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	declare @InitFragment nvarchar(255) = @Fragment;

	if @Fragment is not null
		set @Fragment = N'%' + upper(@Fragment) + N'%';

	declare @Asc nvarchar(10), @Desc nvarchar(10), @RowCount int;
	set @Asc = N'asc'; 
	set @Desc = N'desc';
	set @Dir = isnull(@Dir, @Asc);

	with T([Id!!Id], IsService, Article, [Name], Memo, [Unit.Id!TUnit!Id], [Unit.Name!TUnit!], [Section.Id!TSecton!Id], [Section.Name!TSecton!], [!!RowNumber])
	as(
		select p.Id, p.IsService, p.Article, p.[Name], p.Memo, Unit, u.Name, Section, s.Name, [!!RowNumber] = row_number() over (
			 order by
				case when @Order=N'Id' and @Dir = @Asc then p.Id end asc,
				case when @Order=N'Id' and @Dir = @Desc  then p.Id end desc,
				case when @Order=N'Name' and @Dir = @Asc then p.[Name] end asc,
				case when @Order=N'Name' and @Dir = @Desc then p.[Name] end desc,
				case when @Order=N'Article' and @Dir = @Asc then p.Article end asc,
				case when @Order=N'Article' and @Dir = @Desc then p.Article end desc,
				case when @Order=N'Memo' and @Dir = @Asc then p.Memo end asc,
				case when @Order=N'Memo' and @Dir = @Desc then p.Memo end desc,
				case when @Order=N'Section.Name' and @Dir = @Asc then s.Name end asc,
				case when @Order=N'Section.Name' and @Dir = @Desc then s.Name end desc
			)
			from sunapi.Products as p
			left join sunapi.Units as u on p.Unit = u.Id
			left join sunapi.Sections as s on p.Section = s.Id
			where 
				(@Fragment is null or upper(p.[Name]) like @Fragment or upper(p.[Article]) like @Fragment or cast(p.Id as nvarchar) like @Fragment)
				and
				(@Section is null or p.Section = @Section)
				and
				(@IsService is null or p.IsService = @IsService)
	)
	select [Products!TProduct!Array]=null, *, [!!RowCount] = (select count(1) from T)
		from T
		where [!!RowNumber] > @Offset and [!!RowNumber] <= @Offset + @PageSize
		order by [!!RowNumber];

	select [!$System!] = null, 
		[!Products!PageSize] = @PageSize, 
		[!Products!SortOrder] = @Order, 
		[!Products!SortDir] = @Dir,
		[!Products!Offset] = @Offset,
		[!Products!HasRows] = case when exists(select * from sunapi.Products) then 1 else 0 end,
		[!Products.Section.Id!Filter] = @Section,
		[!Products.Section.Name!Filter] = (select [Name] from sunapi.Sections where Id=@Section),
		[!Products.Fragment!Filter] = @InitFragment

end
go
------------------------------------------------
create or alter procedure sunapi.[Product.Load]
	@UserId bigint,
	@Id bigint = null,
	@Text nvarchar(255) = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;
	select [Product!TProduct!Object] = null, [Id!!Id] = Id, IsService, Article, [Name!!Name] = [Name], Memo, [Unit!TUnit!RefId] = Unit, [Section!TSection!RefId] = Section,
		DateCreated, DateModified, [UserCreated!TUser!RefId] = UserCreated, [UserModified!TUser!RefId] = UserModified
		from sunapi.Products where Id=@Id;

	select [Units!TUnit!Array] = null, [Id!!Id] = Id, [Name!!Name] = [Name]
		from sunapi.Units;

	select [Sections!TSection!Array] = null, [Id!!Id] = Id, [Name!!Name] = [Name]
		from sunapi.SectionsTree
		order by Sort asc;

	select [PriceTypes!TPriceType!Array] = null,  [Id!!Id] = pt.Id, [Name!!Name] = pt.[Name], Price = (
		select top(1) Price 
		from sunapi.Prices as p 
		where p.Product=@Id and p.PriceType = pt.Id and p.[Date] <= getdate()
		order by [Date] desc
	)
	from sunapi.PriceTypes as pt;

	select [!TUser!Map] = null, [Id!!Id] = u.Id,  [Name!!Name] = isnull(u.PersonName, u.UserName)
		from a2security.ViewUsers u
		inner join sunapi.Products p on u.Id in (p.UserCreated, p.UserModified)
		where p.Id=@Id;

	select [Params!TParam!Object] = null, [Text] = @Text;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'sunapi' and ROUTINE_NAME=N'Product.Metadata')
	drop procedure sunapi.[Product.Metadata]
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'sunapi' and ROUTINE_NAME=N'Product.Update')
	drop procedure sunapi.[Product.Update]
go
------------------------------------------------
if exists(select * from INFORMATION_SCHEMA.DOMAINS where DOMAIN_SCHEMA=N'sunapi' and DOMAIN_NAME=N'Product.TableType' and DATA_TYPE=N'table type')
	drop type sunapi.[Product.TableType];
go
------------------------------------------------
create type sunapi.[Product.TableType]
as table(
	Id bigint null,
	IsService bit,
	Article nvarchar(64) null,
	[Name] nvarchar(255),
	[Memo] nvarchar(255),
	Unit bigint,
	Section bigint
)
go
-------------------------------------------------
create or alter procedure sunapi.[Product.Metadata]
as
begin
	set nocount on;
	declare @Product sunapi.[Product.TableType];
	select [Product!Product!Metadata] = null, * from @Product;
end
go
-------------------------------------------------
create or alter procedure sunapi.[Product.Update]
@UserId bigint,
@Product sunapi.[Product.TableType] readonly,
@RetId bigint = null output
as
begin
	set nocount on;
	set transaction isolation level serializable;
	set xact_abort on;

	declare @output table(op nvarchar(150), id bigint);

	merge sunapi.Products as target
	using @Product as source
	on (target.Id = source.Id)
	when matched then
		update set 
			target.IsService = source.IsService,
			target.Article = source.Article,
			target.[Name] = source.[Name],
			target.Memo = source.Memo,
			target.Unit = source.Unit,
			target.Section = source.Section,
			target.[DateModified] = getdate(),
			target.[UserModified] = @UserId
	when not matched by target then 
		insert (IsService, Article, [Name], Memo, Unit, Section, UserCreated, UserModified)
		values (IsService, Article, [Name], Memo, Unit, Section, @UserId, @UserId)
	output 
		$action op,
		inserted.Id id
	into @output(op, id);

	select top(1) @RetId = id from @output;

	exec sunapi.[Product.Load] @UserId, @RetId;
end
go
------------------------------------------------
create or alter procedure sunapi.[Product.FindArticle]
	@UserId bigint,
	@Article nvarchar(64) = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;
	select top(1) [Product!TProduct!Object] = null, [Id!!Id] = p.Id, [Name!!Name] = p.[Name], Article, 
		[Unit.Id!TUnit!Id] = p.Unit, [Unit.Name!TUnit!Name] = u.[Name]
	from sunapi.Products p
		left join sunapi.Units u on p.Unit = u.Id
	where Article=@Article;
end
go
-------------------------------------------------
create or alter procedure sunapi.[Product.Delete]
@UserId bigint,
@Id bigint
as
begin
	set nocount on;
	set transaction isolation level serializable;
	set xact_abort on;
	delete from sunapi.Products where Id=@Id;
end
go
-------------------------------------------------
create or alter procedure sunapi.[Product.Fetch]
	@UserId bigint,
	@Search nvarchar(255) = null
as
begin
	set nocount on
	set nocount on;
	set transaction isolation level read uncommitted;

	if @Search is not null
		set @Search = N'%' + upper(@Search) + N'%';

	select [Products!TProduct!Array]=null, [Id!!Id] = Id, [Name!!Name] = [Name], IsService, Article, Memo
	from sunapi.Products
		where (upper([Name]) like @Search or upper(Article) like @Search
			or upper(Memo) like @Search or cast(Id as nvarchar) like @Search)
	order by [Name]
end
go
-------------------------------------------------
create or alter procedure sunapi.[Goods.Index]
@UserId bigint,
@Id bigint = null,
@Offset int = 0,
@PageSize int = 10,
@Order nvarchar(255) = N'Name',
@Dir nvarchar(20) = N'asc',
@Section bigint = null,
@Fragment nvarchar(255) = null

as
begin
	set nocount on;
	exec sunapi.[Product.Index] @UserId=@UserId, @Id=@Id, @Offset=@Offset, 
		@PageSize=@PageSize, @Order=@Order, @Dir=@Dir, 
		@Section=@Section, @IsService=0, @Fragment=@Fragment;
end
go
------------------------------------------------
create or alter procedure sunapi.[Services.Index]
@UserId bigint,
@Id bigint = null,
@Offset int = 0,
@PageSize int = 10,
@Order nvarchar(255) = N'Name',
@Dir nvarchar(20) = N'asc',
@Section bigint = null,
@Fragment nvarchar(255) = null

as
begin
	set nocount on;
	exec sunapi.[Product.Index] @UserId=@UserId, @Id=@Id, @Offset=@Offset, 
		@PageSize=@PageSize, @Order=@Order, @Dir=@Dir, 
		@Section=@Section, @IsService=1, @Fragment=@Fragment;
end
go
------------------------------------------------


create or alter procedure sunapi.[productPriceHistory.Index]
@UserId bigint,
@Id bigint null,
@Product bigint null

as
begin
	set nocount on;

	select [Product!TProduct]=null, [Id!!Id] = Id, [Name!!Name] = [Name]
	from sunapi.Products
	where Id = @Product;

	select [PriceType!TPriceType]=null, [Id!!Id] = Id, [Name!!Name] = [Name]
	from sunapi.PriceTypes
	where Id = @Id;

	select [Prices!TPrice!Array]=null, [Id!!Id] = Id, [Name!!Name] = [Date], [Date], Product, PriceType, Price
	from sunapi.Prices
		where (PriceType = @Id and Product = @Product)
	order by [Date] desc;

end
go

------------------------------------------------

create or alter procedure sunapi.[Price.Load]
@UserId bigint,
@Id bigint = null,
@Product bigint = null,
@PriceType bigint = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	if (@Id > 0)
		select [Price!TPrice!Object] = null, [Id!!Id] = price.Id, [Date], price.Price,
			[Product!TProduct!RefId] = price.Product,
			[PriceType!TPriceType!RefId] = price.PriceType,
			price.DateCreated, price.UserCreated, price.DateModified, price.UserModified
		from sunapi.Prices as price
		left join sunapi.Products as prod on prod.Id = price.Product
		left join sunapi.PriceTypes as ptype on ptype.Id = price.PriceType
		where price.Id=@Id;
	else
		select [Price!TPrice!Object] = null, [Id!!Id] = 0, [Date] = GETDATE(), Price = null,
			[Product!TProduct!RefId] = @Product,
			[PriceType!TPriceType!RefId] = @PriceType;

	select [Product!TProduct!Array] = null, [Id!!Id] = Id, [Name!!Name] = [Name] 
	from sunapi.Products 
	where Id = IIF((@Id > 0), (select Product from sunapi.Prices where Id = @Id), @Product);

	select [PriceType!TPriceType!Array] = null, [Id!!Id] = Id, [Name!!Name] = [Name] 
	from sunapi.PriceTypes 
	where Id = IIF((@Id > 0), (select PriceType from sunapi.Prices where Id = @Id), @PriceType);




end
go

------------------------------------------------

-------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'sunapi' and ROUTINE_NAME=N'Price.Update')
	drop procedure sunapi.[Price.Update]
go
------------------------------------------------
if exists(select * from INFORMATION_SCHEMA.DOMAINS where DOMAIN_SCHEMA=N'sunapi' and DOMAIN_NAME=N'Price.TableType' and DATA_TYPE=N'table type')
	drop type sunapi.[Price.TableType];
go
------------------------------------------------
create type sunapi.[Price.TableType]
as table(
	Id bigint null,
	[Date] date,
	Product bigint,
	PriceType bigint,
	Price decimal(16,2)
)
go
-------------------------------------------------
create or alter procedure sunapi.[Price.Metadata]
as
begin
	set nocount on;
	declare @Price sunapi.[Price.TableType];
	select [Price!Price!Metadata] = null, * from @Price;
end
go
-------------------------------------------------
create or alter procedure sunapi.[Price.Update]
@UserId bigint,
@Price sunapi.[Price.TableType] readonly,
@RetId bigint = null output
as
begin
	set nocount on;
	set transaction isolation level serializable;
	set xact_abort on;

	declare @output table(op nvarchar(150), id bigint);

	merge sunapi.Prices as target
	using @Price as source
	on (target.Id = source.Id)
	when matched then
		update set 
			target.[Date] = source.[Date],
			target.[Price] = source.[Price],
			target.UserModified = @UserId
	when not matched by target then 
		insert ([Date], Product, PriceType, Price, UserCreated, UserModified)
		values ([Date], Product, PriceType, Price, @UserId, @UserId)
	output 
		$action op,
		inserted.Id id
	into @output(op, id);

	select top(1) @RetId = id from @output;

	exec sunapi.[Price.Load] @UserId, @RetId;
end
go
-------------------------------------------------
create or alter procedure sunapi.[Price.Delete]
@UserId bigint,
@Id bigint
as
begin
	set nocount on;
	set transaction isolation level serializable;
	set xact_abort on;
	delete from sunapi.Prices where Id=@Id;
end
go
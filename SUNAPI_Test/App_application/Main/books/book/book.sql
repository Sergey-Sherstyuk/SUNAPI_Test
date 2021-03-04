-----------------
----- Books -----
-----------------

------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'books' and SEQUENCE_NAME=N'SQ_Books')
	create sequence books.SQ_Books as bigint start with 100 increment by 1;
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'Books' and TABLE_SCHEMA = N'books')
begin
	create table books.Books (
		Id bigint not null constraint PK_Books primary key
			constraint DF_Books_PK default(next value for books.SQ_Books),
		[Name] nvarchar(255) not null,
		Code nvarchar(32) null,
		ISBN nvarchar(32) null,
		Author bigint null constraint FK_Books_Author_Authors foreign key references books.Authors(Id),
		Memo nvarchar(255),
		DateCreated datetime not null constraint DF_Books_DateCreated default(getdate()),
		UserCreated bigint not null
			constraint FK_Books_UserCreated_Users foreign key references a2security.Users(Id),
		DateModified datetime not null constraint DF_Books_DateModified default(getdate()),
		UserModified bigint not null
			constraint FK_Books_UserModified_Users foreign key references a2security.Users(Id)
	)
end
go

-- Book.Code
if (not exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'books' and TABLE_NAME=N'Books' and COLUMN_NAME=N'Code'))
begin
	alter table books.Books add Code nvarchar(32) null;
end
go

-- Book.ISBN
if (not exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'books' and TABLE_NAME=N'Books' and COLUMN_NAME=N'ISBN'))
begin
	alter table books.Books add ISBN nvarchar(32) null;
end
go

-- Book.Author
if (not exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'books' and TABLE_NAME=N'Books' and COLUMN_NAME=N'Author'))
begin
	alter table books.Books add Author bigint null constraint FK_Books_Author_Authors foreign key references books.Authors(Id);
end
go

-- alter Book.Name column to not null
if (exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA = 'books' and TABLE_NAME = 'Books' and COLUMN_NAME = 'Name' and IS_NULLABLE = 'YES'))
begin
	alter table books.Books alter column [Name] nvarchar(255) not null;
end
go


------------------------------------------------
----- Demo data
if not exists(select * from books.Books) 
begin
	insert into books.Books ([Name], UserCreated, UserModified)
		values 
		(N'Кобзар', 0, 0),
		(N'Лісова пісня', 0, 0);
end
go

----- Demo (new)
if ((select count(*) from books.Books) < 10) 
begin
	insert into books.Books ([Name], UserCreated, UserModified)
		values 
		(N'Apple. Эволюция компьютера', 0, 0),
		(N'Стів Джобс. Біографія засновника компанії Apple', 0, 0),
		(N'Big money. Принципы первых', 0, 0),
		(N'Історія України від діда Свирида', 0, 0),
		(N'Мастер и Маргарита', 0, 0),
		(N'Двенадцать стульев', 0, 0),
		(N'250 японских узоров для вязания на спицах.', 0, 0),
		(N'Microsoft SQL Server 2012. Основы T-SQL', 0, 0),
		(N'Гостья из будущего', 0, 0),
		(N'Енеїда', 0, 0),
		(N'Совершенный код', 0, 0),
		(N'Теория игр. Искусство стратегического мышления', 0, 0),
		(N'Краткая история времени', 0, 0),
		(N'Код да Винчи', 0, 0);
end
go

------------------------------------------------
create or alter procedure books.[Book.Index]
@UserId bigint,
@Id bigint = null,
@Offset int = 0,
@PageSize int = 10,
@Order nvarchar(255) = N'Name',
@Dir nvarchar(20) = N'asc',
@Fragment nvarchar(255) = null

as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	declare @InitFragment nvarchar(255) = @Fragment;

	if @Fragment is not null
		set @Fragment = N'%' + upper(@Fragment) + N'%';

	declare @Asc nvarchar(10), @Desc nvarchar(10), @RowCount int;
	set @Asc = N'asc'; set @Desc = N'desc';
	set @Dir = isnull(@Dir, @Asc);

	-- throw 60000, @Fragment, 0;

	/*
	select [Books!TBook!Array] = null, [Id!!Id] = b.Id, b.[Name], b.Code, b.ISBN, 
		[Author.Id!TAuthor!Id] = a.Id, [Author.Name!TAuthor] = a.[Name], b.Memo
	from books.Books as b
	left join books.Authors as a on a.Id = b.Author
	where (@Fragment is null or upper(b.[Name]) like @Fragment or cast(b.Id as nvarchar) like @Fragment);
	*/

	with T ([Id!!Id], [Name], Code, ISBN, [Author.Id!TAuthor!Id], [Author.Name!TAuthor], Memo, [!!RowNumber])
	as(
		select [Id!!Id] = b.Id, b.[Name], b.Code, b.ISBN, 
			[Author.Id!TAuthor!Id] = a.Id, [Author.Name!TAuthor] = a.[Name], b.Memo,
			[!!RowNumber] = row_number() over (
			 order by
				case when @Order=N'Id' and @Dir = @Asc then b.Id end asc,
				case when @Order=N'Id' and @Dir = @Desc  then b.Id end desc,
				case when @Order=N'Name' and @Dir = @Asc then b.[Name] end asc,
				case when @Order=N'Name' and @Dir = @Desc then b.[Name] end desc
			)
		from books.Books as b
		left join books.Authors as a on a.Id = b.Author
		where (@Fragment is null or upper(b.[Name]) like @Fragment or cast(b.Id as nvarchar) like @Fragment)
	)
	select [Books!TBook!Array] = null, *, [!!RowCount] = (select count(1) from T)
	from T
	where [!!RowNumber] > @Offset and [!!RowNumber] <= @Offset + @PageSize
	order by [!!RowNumber];

	select [!$System!] = null, 
		[!Books!PageSize] = @PageSize, 
		[!Books!SortOrder] = @Order, 
		[!Books!SortDir] = @Dir,
		[!Books!Offset] = @Offset,
		[!Books!HasRows] = case when exists(select * from books.Books) then 1 else 0 end,
		[!Books.Fragment!Filter] = @InitFragment;

end
go
------------------------------------------------
create or alter procedure books.[Book.Load]
@UserId bigint,
@Id bigint = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	select [Book!TBook!Object] = null, [Id!!Id] = Id, [Name], Code, ISBN, [Author!TAuthor!RefId] = Author, Memo
	from books.Books
	where Id = @Id;

	select [!TAuthor!Map] = null, [Id!!Id] = Id, [Name]
	from books.Authors where Id in (select Author from books.Books where Id=@Id);

end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'books' and ROUTINE_NAME=N'Book.Update')
	drop procedure books.[Book.Update];
go
------------------------------------------------
if exists(select * from INFORMATION_SCHEMA.DOMAINS where DOMAIN_SCHEMA=N'books' and DOMAIN_NAME=N'Book.TableType' and DATA_TYPE=N'table type')
	drop type books.[Book.TableType];
go
------------------------------------------------
create type books.[Book.TableType]
as table(
	Id bigint null,
	[Name] nvarchar(255),
	Code nvarchar(32),
	ISBN nvarchar(32),
	Author bigint,
	Memo nvarchar(255)
)
go
-------------------------------------------------
create or alter procedure books.[Book.Metadata]
as
begin
	set nocount on;
	declare @Book books.[Book.TableType];
	select [Book!Book!Metadata] = null, * from @Book;
end
go
-------------------------------------------------
create or alter procedure books.[Book.Update]
@UserId bigint,
@Book books.[Book.TableType] readonly,
@RetId bigint = null output
as
begin
	set nocount on;
	set transaction isolation level serializable;
	set xact_abort on;

	declare @output table(op nvarchar(150), id bigint);

	merge books.Books as target
	using @Book as source
	on (target.Id = source.Id)
	when matched then
		update set 
			target.[Name] = source.[Name],
			target.[Code] = source.[Code],
			target.[ISBN] = source.[ISBN],
			target.[Author] = source.[Author],
			target.[Memo] = source.[Memo],
			target.UserModified = @UserId
	when not matched by target then 
		insert ([Name], Code, ISBN, Author, Memo, UserCreated, UserModified)
		values ([Name], Code, ISBN, Author, Memo, @UserId, @UserId)
	output 
		$action op,
		inserted.Id id
	into @output(op, id);

	select top(1) @RetId = id from @output;

	exec books.[Book.Load] @UserId = @UserId, @Id = @RetId;
end
go
-------------------------------------------------
create or alter procedure books.[Book.Delete]
@UserId bigint,
@Id bigint = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	delete from books.Books
	where Id = @Id;

end
go
-------------------------------------------------

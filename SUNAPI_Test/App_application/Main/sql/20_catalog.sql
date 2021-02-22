------------------------------------------------
create or alter procedure sunapi.[Catalog.Index]
@UserId bigint,
@Id bigint = null

as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	with T(Id, ParentSectionId, [Level])
	as (
		select Id, ParentSectionId, 0 from sunapi.Sections as s where s.ParentSectionId is null
		union all
		select s.Id, s.ParentSectionId, T.[Level] + 1
		from sunapi.Sections as s inner join T on T.Id = s.ParentSectionId
	)
	select [Sections!TSection!Tree] = null, [Id!!Id] = s.Id, [Name!!Name] = s.[Name],
		[!TSection.Items!ParentId]=T.ParentSectionId, [Items!TSection!Items] = null, [Level] = T.[Level],
		[Products!TProduct!LazyArray] = null -- ### Объявление ленивого массива ###
	from sunapi.Sections as s inner join T on  s.Id = T.Id
	order by [Level], [Id!!Id];

	-- ### Структура объекта TProduct ###
	select [Products!TProduct!Array] = null, [Id!!Id] = p.Id, [Name!!Name] = p.[Name], p.IsService, p.Article, p.Memo,
		[Unit.Id!TUnit!Id] = null, [Unit.Name!TUnit!Name] = null,
		[Section.Id!TSecton!Id] = null, [Section.Name!TSecton!Name] = null
	from sunapi.Products as p
	-- left join sunapi.Units as u on p.Unit = u.Id
	where 0 <> 0

end
go
------------------------------------------------
create or alter procedure sunapi.[Catalog.Products]
@UserId bigint,
@Id bigint = null
as
begin
	set nocount on;
	
	with T([Id!!Id], [Name], IsService, Article, Memo, [Unit.Id!TUnit!Id], [Unit.Name!TUnit!], [Section.Id!TSecton!Id], [Section.Name!TSecton!Name], [!!RowNumber])
	as(
		select p.Id, p.[Name], p.IsService, p.Article, p.Memo, Unit, u.Name, Section, s.Name, [!!RowNumber] = row_number() over (order by p.Name asc)
			from sunapi.Products as p
			left join sunapi.Units as u on p.Unit = u.Id
			left join sunapi.Sections as s on p.Section = s.Id
			where 
				p.Section = @Id
				--(@Fragment is null or upper(p.[Name]) like @Fragment or upper(p.[Article]) like @Fragment or cast(p.Id as nvarchar) like @Fragment)
				--and (@IsService is null or p.IsService = @IsService)
	)
	select [Products!TProduct!Array]=null, *, [!!RowCount] = (select count(1) from T)
		from T
		--where [!!RowNumber] > @Offset and [!!RowNumber] <= @Offset + @PageSize
		order by [!!RowNumber];
end
go
------------------------------------------------
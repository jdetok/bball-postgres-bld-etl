/*
THE VIEWS & PROCEDURES DEFINED IN THIS SCRIPT ARE RESPONSIBLE FOR INSERTING
AGGREGATE PLAYER STATS INTO TABLE api.plr_agg
FOR EACH PLAYER, STATS ARE AGGREGATED BY INDIVIDUAL REGULAR/POST SEASON, 
CAREER REGULAR/POST SEASON, AND CAREER COMBINED REG/POST SEASON. 
EACH PLAYER WILL HAVE TWO ROWS PER SEASON/AGG TYPE: ONE WITH AVERAGE (PER GAME)
STATS AND ONE WITH SEASON TOTALS. S
*/
/*
drop view if exists api.v_plr_szn_tot;
drop view if exists api.v_plr_szn_avg;
drop view if exists api.v_plr_rp_tot;
drop view if exists api.v_plr_rp_avg;
drop view if exists api.v_plr_cc_tot;
drop view if exists api.v_plr_cc_avg;
*/
-- season totals
create or replace view api.v_plr_szn_tot as
select 
    a.player_id, max(a.team_id) as "team_id", d.lg, 
    a.szn_id, e.szn_desc, e.wszn_desc, 'tot' as "stype", 
    b.player, max(c.team) as "team", max(c.team_long) as "team_long",
    count(distinct a.game_id) as "gp", sum(a.mins) as "minutes",
	sum(a.pts) as "points", sum(a.ast) as "assists", 
	sum(a.reb) as "rebounds", sum(a.stl) as "steals", sum(a.blk) as "blocks", 
	sum(a.fgm) as "fgm", sum(a.fga) as "fga",
	coalesce(
		cast(round(avg(a.fgp) * 100, 2) as varchar(10)) || '%', '0%')
	as "fgp",
	sum(a.f3m) as "f3m", sum(a.f3a) as "f3a",
	coalesce(
		cast(round(avg(a.f3p) * 100, 2) as varchar(10)) || '%', '0%')
	as "f3p",
	sum(a.ftm) as "ftm", sum(a.fta) as "fta",
	coalesce(
		cast(round(avg(a.ftp) * 100, 2) as varchar(10)) || '%', '0%')
	as "ftp"
from stats.pbox a
inner join lg.plr b on b.player_id = a.player_id
inner join lg.team c on c.team_id = a.team_id
inner join lg.league d on d.lg_id = b.lg_id
inner join lg.szn e on e.szn_id = a.szn_id
where b.lg_id < 2
group by a.player_id, d.lg, a.szn_id, b.player, e.szn_desc, e.wszn_desc
order by a.szn_id desc;

-- season avgs
create or replace view api.v_plr_szn_avg as
select 
    a.player_id, max(a.team_id) as "team_id", d.lg, 
    a.szn_id, e.szn_desc, e.wszn_desc, 'avg' as "stype", 
    b.player, max(c.team) as "team", max(c.team_long) as "team_long",
    count(distinct a.game_id) as "gp", sum(a.mins) as "minutes",
    round(avg(a.pts), 2) as "points", round(avg(a.ast), 2) as "assists", 
	round(avg(a.reb), 2) as "rebounds", round(avg(a.stl), 2) as "steals", 
    round(avg(a.blk), 2) as "blocks", 
	round(avg(a.fgm), 2) as "fgm", round(avg(a.fga), 2) as "fga",
	coalesce(
		cast(round(avg(a.fgp) * 100, 2) as varchar(10)) || '%', '0%')
	as "fgp",
	round(avg(a.f3m), 2) as "f3m", round(avg(a.f3a), 2) as "f3a",
	coalesce(
		cast(round(avg(a.f3p) * 100, 2) as varchar(10)) || '%', '0%')
	as "f3p",
	round(avg(a.ftm), 2) as "ftm", round(avg(a.fta), 2) as "fta",
	coalesce(
		cast(round(avg(a.ftp) * 100, 2) as varchar(10)) || '%', '0%')
	as "ftp"
from stats.pbox a
inner join lg.plr b on b.player_id = a.player_id
inner join lg.team c on c.team_id = a.team_id
inner join lg.league d on d.lg_id = b.lg_id
inner join lg.szn e on e.szn_id = a.szn_id
where b.lg_id < 2 
group by a.player_id, d.lg, a.szn_id, b.player, e.szn_desc, e.wszn_desc
order by a.szn_id desc;

-- CAREER REGULAR/POST SEASON AGGREGATES:
-- career reg/pl avgs
create or replace view api.v_plr_rp_avg as
select 
    a.player_id, max(a.team_id) as "team_id", d.lg, 
    e.szn_id, e.szn_desc, e.wszn_desc, 'avg' as "stype", 
    b.player, max(c.team) as "team", max(c.team_long) as "team_long",
	count(distinct a.game_id) as "gp", sum(a.mins) as "minutes",
    round(avg(a.pts), 2) as "points", round(avg(a.ast), 2) as "assists", 
	round(avg(a.reb), 2) as "rebounds", round(avg(a.stl), 2) as "steals", 
    round(avg(a.blk), 2) as "blocks", 
	round(avg(a.fgm), 2) as "fgm", round(avg(a.fga), 2) as "fga",
	coalesce(
		cast(round(avg(a.fgp) * 100, 2) as varchar(10)) || '%', '0%')
	as "fgp",
	round(avg(a.f3m), 2) as "f3m", round(avg(a.f3a), 2) as "f3a",
	coalesce(
		cast(round(avg(a.f3p) * 100, 2) as varchar(10)) || '%', '0%')
	as "f3p",
	round(avg(a.ftm), 2) as "ftm", round(avg(a.fta), 2) as "fta",
	coalesce(
		cast(round(avg(a.ftp) * 100, 2) as varchar(10)) || '%', '0%')
	as "ftp"
from stats.pbox a
inner join lg.plr b on b.player_id = a.player_id
inner join lg.team c on c.team_id = a.team_id
inner join lg.league d on d.lg_id = b.lg_id
inner join lg.szn e -- reg. season and playoff aggregates
	on e.szn_id = cast(left(cast(a.szn_id as varchar(5)), 1) || '9999' as int)
where b.lg_id < 2 
group by a.player_id, d.lg, e.szn_id, b.player, e.szn_desc, e.wszn_desc;

-- career reg/pl totals
create or replace view api.v_plr_rp_tot as
select
    a.player_id, max(a.team_id) as "team_id", d.lg, 
    e.szn_id, e.szn_desc, e.wszn_desc, 'tot' as "stype", 
    b.player, max(c.team) as "team", max(c.team_long) as "team_long",
    count(distinct a.game_id) as "gp", sum(a.mins) as "minutes",
    sum(a.pts) as "points", sum(a.ast) as "assists", 
	sum(a.reb) as "rebounds", sum(a.stl) as "steals", sum(a.blk) as "blocks", 
	sum(a.fgm) as "fgm", sum(a.fga) as "fga",
	coalesce(
		cast(round(avg(a.fgp) * 100, 2) as varchar(10)) || '%', '0%')
	as "fgp",
	sum(a.f3m) as "f3m", sum(a.f3a) as "f3a",
	coalesce(
		cast(round(avg(a.f3p) * 100, 2) as varchar(10)) || '%', '0%')
	as "f3p",
	sum(a.ftm) as "ftm", sum(a.fta) as "fta",
	coalesce(
		cast(round(avg(a.ftp) * 100, 2) as varchar(10)) || '%', '0%')
	as "ftp"
from stats.pbox a
inner join lg.plr b on b.player_id = a.player_id
inner join lg.team c on c.team_id = a.team_id
inner join lg.league d on d.lg_id = b.lg_id
inner join lg.szn e -- reg. season and playoff aggregates
	on e.szn_id = cast(left(cast(a.szn_id as varchar(5)), 1) || '9999' as int)
where b.lg_id < 2 
group by a.player_id, d.lg, e.szn_id, b.player, e.szn_desc, e.wszn_desc;

-- CAREER COMBINED REGULAR SEASON/PLAYOFFS AGGREGATES
-- career avg
create or replace view api.v_plr_cc_avg as
select 
    a.player_id, max(a.team_id) as "team_id", d.lg, 
    e.szn_id, e.szn_desc, e.wszn_desc, 'avg' as "stype", 
    b.player, max(c.team) as "team", max(c.team_long) as "team_long",
    count(distinct a.game_id) as "gp", sum(a.mins) as "minutes",
    round(avg(a.pts), 2) as "points", round(avg(a.ast), 2) as "assists", 
	round(avg(a.reb), 2) as "rebounds", round(avg(a.stl), 2) as "steals", 
    round(avg(a.blk), 2) as "blocks", 
	round(avg(a.fgm), 2) as "fgm", round(avg(a.fga), 2) as "fga",
	coalesce(
		cast(round(avg(a.fgp) * 100, 2) as varchar(10)) || '%', '0%')
	as "fgp",
	round(avg(a.f3m), 2) as "f3m", round(avg(a.f3a), 2) as "f3a",
	coalesce(
		cast(round(avg(a.f3p) * 100, 2) as varchar(10)) || '%', '0%')
	as "f3p",
	round(avg(a.ftm), 2) as "ftm", round(avg(a.fta), 2) as "fta",
	coalesce(
		cast(round(avg(a.ftp) * 100, 2) as varchar(10)) || '%', '0%')
	as "ftp"
from stats.pbox a
inner join lg.plr b on b.player_id = a.player_id
inner join lg.team c on c.team_id = a.team_id
inner join lg.league d on d.lg_id = b.lg_id
inner join lg.szn e on e.szn_id = 99999
where b.lg_id < 2 
group by a.player_id, d.lg, e.szn_id, b.player, e.szn_desc, e.wszn_desc;

-- career combined totals
create or replace view api.v_plr_cc_tot as
select 
    a.player_id, max(a.team_id) as "team_id", d.lg, 
    e.szn_id, e.szn_desc, e.wszn_desc, 'tot' as "stype", 
    b.player, max(c.team) as "team", max(c.team_long) as "team_long", 
    count(distinct a.game_id) as "gp", sum(a.mins) as "minutes",
    sum(a.pts) as "points", sum(a.ast) as "assists", 
	sum(a.reb) as "rebounds", sum(a.stl) as "steals", sum(a.blk) as "blocks", 
	sum(a.fgm) as "fgm", sum(a.fga) as "fga",
	coalesce(
		cast(round(avg(a.fgp) * 100, 2) as varchar(10)) || '%', '0%')
	as "fgp",
	sum(a.f3m) as "f3m", sum(a.f3a) as "f3a",
	coalesce(
		cast(round(avg(a.f3p) * 100, 2) as varchar(10)) || '%', '0%')
	as "f3p",
	sum(a.ftm) as "ftm", sum(a.fta) as "fta",
	coalesce(
		cast(round(avg(a.ftp) * 100, 2) as varchar(10)) || '%', '0%')
	as "ftp"
from stats.pbox a
inner join lg.plr b on b.player_id = a.player_id
inner join lg.team c on c.team_id = a.team_id
inner join lg.league d on d.lg_id = b.lg_id
inner join lg.szn e on e.szn_id = 99999
where b.lg_id < 2 
group by a.player_id, d.lg, e.szn_id, b.player, e.szn_desc, e.wszn_desc;


-- ============================================================================
/* 
STORED PROCEDURE TO INSERT THE RESULTS OF THE VIEWS ABOVE INTO API TABLE
*/ 
create or replace procedure api.sp_plr_agg()
language plpgsql
as $$
begin
	raise notice e'deleting existing values in api.plr_agg\n';
    truncate api.plr_agg;

	-- season aggs
	raise notice 'inserting season totals';
    insert into api.plr_agg select * from api.v_plr_szn_tot;
	raise notice e'season totals complete: %\n', public.fn_cntstr('api.plr_agg');

	raise notice 'inserting season avgs';
	insert into api.plr_agg select * from api.v_plr_szn_avg;
	raise notice e'season avgs complete: %\n', public.fn_cntstr('api.plr_agg');

	-- reg season/playoff aggs
	raise notice 'inserting rs/playoff totals';
    insert into api.plr_agg select * from api.v_plr_rp_tot;
	raise notice e'regszn/playoff totals complete: %\n', public.fn_cntstr('api.plr_agg');

	raise notice 'inserting rs/playoff avgs';
	insert into api.plr_agg select * from api.v_plr_rp_avg;
	raise notice e'regszn/playoff avgs complete: %\n', public.fn_cntstr('api.plr_agg');

	-- combined reg season/playoff aggs
	raise notice 'inserting combined rs/playoff totals';
    insert into api.plr_agg select * from api.v_plr_cc_tot;
	raise notice e'combined totals complete: %\n', public.fn_cntstr('api.plr_agg');

	raise notice 'inserting combined rs/playoff avgs';
	insert into api.plr_agg select * from api.v_plr_cc_avg;
	raise notice e'combined avgs complete: %\n', public.fn_cntstr('api.plr_agg');
end; $$;
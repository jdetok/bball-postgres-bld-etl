-- run after recent build
select fn_cntstr('intake.player') union -- 4260 dev
select fn_cntstr('intake.wplayer') union -- 1145 dev
select fn_cntstr('intake.gm_team') union -- 137800 dev
select fn_cntstr('intake.gm_player') union -- 1394956 dev
select fn_cntstr('lg.szn') union -- 114 dev
select fn_cntstr('lg.team') union -- 50 dev
select fn_cntstr('lg.plr') union -- 5406 dev
select fn_cntstr('stats.tbox') union -- 137800 dev
select fn_cntstr('stats.pbox') union -- 1394956 dev
select fn_cntstr('api.plr_agg'); -- 105072 dev
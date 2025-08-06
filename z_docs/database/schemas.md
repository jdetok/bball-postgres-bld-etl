# bball postgres database schema design overview
## **NOTE: 
- `intake.[w]player` refers to BOTH the tables intake.player and intake.wplayer
## intake
- intake tables are inserted into by the [Go ETL process](https://github.com/jdetok/bball-etl-go)
- the layout of intake tables directly match the JSON response from stats.nba.com endpoints 
- ### tables
    - gm_player
        - SOURCE: leaguegamelog endpoint, PlayerOrTeam=P
        - pkey: game_id, player_id
    - gm_team
        - SOURCE: leaguegamelog endpoint, PlayerOrTeam=T
        - pkey: game_id, team_id
    - player
        - nba players
        - SOURCE: commonallplayers endpoint, LeagueID=00
        - pkey: player_id
    - wplayer
        - wnba players
        - SOURCE: commonallplayers endpoint, LeagueID=10
        - pkey: player_id
## lg
the league schema is for core player/league/team data
- ### tables 
    - league
        SOURCE: insert run after table created
        - pkey: lg_id
    - szn
        SOURCE: intake.gm_team, intake.[w]player
        - pkey: szn_id
    - team
        - pkey: team_id
    - plr
        - pkey: player_id
- ### procedures
    - sp_szn_load()
        - sources seasons from gm_team, uses several functions to format & insert into lg.szn
    - sp_team_all_load()
        - sources teams from intake.gm_team and intake.[w]player, inserts into lg.team
            - joins player on year from team's max season id, enables getting the most recent team name/info for teams that have switched cities/names before, and gets old disbanded teams as well (e.g. Houston Cornets)
    - sp_plr_all_load()
        - sources players from intake.gm_player and intake.[w]player
        - ** NOTE: WNBA player Angel Robinson had player id 202270 in 2014 and 202657 in all other years. after this sp is called, the following insert statement MUST be executed. if not, the stats.sp_pbox() and api.sp_plr_agg() procedures will fail with a foreign key error
        ```sql
        insert into lg.plr 
        (lg_id, player_id, plr_cde, player, last_first, from_year, to_year)
	    select
            1, 
            202270, 
            playercode, 
            display_first_last, 
            display_last_comma_first, 
            from_year, 
            to_year
	    from intake.wplayer
	    where person_id = 202657;
        ``` 
## stats
stats schema is for player/team box scores
- ### tables
    - pbox
        - SOURCE: intake.gm_player
        - pkey: game_id, player_id
    - tbox
        - SOURCE: intake.gm_team
        - pkey: game_id, team_id
- ### procedures
    - sp_tbox()
        - loads team box scores from intake.gm_team
    - sp_pbox()
        - loads player box scores from intake.gm_player
    
## api
aggregated season/career statistics by players. queried by jdeko.me/bball api 
- ### tables
    - plr_agg
        - almost completely matches mdb table. but season_desc and wseason_desc are added between season_id and stat_type  
- ### procedures
    - sp_plr_agg()
        - utilizes several views to aggregate and insert stats in different ways
### aggregate season IDs used 
## career stats
- 99999: used for combined reg. season/playoffs career stats
- 29999: used for reg. season career stats
- 49999: used for playoffs career stats